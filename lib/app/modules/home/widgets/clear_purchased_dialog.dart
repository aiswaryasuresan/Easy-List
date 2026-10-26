import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/writers/item_writer.dart';
import '../../../theme/app_theme.dart';
import '../home_controller.dart';

class ClearPurchasedDialog {
  /// Clears purchased items from [writer]'s list, defaulting to the main
  /// shopping list.
  static Future<void> confirm(
    BuildContext context, {
    ItemWriter? writer,
    String listLabel = 'your list',
  }) async {
    final t = AppTokens.of(context);
    final controller = writer ?? Get.find<HomeController>();
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          backgroundColor: t.destructiveBackground,
          child: Icon(Icons.delete_outline, color: t.destructive),
        ),
        title: const Text('Clear purchased items?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        content: Text(
          'This will remove all purchased items from $listLabel. '
          'This action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actionsPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: t.chipBackground,
                    foregroundColor: t.textPrimary,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    controller.clearPurchased();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: t.destructive,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
