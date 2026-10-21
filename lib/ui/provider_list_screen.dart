import 'package:flutter/material.dart';

import '../bills/providers.dart';
import 'check_screen.dart';
import '../ads/ad_banner.dart';
import 'theme.dart';

/// Lists the providers of one kind (Electricity or Gas).
class ProviderListScreen extends StatelessWidget {
  final BillKind kind;

  const ProviderListScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final providers = kProviders.where((p) => p.kind == kind).toList();
    final title = kind == BillKind.electricity ? 'ELECTRICITY' : 'GAS';

    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: providers.length,
        itemBuilder: (context, i) {
          final p = providers[i];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckScreen(provider: p)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    kind == BillKind.electricity
                        ? Icons.bolt
                        : Icons.local_fire_department,
                    color: kind == BillKind.electricity
                        ? BillTheme.navy
                        : Colors.orange.shade700,
                    size: 34,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.shortName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      p.name.split('—').last.trim(),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
