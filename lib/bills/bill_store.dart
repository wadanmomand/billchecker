import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'saved.dart';

/// Local storage: saved bills (named) + recent search history.
class BillStore {
  static const _savedKey = 'saved_bills';
  static const _historyKey = 'bill_history';

  static Future<List<SavedBill>> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => SavedBill.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveBill(SavedBill bill) async {
    final bills = await loadSaved();
    bills.removeWhere(
        (b) => b.providerId == bill.providerId && b.reference == bill.reference);
    bills.insert(0, bill);
    while (bills.length > 50) {
      bills.removeLast();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _savedKey, jsonEncode(bills.map((b) => b.toJson()).toList()));
  }

  static Future<void> deleteSaved(int index) async {
    final bills = await loadSaved();
    if (index >= 0 && index < bills.length) {
      bills.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _savedKey, jsonEncode(bills.map((b) => b.toJson()).toList()));
    }
  }

  static Future<List<HistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addHistory(HistoryEntry entry) async {
    final history = await loadHistory();
    history.removeWhere((h) =>
        h.providerId == entry.providerId && h.reference == entry.reference);
    history.insert(0, entry);
    while (history.length > 50) {
      history.removeLast();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _historyKey, jsonEncode(history.map((h) => h.toJson()).toList()));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
