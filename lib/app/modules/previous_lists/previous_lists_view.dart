import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';
import '../../data/models/saved_list.dart';
import '../../theme/app_theme.dart';
import 'previous_list_controller.dart';
import 'previous_list_detail_view.dart';
import 'widgets/previous_list_dialogs.dart';
import 'widgets/saved_list_menu.dart';

/// Tab body for the bottom-nav "Create Lists" entry: every custom list the
/// user made, each one edited on its own.
class PreviousListsView extends GetView<PreviousListController> {
  const PreviousListsView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Create Lists',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              'Your own shopping lists. Tap one to add, edit or reuse its items.',
              style: TextStyle(fontSize: 13, color: t.textSecondary),
            ),
          ),
          Expanded(
            child: Obx(() {
              final lists = controller.lists.toList();
              if (lists.isEmpty) return const _NoListsYet();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: lists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) => _SavedListCard(list: lists[index]),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () => PreviousListDialogs.createNewList(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New List'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => PreviousListDialogs.saveCurrentList(context),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Current'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: t.primaryDark,
                      side: BorderSide(color: t.primary, width: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedListCard extends StatelessWidget {
  final SavedList list;

  const _SavedListCard({required this.list});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final itemCount = list.items.length;
    final preview = list.items.take(3).map((e) => e.name).join(', ');
    final remaining = itemCount - 3;
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(() => PreviousListDetailView(listId: list.id));
          HapticService.selection();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: t.lightSage,
                child: Icon(Icons.list_alt, color: t.primaryDark, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}'
                      '${list.purchasedCount > 0 ? ' • ${list.purchasedCount} purchased' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: t.textSecondary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Updated ${formatSavedListDate(list.updatedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: t.textSecondary),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        remaining > 0 ? '$preview +$remaining more' : preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5, color: t.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              SavedListMenu(list: list),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoListsYet extends StatelessWidget {
  const _NoListsYet();

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
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 14),
            const Text(
              'No lists yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create New List starts an empty list you can fill in, or save '
              'the items on your List screen with Save Current.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: t.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
