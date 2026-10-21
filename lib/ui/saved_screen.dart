import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bills/bill_store.dart';
import '../bills/providers.dart';
import '../bills/saved.dart';
import 'check_screen.dart';
import '../ads/ad_banner.dart';
import 'theme.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<SavedBill> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final bills = await BillStore.loadSaved();
    if (mounted) {
      setState(() {
        _bills = bills;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(title: const Text('SAVED BILLS')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? const Center(
                  child: Text('No saved bills yet.\nSave one from any provider.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bills.length,
                  itemBuilder: (context, i) {
                    final b = _bills[i];
                    final p = kProviders.firstWhere(
                        (p) => p.id == b.providerId,
                        orElse: () => kProviders.first);
                    return Dismissible(
                      key: ValueKey('${b.savedAt.millisecondsSinceEpoch}-$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await BillStore.deleteSaved(i);
                        await _reload();
                      },
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                              p.kind == BillKind.electricity
                                  ? Icons.bolt
                                  : Icons.local_fire_department,
                              color: BillTheme.goldDark,
                              size: 30),
                          title: Text(b.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: BillTheme.navy)),
                          subtitle: Text(
                              '${p.shortName} • ${b.reference}\n'
                              'Saved ${DateFormat('d MMM yyyy').format(b.savedAt)}'),
                          isThreeLine: true,
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CheckScreen(
                                  provider: p, prefill: b.reference),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
