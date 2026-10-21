import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bill_checker/bills/bill_fetcher.dart';
import 'package:bill_checker/bills/providers.dart';

void main() {
  group('providers', () {
    test('all 12 launch providers present', () {
      expect(kProviders.length, 12);
      final ids = kProviders.map((p) => p.id).toSet();
      expect(ids, containsAll([
        'lesco', 'gepco', 'fesco', 'iesco', 'mepco',
        'pesco', 'hesco', 'sepco', 'qesco', 'ke', 'sngpl', 'ssgc',
      ]));
    });

    test('pitc deep link format', () {
      final lesco = kProviders.firstWhere((p) => p.id == 'lesco');
      expect(lesco.urlBuilder('12345678901234'),
          'https://bill.pitc.com.pk/lescobill/general?refno=12345678901234');
    });

    test('captcha-expected providers go webViewOnly', () {
      for (final id in ['fesco', 'pesco', 'qesco', 'sngpl', 'ke']) {
        final p = kProviders.firstWhere((p) => p.id == id);
        expect(p.mode, FetchMode.webViewOnly, reason: id);
      }
    });

    test('likely captcha-free providers try httpFirst', () {
      for (final id in ['lesco', 'gepco', 'iesco', 'mepco', 'hesco', 'sepco', 'ssgc']) {
        final p = kProviders.firstWhere((p) => p.id == id);
        expect(p.mode, FetchMode.httpFirst, reason: id);
      }
    });
  });

  group('parseBillHtml', () {
    test('extracts common fields', () {
      const html = '''
        <html><body><table>
        <tr><td>Consumer Name</td><td>ALI RAZA</td></tr>
        <tr><td>Payable Within Due Date</td><td>Rs. 4,250</td></tr>
        <tr><td>Due Date</td><td>20-11-2026</td></tr>
        <tr><td>Units Consumed</td><td>312</td></tr>
        <tr><td>Billing Month</td><td>OCT 2026</td></tr>
        </table></body></html>
      ''';
      final s = BillFetcher.parseBillHtml(html);
      expect(s.consumerName, contains('ALI RAZA'));
      expect(s.payableAmount, contains('4,250'));
      expect(s.dueDate, contains('20-11-2026'));
      expect(s.unitsConsumed, contains('312'));
      expect(s.billingMonth, contains('OCT 2026'));
      expect(s.hasAny, isTrue);
    });

    test('returns empty summary for unrecognized html', () {
      final s = BillFetcher.parseBillHtml('<html><body>hello</body></html>');
      expect(s.hasAny, isFalse);
    });
  });

  group('fetch', () {
    test('flags captcha pages as blocked', () async {
      final client =
          MockClient((_) async => http.Response('<div>g-recaptcha</div>', 200));
      final f = BillFetcher(client: client);
      final r = await f.fetch('https://example.com/bill');
      expect(r.blocked, isTrue);
      f.dispose();
    });

    test('non-200 is blocked', () async {
      final client = MockClient((_) async => http.Response('x', 500));
      final f = BillFetcher(client: client);
      final r = await f.fetch('https://example.com/bill');
      expect(r.blocked, isTrue);
      f.dispose();
    });

    test('parses bill page into summary', () async {
      final client = MockClient((_) async => http.Response(
          '<td>Due Date</td><td>20-11-2026</td>', 200));
      final f = BillFetcher(client: client);
      final r = await f.fetch('https://example.com/bill');
      expect(r.blocked, isFalse);
      expect(r.summary?.dueDate, contains('20-11-2026'));
      f.dispose();
    });
  });
}
