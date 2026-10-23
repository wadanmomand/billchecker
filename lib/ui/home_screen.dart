import 'package:flutter/material.dart';

import '../bills/bill_store.dart';
import '../bills/providers.dart';
import '../bills/saved.dart';
import 'check_screen.dart';
import 'provider_list_screen.dart';
import 'saved_screen.dart';
import 'sources_dialog.dart';
import '../ads/ad_banner.dart';
import 'theme.dart';

/// Home: just two big options — Electricity and Gas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavedBill> _saved = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final saved = await BillStore.loadSaved();
    if (mounted) setState(() => _saved = saved);
  }

  void _openKind(BillKind kind) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => ProviderListScreen(kind: kind)))
        .then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(
        title: const Text('MY BILL CHECKER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sources & Disclaimer',
            onPressed: () => showBillCheckerSourcesDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'Saved bills',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SavedScreen()))
                .then((_) => _reload()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          _bigCard(
            icon: Icons.bolt,
            iconColor: BillTheme.navy,
            title: 'Electricity',
            subtitle: 'LESCO, GEPCO, FESCO, IESCO, MEPCO, PESCO, HESCO, SEPCO, QESCO, K-Electric',
            onTap: () => _openKind(BillKind.electricity),
          ),
          const SizedBox(height: 16),
          _bigCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange.shade700,
            title: 'Gas',
            subtitle: 'SNGPL, SSGC',
            onTap: () => _openKind(BillKind.gas),
          ),
          const SizedBox(height: 24),
          if (_saved.isNotEmpty) ...[
            const Text(
              'Saved bills — one tap check',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: BillTheme.navy),
            ),
            const SizedBox(height: 8),
            ..._saved.take(4).map((b) {
              final p = kProviders.firstWhere(
                  (p) => p.id == b.providerId,
                  orElse: () => kProviders.first);
              return Card(
                child: ListTile(
                  leading: Icon(
                      p.kind == BillKind.electricity
                          ? Icons.bolt
                          : Icons.local_fire_department,
                      color: BillTheme.goldDark),
                  title: Text(b.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.shortName} • ${b.reference}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) =>
                              CheckScreen(provider: p, prefill: b.reference)))
                      .then((_) => _reload()),
                ),
              );
            }),
          ],
          const SizedBox(height: 32),
          const Text(
            'Not affiliated with any utility provider. Bill data comes from '
            'official public portals; accuracy depends on their servers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _bigCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: BillTheme.navy)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
