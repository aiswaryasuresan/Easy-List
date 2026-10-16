import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../default_product_catalog.dart';
import '../malayalam_product_catalog.dart';

class HistoryEntry {
  final String name;
  final String normalized;
  final String? category;
  final String? unit;
  final int lastUsed;
  final int count;

  const HistoryEntry({
    required this.name,
    required this.normalized,
    this.category,
    this.unit,
    required this.lastUsed,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'normalized': normalized,
        'category': category,
        'unit': unit,
        'lastUsed': lastUsed,
        'count': count,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        name: json['name'] as String,
        normalized: json['normalized'] as String? ??
            normalizeProductName(json['name'] as String),
        category: json['category'] as String?,
        unit: json['unit'] as String?,
        lastUsed: json['lastUsed'] as int? ?? 0,
        count: json['count'] as int? ?? 1,
      );
}

class ItemHistoryRepository {
  static const _key = 'item_history';
  final GetStorage _box = GetStorage();

  List<HistoryEntry> load() {
    final raw = _box.read<List<dynamic>>(_key);
    if (raw == null) return [];
    return raw.map((e) {
      if (e is String) {
        return HistoryEntry.fromJson(
            Map<String, dynamic>.from(jsonDecode(e) as Map));
      }
      return HistoryEntry.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();
  }

  void record(String name, String? unit) {
    final normalized = normalizeProductName(name);
    if (normalized.isEmpty) return;
    final entries = load();
    final index =
        entries.indexWhere((e) => e.normalized == normalized);
    final catalogMatches = kAllProductCatalog
        .where((p) => normalizeProductName(p.name) == normalized)
        .toList();
    final catalogCategory =
        catalogMatches.isEmpty ? null : catalogMatches.first.category;
    final catalogUnit =
        catalogMatches.isEmpty ? null : catalogMatches.first.defaultUnit;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (index == -1) {
      entries.add(HistoryEntry(
        name: name.trim(),
        normalized: normalized,
        category: catalogCategory,
        unit: unit ?? catalogUnit,
        lastUsed: now,
        count: 1,
      ));
    } else {
      final old = entries[index];
      entries[index] = HistoryEntry(
        name: old.name,
        normalized: old.normalized,
        category: old.category ?? catalogCategory,
        unit: unit ?? old.unit ?? catalogUnit,
        lastUsed: now,
        count: old.count + 1,
      );
    }
    entries.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    _box.write(_key, entries.take(200).map((e) => e.toJson()).toList());
  }
}
