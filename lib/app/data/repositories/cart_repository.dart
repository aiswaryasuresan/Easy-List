import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../models/shopping_item.dart';

class CartRepository {
  static const _itemsKey = 'shopping_items';
  final GetStorage _box = GetStorage();

  List<ShoppingItem> loadItems() {
    final raw = _box.read<List<dynamic>>(_itemsKey);
    if (raw == null) return [];
    return raw.map((e) {
      if (e is String) {
        return ShoppingItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(e) as Map));
      }
      return ShoppingItem.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();
  }

  void saveItems(List<ShoppingItem> items) {
    _box.write(_itemsKey, items.map((e) => e.toJson()).toList());
  }

  int nextId(List<ShoppingItem> items) =>
      items.isEmpty ? 1 : items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

  int nextSortOrder(List<ShoppingItem> items) => items.isEmpty
      ? 1
      : items.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
}
