import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ui/home_screen.dart';
import 'ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: ads must never block the app (offline, plugin missing).
  try {
    await MobileAds.instance.initialize();
  } catch (_) {}
  runApp(const BillCheckerApp());
}

class BillCheckerApp extends StatelessWidget {
  const BillCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bill Checker Pakistan',
      debugShowCheckedModeBanner: false,
      theme: BillTheme.light(),
      home: const HomeScreen(),
    );
  }
}
