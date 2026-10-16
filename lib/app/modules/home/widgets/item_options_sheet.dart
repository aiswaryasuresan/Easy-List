import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/haptic_service.dart';
import '../../../data/models/shopping_item.dart';
import '../../../theme/app_theme.dart';
import '../../item_form/item_form_sheet.dart';
import '../home_controller.dart';

class ItemOptionsSheet {
  static Future<void> show(BuildContext context, ShoppingItem item) async {
    final t = AppTokens.of(context);
    final controller = Get.find<HomeController>();
    await Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: t.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(productIconFor(item.name),
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                            if (item.quantityLabel.isNotEmpty)
                              Text(
                                item.quantityLabel,
                                style: TextStyle(
                                    fontSize: 13, color: t.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),//--
                  const Divider(),
                  _OptionTile(
                    icon: Icons.edit_outlined,
                    label: 'Edit item',
                    onTap: () {
                      Get.back();
                      ItemFormSheet.showEdit(item);
                    },
                  ),
                  _OptionTile(
                    icon: Icons.copy,
                    label: 'Duplicate item',
                    onTap: () {
                      Get.back();
                      controller.duplicateItem(item.id);
                    },
                  ),
                  _OptionTile(
                    icon: Icons.delete_outline,
                    label: 'Delete item',
                    color: t.destructive,
                    onTap: () {
                      Get.back();
                      confirmDelete(context, item);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: t.chipBackground,
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: t.textPrimary,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> confirmDelete(
      BuildContext context, ShoppingItem item) async {
    final t = AppTokens.of(context);
    final controller = Get.find<HomeController>();
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          backgroundColor: t.destructiveBackground,
          child: Icon(Icons.delete_outline, color: t.destructive),
        ),
        title: const Text('Delete item?', textAlign: TextAlign.center),
        content: Text(
          '"${item.name}" will be removed from your list.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticService.delete();
              controller.deleteItem(item.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: t.destructive,
              minimumSize: const Size(96, 44),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final effectiveColor = color ?? t.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(fontSize: 15, color: effectiveColor)),
          ],
        ),
      ),
    );
  }
}
