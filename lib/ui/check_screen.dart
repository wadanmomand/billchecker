import 'package:flutter/material.dart';

import '../bills/bill_fetcher.dart';
import '../bills/bill_store.dart';
import '../bills/providers.dart';
import '../bills/saved.dart';
import 'bill_view_screen.dart';
import '../ads/ad_banner.dart';
import 'theme.dart';

/// Enter the reference number, then check the bill:
/// - httpFirst providers: fetch + parse; on failure fall back to WebView.
/// - webViewOnly providers: straight to WebView with the deep link.
class CheckScreen extends StatefulWidget {
  final BillProvider provider;
  final String? prefill;

  const CheckScreen({super.key, required this.provider, this.prefill});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  final _ctrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) _ctrl.text = widget.prefill!;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String? _validate(String ref) {
    final digits = ref.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Please enter your ${widget.provider.inputLabel}.';
    if (!widget.provider.inputLengths.contains(digits.length)) {
      return 'Usually ${widget.provider.inputLengths.join(' or ')} digits — '
          'check the number and try again.';
    }
    return null;
  }

  Future<void> _check() async {
    final ref = _ctrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final err = _validate(ref);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });

    final url = widget.provider.urlBuilder(ref);
    await BillStore.addHistory(HistoryEntry(
      providerId: widget.provider.id,
      reference: ref,
      checkedAt: DateTime.now(),
    ));

    if (!mounted) return;

    if (widget.provider.mode == FetchMode.webViewOnly) {
      setState(() => _busy = false);
      _openWebView(url, ref, null);
      return;
    }

    // httpFirst: try to fetch + parse.
    try {
      final fetcher = BillFetcher();
      final result = await fetcher.fetch(url);
      fetcher.dispose();
      if (!mounted) return;
      setState(() => _busy = false);
      if (!result.blocked && (result.summary?.hasAny ?? false)) {
        _openWebView(url, ref, result.summary);
      } else {
        // CAPTCHA / unparseable — fall back to the WebView.
        _openWebView(url, ref, null);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _openWebView(url, ref, null);
    }
  }

  void _openWebView(String url, String ref, BillSummary? summary) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillViewScreen(
          provider: widget.provider,
          reference: ref,
          url: url,
          summary: summary,
        ),
      ),
    );
  }

  Future<void> _saveBill() async {
    final ref = _ctrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (_validate(ref) != null) {
      setState(() => _error = _validate(ref));
      return;
    }
    final name = _nameCtrl.text.trim().isEmpty
        ? widget.provider.shortName
        : _nameCtrl.text.trim();
    await BillStore.saveBill(SavedBill(
      providerId: widget.provider.id,
      reference: ref,
      name: name,
      savedAt: DateTime.now(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Bill saved')));
      _nameCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(title: Text(p.shortName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: BillTheme.navy)),
            const SizedBox(height: 4),
            Text(
              p.webViewHint ??
                  (p.mode == FetchMode.webViewOnly
                      ? 'Opens the official ${p.shortName} page — solve the captcha there if asked.'
                      : 'Fetches your latest bill from the official ${p.shortName} portal.'),
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: p.inputLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Save as (optional, e.g. Home)'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 20),
            GoldButton(
                label: _busy ? 'CHECKING…' : 'CHECK BILL',
                onPressed: _busy ? null : _check),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _saveBill,
              icon: const Icon(Icons.bookmark_add),
              label: const Text('Save this bill'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data comes from the official public portal. This app is not '
              'affiliated with the utility provider.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
