import 'dart:convert';

import 'shopping_item.dart';

/// A shopping list the user keeps on the device: its own stable id, its own
/// items, and its own name. Nothing here is shared with another list.
class SavedList {
  final int id;
  String name;
  final int createdAt;
  int updatedAt;
  final List<ShoppingItem> items;

  SavedList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.items,
    int? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  int get purchasedCount => items.where((e) => e.isPurchased).length;

  int get remainingCount => items.length - purchasedCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'items': items.map((e) => e.toJson()).toList(),
      };

  /// Throws on an unreadable record so the caller can skip it, keeping one bad
  /// entry from hiding the rest of the user's lists.
  factory SavedList.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid saved list');
    }
    final createdAt = json['createdAt'];
    final created = createdAt is int ? createdAt : 0;
    final updatedAt = json['updatedAt'];
    return SavedList(
      id: id,
      name: name,
      createdAt: created,
      // Lists saved before updatedAt existed are treated as last updated when
      // they were created.
      updatedAt: updatedAt is int ? updatedAt : created,
      items: _readItems(json['items']),
    );
  }

  static List<ShoppingItem> _readItems(Object? raw) {
    if (raw is! List) return [];
    final items = <ShoppingItem>[];
    for (final entry in raw) {
      try {
        final map = entry is String
            ? Map<String, dynamic>.from(jsonDecode(entry) as Map)
            : Map<String, dynamic>.from(entry as Map);
        if (map['id'] is! int || map['name'] is! String) continue;
        items.add(ShoppingItem.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    return items;
  }
}
