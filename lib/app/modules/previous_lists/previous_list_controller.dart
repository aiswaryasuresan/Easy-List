import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';
import '../../core/writers/item_writer.dart';
import '../../data/models/saved_list.dart';
import '../../data/models/shopping_item.dart';
import '../../data/repositories/saved_list_repository.dart';
import '../home/home_controller.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatSavedListDate(int millis) {
  if (millis <= 0) return 'Unknown date';
  final date = DateTime.fromMillisecondsSinceEpoch(millis);
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'am' : 'pm';
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}, '
      '$hour:$minute $period';
}

class PreviousListController extends GetxController {
  static const maxSavedLists = 50;

  final SavedListRepository _repo = Get.put(SavedListRepository());
  final lists = <SavedList>[].obs;

  @override
  void onInit() {
    super.onInit();
    lists.assignAll(_repo.load());
  }

  SavedList? byId(int id) => lists.where((e) => e.id == id).firstOrNull;

  String suggestedName() => 'Trip on ${formatSavedListDate(
        DateTime.now().millisecondsSinceEpoch,
      )}';

  /// Case- and whitespace-insensitive so "Weekly Grocery" and
  /// " weekly grocery " are treated as the same list name.
  bool nameTaken(String name, {int? exceptId}) {
    final candidate = _normalizeName(name)?.toLowerCase();
    if (candidate == null) return false;
    return lists.any(
        (e) => e.id != exceptId && e.name.toLowerCase() == candidate);
  }

  /// Creates an empty list the user can fill in straight away. Returns null
  /// when the name is blank or already used by another list.
  SavedList? createList(String name) {
    final normalized = _normalizeName(name);
    if (normalized == null || nameTaken(normalized)) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    final saved = SavedList(
      id: _repo.nextId(lists),
      name: normalized,
      createdAt: now,
      items: <ShoppingItem>[],
    );
    _insertNewest(saved);
    HapticService.selection();
    return saved;
  }

  static const maxListNameLength = 60;

  String? _normalizeName(String? raw) {
    final trimmed = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return null;
    return trimmed.length > maxListNameLength
        ? trimmed.substring(0, maxListNameLength)
        : trimmed;
  }

  void _insertNewest(SavedList saved) {
    lists.insert(0, saved);
    if (lists.length > maxSavedLists) {
      lists.removeRange(maxSavedLists, lists.length);
    }
    _persist();
  }

  /// Snapshots the active list. When [clearActiveList] is set the List screen
  /// starts empty again, ready for the next trip.
  SavedList saveActiveList(String name, {required bool clearActiveList}) {
    final home = Get.find<HomeController>();
    final saved = SavedList(
      id: _repo.nextId(lists),
      name: _normalizeName(name) ?? suggestedName(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      items: home.items.map((e) => ShoppingItem.fromJson(e.toJson())).toList(),
    );
    _insertNewest(saved);
    if (clearActiveList) home.clearList();
    HapticService.success();
    return saved;
  }

  void rename(int id, String name) {
    final saved = byId(id);
    final normalized = _normalizeName(name);
    if (normalized == null ||
        saved == null ||
        nameTaken(normalized, exceptId: id)) {
      return;
    }
    saved.name = normalized;
    _touch(id);
    HapticService.selection();
  }

  /// Deletes a saved trip only — the active shopping list is untouched.
  void delete(int id) {
    lists.removeWhere((e) => e.id == id);
    _persist();
    HapticService.delete();
  }

  // ---------- Editing items inside a saved list ----------

  void addSavedItem(int listId, String name, double? quantity, String? unit) {
    final list = byId(listId);
    final trimmed = name.trim();
    if (list == null || trimmed.isEmpty) return;
    list.items.add(ShoppingItem(
      id: _nextItemId(list.items),
      name: trimmed,
      quantity: quantity,
      unit: unit,
      sortOrder: list.items.length,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    _touch(listId);
    HapticService.success();
  }

  void updateSavedItem(
    int listId,
    int itemId,
    String name,
    double? quantity,
    String? unit,
  ) {
    final item = _savedItem(listId, itemId);
    final trimmed = name.trim();
    if (item == null || trimmed.isEmpty) return;
    item.name = trimmed;
    item.quantity = quantity;
    item.unit = unit;
    _touch(listId);
    HapticService.success();
  }

  void removeSavedItem(int listId, int itemId) {
    final list = byId(listId);
    if (list == null) return;
    list.items.removeWhere((e) => e.id == itemId);
    _touch(listId);
    HapticService.delete();
  }

  void duplicateSavedItem(int listId, int itemId) {
    final list = byId(listId);
    final source = _savedItem(listId, itemId);
    if (list == null || source == null) return;
    list.items.insert(
      list.items.indexOf(source) + 1,
      ShoppingItem(
        id: _nextItemId(list.items),
        name: source.name,
        quantity: source.quantity,
        unit: source.unit,
        sortOrder: list.items.length,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _touch(listId);
  }

  void toggleSavedItemPurchased(int listId, int itemId) {
    final item = _savedItem(listId, itemId);
    if (item == null) return;
    item.isPurchased = !item.isPurchased;
    _touch(listId);
    HapticService.lightTap();
  }

  void clearSavedPurchased(int listId) {
    final list = byId(listId);
    if (list == null) return;
    list.items.removeWhere((e) => e.isPurchased);
    _touch(listId);
    HapticService.delete();
  }

  ShoppingItem? _savedItem(int listId, int itemId) => byId(listId)
      ?.items
      .where((e) => e.id == itemId)
      .firstOrNull;

  /// Item ids only need to be unique inside one saved list.
  int _nextItemId(List<ShoppingItem> items) =>
      items.fold<int>(0, (max, e) => e.id > max ? e.id : max) + 1;

  /// Repaints the lists and writes them through to local storage. [listId]
  /// marks that list as just updated.
  void _touch([int? listId]) {
    if (listId != null) {
      byId(listId)?.updatedAt = DateTime.now().millisecondsSinceEpoch;
    }
    lists.refresh();
    _persist();
  }

  /// Copies a saved trip into the active list as unchecked items. The saved
  /// trip keeps its own data and can be reused any number of times. Returns
  /// how many items were added, or 0 if a reuse is already running.
  int reuse(int id, {bool replace = false}) {
    if (_reuseInProgress) return 0;
    final saved = byId(id);
    if (saved == null) return 0;
    final home = Get.find<HomeController>();
    _reuseInProgress = true;
    try {
      return replace
          ? home.replaceWithSavedItems(saved.items)
          : home.addSavedItems(saved.items);
    } finally {
      _reuseInProgress = false;
    }
  }

  bool get reuseInProgress => _reuseInProgress || reusing.value;
  bool _reuseInProgress = false;

  /// The reuse flow spans one or two dialogs, so the button stays disabled
  /// from the first tap until the flow settles.
  final reusing = false.obs;

  bool tryBeginReuse() {
    if (reusing.value) return false;
    reusing.value = true;
    return true;
  }

  void endReuse() => reusing.value = false;

  void _persist() => _repo.save(lists);
}

/// Points the shared item form, item row and delete confirmation at one saved
/// list instead of the active shopping list.
class SavedListWriter implements ItemWriter {
  final int listId;
  final PreviousListController _lists;

  SavedListWriter(this.listId, {PreviousListController? controller})
      : _lists = controller ?? Get.find<PreviousListController>();

  @override
  void addItem(String name, double? quantity, String? unit) =>
      _lists.addSavedItem(listId, name, quantity, unit);

  @override
  void updateItem(int id, String name, double? quantity, String? unit) =>
      _lists.updateSavedItem(listId, id, name, quantity, unit);

  @override
  void deleteItem(int id) => _lists.removeSavedItem(listId, id);

  @override
  void duplicateItem(int id) => _lists.duplicateSavedItem(listId, id);

  @override
  void togglePurchased(int id) => _lists.toggleSavedItemPurchased(listId, id);

  @override
  void clearPurchased() => _lists.clearSavedPurchased(listId);

  @override
  String get listLabel => '"${_lists.byId(listId)?.name ?? 'this list'}"';
}
