import 'dart:convert';

/// A saved bill lookup: provider + reference + user-given name.
class SavedBill {
  final String providerId;
  final String reference;
  final String name;
  final DateTime savedAt;

  SavedBill({
    required this.providerId,
    required this.reference,
    required this.name,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'reference': reference,
        'name': name,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedBill.fromJson(Map<String, dynamic> json) => SavedBill(
        providerId: json['providerId'] as String,
        reference: json['reference'] as String,
        name: json['name'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

/// Search history entry (most recent first, max 50).
class HistoryEntry {
  final String providerId;
  final String reference;
  final DateTime checkedAt;

  HistoryEntry({
    required this.providerId,
    required this.reference,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'reference': reference,
        'checkedAt': checkedAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        providerId: json['providerId'] as String,
        reference: json['reference'] as String,
        checkedAt: DateTime.parse(json['checkedAt'] as String),
      );
}

String encodeJsonList(List<Map<String, dynamic>> items) =>
    jsonEncode(items);
