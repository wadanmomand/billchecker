/// Bill fetcher: HTTP GET of the provider deep link + defensive HTML parse.
///
/// MVP reality: there is no JSON API. For captcha-free portals we fetch the
/// deep link and extract key fields with tolerant label matching. Anything
/// ambiguous (CAPTCHA page, login wall, unparseable HTML) is reported so the
/// UI can fall back to the in-app WebView.
library;

import 'package:http/http.dart' as http;

/// Key fields extracted from a bill page. All nullable — parsing is
/// best-effort and varies by portal.
class BillSummary {
  final String? consumerName;
  final String? payableAmount;
  final String? dueDate;
  final String? unitsConsumed;
  final String? billingMonth;

  const BillSummary({
    this.consumerName,
    this.payableAmount,
    this.dueDate,
    this.unitsConsumed,
    this.billingMonth,
  });

  bool get hasAny =>
      consumerName != null ||
      payableAmount != null ||
      dueDate != null ||
      unitsConsumed != null ||
      billingMonth != null;
}

class FetchResult {
  final BillSummary? summary;
  final String html;

  /// True when the page looks like a CAPTCHA / bot-check / login wall.
  final bool blocked;

  const FetchResult({this.summary, required this.html, this.blocked = false});
}

class BillFetcher {
  static const _ua =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36';

  final http.Client _client;
  BillFetcher({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  static final _blockedMarkers = [
    'captcha',
    'recaptcha',
    'g-recaptcha',
    'cf-challenge',
    'just a moment',
    'verify you are human',
  ];

  /// Fetches [url] and tries to parse a bill summary out of the HTML.
  Future<FetchResult> fetch(String url) async {
    final res = await _client
        .get(Uri.parse(url), headers: {'User-Agent': _ua})
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      return FetchResult(html: '', blocked: true);
    }
    final html = res.body;
    final lower = html.toLowerCase();
    if (_blockedMarkers.any(lower.contains)) {
      return FetchResult(html: html, blocked: true);
    }
    final summary = parseBillHtml(html);
    return FetchResult(html: html, summary: summary);
  }

  /// Best-effort extraction of bill fields from portal HTML.
  /// Public for tests. Returns a summary that may have all-null fields
  /// when nothing recognizable is found.
  static BillSummary parseBillHtml(String html) {
    // Strip tags to get visible text, keeping it simple and tolerant.
    final text = html
        .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'[ \t\xa0]+'), ' ');

    String? find(List<String> labels, {bool Function(String)? valid}) {
      for (final label in labels) {
        final matches = RegExp(
          '${RegExp.escape(label)}\\s*[:\\-]?\\s*([^\\n]{1,60})',
          caseSensitive: false,
        ).allMatches(text);
        for (final m in matches) {
          final v = m.group(1)!.trim();
          if (v.isEmpty || v.length >= 60) continue;
          if (valid != null && !valid(v)) continue;
          return v;
        }
      }
      return null;
    }

    bool hasDigit(String v) => RegExp(r'\d').hasMatch(v);
    bool looksLikeDate(String v) =>
        hasDigit(v) &&
        (v.contains('-') ||
            v.contains('/') ||
            RegExp(r'jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec',
                    caseSensitive: false)
                .hasMatch(v));

    return BillSummary(
      payableAmount: find(
        [
          'payable within due date',
          'net payable',
          'total payable',
          'payable amount',
          'amount payable',
          'bill amount',
        ],
        valid: hasDigit,
      ),
      dueDate: find(
        [
          'due date',
          'last date',
          'pay by',
        ],
        valid: looksLikeDate,
      ),
      unitsConsumed: find(
        [
          'units consumed',
          'units',
          'consumption',
        ],
        valid: hasDigit,
      ),
      consumerName: find([
        'consumer name',
        'customer name',
        'name',
      ]),
      billingMonth: find(
        [
          'billing month',
          'bill month',
          'month',
        ],
        valid: (v) => RegExp(
                r'jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|\d{4}',
                caseSensitive: false)
            .hasMatch(v),
      ),
    );
  }
}
