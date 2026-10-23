/// Sources & Disclaimer dialog (Play Misleading Claims policy fix,
/// 2026-10-23). Opened from the AppBar info button on the home screen.
/// States plainly that this is NOT a government app and names the
/// official portals the bill data comes from.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showBillCheckerSourcesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sources & Disclaimer'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This app is NOT a government app. It is not affiliated '
              'with, endorsed by, or connected to PITC, any DISCO, '
              'K-Electric, SNGPL, SSGC, or any government body.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bill data always comes from the official portals below, '
              'opened on your own device. This app only shows you the '
              'result — it does not issue bills and cannot change them. '
              "Your utility's own portal and bill are the final "
              'authority.',
            ),
            const SizedBox(height: 12),
            const Text('Official sources:'),
            _Link(
              label: 'PITC Web Bill Portal (10 ex-WAPDA DISCOs)',
              url: 'https://bill.pitc.com.pk/',
            ),
            _Link(
              label: 'K-Electric — bills & e-payments',
              url: 'https://ke.com.pk/bills-e-payments/',
            ),
            _Link(
              label: 'SNGPL — official website',
              url: 'https://www.sngpl.com.pk/',
            ),
            _Link(
              label: 'SSGC — official bill portal',
              url: 'https://viewbill.ssgc.com.pk/web/',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class _Link extends StatelessWidget {
  final String label;
  final String url;
  const _Link({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Text(
          '$label\n$url',
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
