import 'package:flutter/material.dart';

import '../../../core/writers/item_writer.dart';
import '../../../data/models/saved_list.dart';
import '../../../theme/app_theme.dart';
import '../../home/widgets/clear_purchased_dialog.dart';
import 'previous_list_dialogs.dart';

/// Rename/delete menu for a list. Used on the list card and on the detail app
/// bar; [afterDelete] lets the detail screen pop back once its subject is
/// gone. Passing a [writer] also offers "Clear purchased" for that list.
class SavedListMenu extends StatelessWidget {
  final SavedList list;
  final VoidCallback? afterDelete;
  final ItemWriter? writer;

  const SavedListMenu({
    super.key,
    required this.list,
    this.afterDelete,
    this.writer,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return PopupMenuButton<String>(
      color: t.surface,
      icon: Icon(Icons.more_vert, size: 22, color: t.textSecondary),
      onSelected: (value) {
        switch (value) {
          case 'rename':
            PreviousListDialogs.rename(context, list);
          case 'clear':
            ClearPurchasedDialog.confirm(
              context,
              writer: writer,
              listLabel: '"${list.name}"',
            );
          case 'delete':
            PreviousListDialogs.confirmDelete(
              context,
              list,
              afterDelete: afterDelete,
            );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'rename',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.drive_file_rename_outline, size: 20),
            title: const Text('Rename list'),
          ),
        ),
        if (writer != null && list.purchasedCount > 0)
          PopupMenuItem(
            value: 'clear',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.clear_all, size: 20),
              title: Text('Clear purchased (${list.purchasedCount})'),
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, size: 20, color: t.destructive),
            title: Text('Delete list', style: TextStyle(color: t.destructive)),
          ),
        ),
      ],
    );
  }
}
