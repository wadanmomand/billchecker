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

  /// Builds the deep link for [reference]. Return null if the provider
  /// needs the user to type the number on the page itself.
  final String Function(String reference) urlBuilder;

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
    required this.inputLabel,
    required this.inputLengths,
  });
}

String _pitc(String prefix) =>
    'https://bill.pitc.com.pk/${prefix}bill/general?refno=';

/// All 12 launch providers. Order: electricity DISCOs, KE, then gas.
///
/// NOTE: KE/SNGPL/SSGC deep-link formats are best-effort (not live-verified
/// from our network — portals are Pakistan-geo-restricted). The WebView
/// fallback means a wrong deep link still lands the user on the right
/// portal page to type the number manually.
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

String _keUrl(String account) =>
    'https://www.ke.com.pk/bill/check-bill?account=$account';

String _sngplUrl(String consumer) =>
    'https://www.sngpl.com.pk/web/customer-services/view-bill?consumer=$consumer';

String _ssgcUrl(String customer) =>
    'https://viewbill.ssgc.com.pk/web/?customer=$customer';
