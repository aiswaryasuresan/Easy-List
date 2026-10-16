import 'package:flutter/material.dart' show FocusNode, TextEditingController;
import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';
import '../../data/default_product_catalog.dart';
import '../../data/malayalam_product_catalog.dart';
import '../../data/models/shopping_item.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/item_history_repository.dart';

class HomeController extends GetxController {
  final CartRepository _repo = Get.put(CartRepository());
  final ItemHistoryRepository _history = Get.put(ItemHistoryRepository());
  List<HistoryEntry> _historyEntries = [];

  final items = <ShoppingItem>[].obs;
  final purchasedSectionExpanded = false.obs;

  // 0 = All, 1 = To Buy, 2 = Purchased
  final filter = 0.obs;

  // 0 = List tab, 1 = Settings tab, 2 = Share tab
  final tab = 0.obs;
  final query = ''.obs;
  final searchFocus = FocusNode();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    items.assignAll(_repo.loadItems());
    _historyEntries = _history.load();
  }

  @override
  void onClose() {
    searchFocus.dispose();
    searchController.dispose();
    super.onClose();
  }

  List<ShoppingItem> get pendingItems =>
      _search(items.where((e) => !e.isPurchased));

  List<ShoppingItem> get purchasedItems =>
      _search(items.where((e) => e.isPurchased));

  List<ShoppingItem> _search(Iterable<ShoppingItem> source) {
    final q = query.value.trim().toLowerCase();
    final list = source.toList();
    if (q.isEmpty) return list;
    return list.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  int get remainingCount =>
      items.where((e) => !e.isPurchased).length;
  bool get isEmpty => items.isEmpty;
  bool get hasPurchased =>
      items.any((e) => e.isPurchased);

  // ---------- Autocomplete ----------

  bool get showSuggestions =>
      tab.value == 0 && query.value.trim().isNotEmpty;

  List<ProductSuggestion> suggestionsFor(String rawQuery) {
    final q = normalizeProductName(rawQuery);
    if (q.isEmpty) return const [];

    int rank(String name, List<String> aliases) {
      final n = normalizeProductName(name);
      if (n == q) return 0;
      if (n.startsWith(q)) return 1;
      if (n.contains(q)) return 2;
      for (final a in aliases) {
        final an = normalizeProductName(a);
        if (an == q) return 0;
        if (an.startsWith(q)) return 3;
      }
      for (final a in aliases) {
        if (normalizeProductName(a).contains(q)) return 4;
      }
      return 99;
    }

    final results = <ProductSuggestion>[];
    final seen = <String>{};

    final catalog = <List<Object>>[];
    for (final p in kAllProductCatalog) {
      final r = rank(p.name, p.aliases);
      if (r != 99) catalog.add([r, p]);
    }
    catalog.sort((a, b) {
      final ra = a[0] as int, rb = b[0] as int;
      if (ra != rb) return ra.compareTo(rb);
      return (a[1] as CatalogProduct)
          .name
          .compareTo((b[1] as CatalogProduct).name);
    });
    for (final entry in catalog) {
      final p = entry[1] as CatalogProduct;
      if (seen.add(normalizeProductName(p.name))) {
        results.add(ProductSuggestion(
            name: p.name, category: p.category, unit: p.defaultUnit));
      }
      if (results.length >= 6) return results;
    }

    final hist = _historyEntries
        .where((e) => !seen.contains(e.normalized))
        .where((e) => e.normalized.startsWith(q) || e.normalized.contains(q))
        .toList()
      ..sort((a, b) {
        final ap = a.normalized.startsWith(q) ? 0 : 1;
        final bp = b.normalized.startsWith(q) ? 0 : 1;
        if (ap != bp) return ap.compareTo(bp);
        if (a.lastUsed != b.lastUsed) return b.lastUsed.compareTo(a.lastUsed);
        return b.count.compareTo(a.count);
      });
    for (final e in hist) {
      seen.add(e.normalized);
      results.add(ProductSuggestion(
          name: e.name,
          category: 'Recently added',
          unit: e.unit,
          fromHistory: true));
      if (results.length >= 6) break;
    }
    return results;
  }

  /// Returns a message when the selection must be blocked, null when the
  /// Add Item form can be opened.
  String? blockReasonFor(ProductSuggestion s) {
    final norm = normalizeProductName(s.name);
    final alreadyPending = items.any(
        (e) => !e.isPurchased && normalizeProductName(e.name) == norm);
    if (alreadyPending) return 'Already on your list';
    return null;
  }

  void addItem(String name, double? quantity, String? unit) {
    final now = DateTime.now().millisecondsSinceEpoch;
    items.add(ShoppingItem(
      id: _repo.nextId(items),
      name: name,
      quantity: quantity,
      unit: unit,
      sortOrder: _repo.nextSortOrder(items),
      createdAt: now,
    ));
    _persist();
    _history.record(name, unit);
    _historyEntries = _history.load();
    query.value = '';
    searchController.clear();
    HapticService.success();
  }

  void updateItem(int id, String name, double? quantity, String? unit) {
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    items[index].name = name;
    items[index].quantity = quantity;
    items[index].unit = unit;
    items.refresh();
    _persist();
    HapticService.success();
  }

  void deleteItem(int id) {
    items.removeWhere((e) => e.id == id);
    _persist();
  }

  void duplicateItem(int id) {
    final source = items.where((e) => e.id == id).firstOrNull;
    if (source == null) return;
    final copy = ShoppingItem(
      id: _repo.nextId(items),
      name: source.name,
      quantity: source.quantity,
      unit: source.unit,
      isPurchased: false,
      sortOrder: _repo.nextSortOrder(items),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    items.insert(items.indexOf(source) + 1, copy);
    _persist();
  }

  void togglePurchased(int id) {
    final item = items.where((e) => e.id == id).firstOrNull;
    if (item == null) return;
    item.isPurchased = !item.isPurchased;
    items.refresh();
    _persist();
    HapticService.lightTap();
  }

  void clearPurchased() {
    items.removeWhere((e) => e.isPurchased);
    _persist();
  }

  void _persist() => _repo.saveItems(items);
}
