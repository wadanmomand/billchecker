import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bills/bill_fetcher.dart';
import '../bills/providers.dart';
import '../ads/ad_banner.dart';
import 'theme.dart';

/// Shows the bill: a parsed summary card on top (when available) and the
/// official portal page in a WebView below (always the source of truth).
class BillViewScreen extends StatefulWidget {
  final BillProvider provider;
  final String reference;
  final String url;
  final BillSummary? summary;

  const BillViewScreen({
    super.key,
    required this.provider,
    required this.reference,
    required this.url,
    this.summary,
  });

  @override
  State<BillViewScreen> createState() => _BillViewScreenState();
}

class _BillViewScreenState extends State<BillViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(
        title: Text('${widget.provider.shortName} BILL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () {
              setState(() => _loading = true);
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (s != null && s.hasAny)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [BillTheme.navy, BillTheme.navyDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.consumerName != null)
                    _line('Name', s.consumerName!),
                  if (s.billingMonth != null)
                    _line('Billing month', s.billingMonth!),
                  if (s.unitsConsumed != null)
                    _line('Units', s.unitsConsumed!),
                  if (s.dueDate != null) _line('Due date', s.dueDate!),
                  if (s.payableAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Payable: ${s.payableAmount!}',
                        style: const TextStyle(
                          color: BillTheme.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
