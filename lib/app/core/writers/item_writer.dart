/// Target that item add/edit/delete/purchase actions write to. The active
/// shopping list and a saved list both implement it, so the item form and
/// item row stay single-sourced.
abstract class ItemWriter {
  void addItem(String name, double? quantity, String? unit);
  void updateItem(int id, String name, double? quantity, String? unit);
  void deleteItem(int id);
  void duplicateItem(int id);
  void togglePurchased(int id);

  /// Removes every purchased item from this list.
  void clearPurchased();

  /// How confirmation copy refers to this list, e.g. `your shopping list`.
  String get listLabel;
}
