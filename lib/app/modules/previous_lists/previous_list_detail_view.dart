import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/item_filter_chips.dart';
import '../../data/models/saved_list.dart';
import '../../data/models/shopping_item.dart';
import '../../theme/app_theme.dart';
import '../home/widgets/item_row.dart';
import '../item_form/item_form_sheet.dart';
import 'previous_list_controller.dart';
import 'widgets/previous_list_dialogs.dart';
import 'widgets/saved_list_menu.dart';

/// One custom list. Its items are edited here through the same rows and form
/// the main List uses, and the All / To Buy / Purchased filter belongs to this
/// screen only, so no list shares another's state.
class PreviousListDetailView extends StatefulWidget {
  final int listId;

  const PreviousListDetailView({super.key, required this.listId});

  @override
  State<PreviousListDetailView> createState() => _PreviousListDetailState();
}

class _PreviousListDetailState extends State<PreviousListDetailView> {
  // 0 = All, 1 = To Buy, 2 = Purchased
  int _filter = 0;

  /// Every write from this screen goes to this one list only.
  late final SavedListWriter _writer = SavedListWriter(widget.listId);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final controller = Get.find<PreviousListController>();
    final listId = widget.listId;
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Obx(() => Text(
              controller.byId(listId)?.name ?? 'List',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        actions: [
          Obx(() {
            final list = controller.byId(listId);
            if (list == null) return const SizedBox.shrink();
            return SavedListMenu(
              list: list,
              writer: _writer,
              afterDelete: () => Get.back(),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.byId(listId) == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => ItemFormSheet.showAdd(writer: _writer),
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        );
      }),
      body: SafeArea(
        child: Obx(() {
          final list = controller.byId(listId);
          if (list == null) return const _ListGoneHint();
          final items = list.items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  'Created ${formatSavedListDate(list.createdAt)}\n'
                  'Updated ${formatSavedListDate(list.updatedAt)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: t.textSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: items.isEmpty
                    ? const SizedBox.shrink()
                    : ItemFilterChips(
                        labels: [
                          'All (${items.length})',
                          'To Buy (${list.remainingCount})',
                          'Purchased (${list.purchasedCount})',
                        ],
                        selected: _filter,
                        onChanged: (index) => setState(() => _filter = index),
                      ),
              ),
              Expanded(
                child: _buildBody(list),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: FilledButton.icon(
                  onPressed: items.isEmpty || controller.reusing.value
                      ? null
                      : () => PreviousListDialogs.confirmReuse(context, list),
                  icon: const Icon(Icons.replay),
                  label: const Text('Reuse This List'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody(SavedList list) {
    final items = _visible(list.items);
    if (list.items.isEmpty) return const _EmptyItemsHint();
    if (items.isEmpty) return _NoMatchingItems(_filter);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: items.length,
      itemBuilder: (_, index) => ItemRow(item: items[index], writer: _writer),
    );
  }

  List<ShoppingItem> _visible(List<ShoppingItem> source) => switch (_filter) {
        1 => source.where((e) => !e.isPurchased).toList(),
        2 => source.where((e) => e.isPurchased).toList(),
        _ => source.toList(),
      };
}

class _NoMatchingItems extends StatelessWidget {
  final int filter;

  const _NoMatchingItems(this.filter);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Center(
      child: Text(
        filter == 1 ? 'Nothing left to buy.' : 'Nothing purchased yet.',
        style: TextStyle(fontSize: 14, color: t.textSecondary),
      ),
    );
  }
}

class _EmptyItemsHint extends StatelessWidget {
  const _EmptyItemsHint();

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/illustrations/grocery_bag.png',
              width: 96,
              height: 96,
            ),
            const SizedBox(height: 12),
            const Text(
              'No items yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Use "Add item" to fill this list, then reuse it whenever you '
              'shop for the same things.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: t.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListGoneHint extends StatelessWidget {
  const _ListGoneHint();

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'This list is no longer available.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: t.textSecondary),
        ),
      ),
    );
  }
}
