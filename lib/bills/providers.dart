/// Bill provider configurations for My Bill Checker Pakistan.
///
/// Research: `bill.pitc.com.pk/<prefix>bill` covers the ex-WAPDA DISCOs;
/// K-Electric, SNGPL and SSGC have their own portals.
/// (research_notes/pakistan-bill-checker-portals-20261019-1831)
library;

enum BillKind { electricity, gas }

enum FetchMode {
  /// Try HTTP GET + HTML parse first; fall back to WebView automatically.
  httpFirst,

  /// Go straight to in-app WebView (CAPTCHA expected).
  webViewOnly,
}

class BillProvider {
  final String id;
  final String name;
  final String shortName;
  final BillKind kind;
  final FetchMode mode;

  /// Builds the deep link for [reference]. For providers whose portal has
  /// no working deep link, this returns the official page itself and the
  /// user types the number there (see [webViewHint]).
  final String Function(String reference) urlBuilder;

  /// Hint shown when the number must be typed on the portal page itself
  /// (null = the number is carried in the deep link).
  final String? webViewHint;

  /// Label shown above the input field, e.g. "14-digit Reference Number".
  final String inputLabel;

  /// Expected digit counts (validated loosely — portals accept variants).
  final List<int> inputLengths;

  const BillProvider({
    required this.id,
    required this.name,
    required this.shortName,
    required this.kind,
    required this.mode,
    required this.urlBuilder,
    this.webViewHint,
    required this.inputLabel,
    required this.inputLengths,
  });
}

String _pitc(String prefix) =>
    'https://bill.pitc.com.pk/${prefix}bill/general?refno=';

/// All 12 launch providers. Order: electricity DISCOs, KE, then gas.
///
/// NOTE (2026-10-22, phone-verified): KE and SNGPL have NO working deep
/// link. KE's old /bill/check-bill?account= path times out on a real phone;
/// the live official page is ke.com.pk/bills-e-payments (verified 2026-10-22).
/// SNGPL's guessed /web/customer-services/view-bill path 404s; its bill form
/// ("Get Your Gas Bill" → Consumer Bill + captcha) is only reachable through
/// the site's menu, so the WebView opens sngpl.com.pk itself. Both providers
/// carry a [BillProvider.webViewHint] telling the user what to type where.
final List<BillProvider> kProviders = [
  BillProvider(
    id: 'lesco',
    name: 'LESCO — Lahore Electric',
    shortName: 'LESCO',
    kind: BillKind.electricity,
    mode: FetchMode.httpFirst,
    urlBuilder: _pitcRef('lesco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10, 7],
  ),
  BillProvider(
    id: 'gepco',
    name: 'GEPCO — Gujranwala Electric',
    shortName: 'GEPCO',
    kind: BillKind.electricity,
    mode: FetchMode.httpFirst,
    urlBuilder: _pitcRef('gepco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'fesco',
    name: 'FESCO — Faisalabad Electric',
    shortName: 'FESCO',
    kind: BillKind.electricity,
    mode: FetchMode.webViewOnly, // image CAPTCHA confirmed
    urlBuilder: _pitcRef('fesco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'iesco',
    name: 'IESCO — Islamabad Electric',
    shortName: 'IESCO',
    kind: BillKind.electricity,
    mode: FetchMode.httpFirst,
    urlBuilder: _pitcRef('iesco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'mepco',
    name: 'MEPCO — Multan Electric',
    shortName: 'MEPCO',
    kind: BillKind.electricity,
    mode: FetchMode.httpFirst,
    urlBuilder: _pitcRef('mepco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'pesco',
    name: 'PESCO — Peshawar Electric',
    shortName: 'PESCO',
    kind: BillKind.electricity,
    mode: FetchMode.webViewOnly, // image CAPTCHA confirmed
    urlBuilder: _pitcRef('pesco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'hesco',
    name: 'HESCO — Hyderabad Electric',
    shortName: 'HESCO',
    kind: BillKind.electricity,
    mode: FetchMode.httpFirst,
    urlBuilder: _pitcRef('hesco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'sepco',
    name: 'SEPCO — Sukkur Electric',
    shortName: 'SEPCO',
    kind: BillKind.electricity,
    mode: FetchMode.httpFirst,
    urlBuilder: _pitcRef('sepco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'qesco',
    name: 'QESCO — Quetta Electric',
    shortName: 'QESCO',
    kind: BillKind.electricity,
    mode: FetchMode.webViewOnly, // image CAPTCHA confirmed
    urlBuilder: _pitcRef('qesco'),
    inputLabel: 'Reference Number (14 digits)',
    inputLengths: [14, 10],
  ),
  BillProvider(
    id: 'ke',
    name: 'K-Electric',
    shortName: 'KE',
    kind: BillKind.electricity,
    mode: FetchMode.webViewOnly, // separate system; CAPTCHA unconfirmed
    urlBuilder: _keUrl,
    webViewHint:
        'On the KE page, enter your 13-digit account number to view the bill.',
    inputLabel: 'Account Number (13 digits)',
    inputLengths: [13],
  ),
  BillProvider(
    id: 'sngpl',
    name: 'SNGPL — Sui Northern Gas',
    shortName: 'SNGPL',
    kind: BillKind.gas,
    mode: FetchMode.webViewOnly, // image CAPTCHA per 3 sources
    urlBuilder: _sngplUrl,
    webViewHint:
        "On the SNGPL site, open 'Get Your Gas Bill' → Consumer Bill, then enter your consumer number and the captcha.",
    inputLabel: 'Consumer Number (11 digits)',
    inputLengths: [11],
  ),
  BillProvider(
    id: 'ssgc',
    name: 'SSGC — Sui Southern Gas',
    shortName: 'SSGC',
    kind: BillKind.gas,
    mode: FetchMode.httpFirst, // likely no CAPTCHA
    urlBuilder: _ssgcUrl,
    inputLabel: 'Customer Number (10 digits)',
    inputLengths: [10],
  ),
];

String Function(String) _pitcRef(String prefix) =>
    (ref) => '${_pitc(prefix)}$ref';

/// KE has no working deep link (the old /bill/check-bill?account= path
/// times out on a real phone, 2026-10-22). Open the live official
/// Digital Bills & Payments page; the user enters the number there.
String _keUrl(String account) => 'https://ke.com.pk/bills-e-payments/';

/// SNGPL has no documented deep link (the guessed view-bill path 404s,
/// 2026-10-22). Open the official site; the user reaches the Consumer
/// Bill form via 'Get Your Gas Bill' in the site menu.
String _sngplUrl(String consumer) => 'https://www.sngpl.com.pk/';

String _ssgcUrl(String customer) =>
    'https://viewbill.ssgc.com.pk/web/?customer=$customer';
