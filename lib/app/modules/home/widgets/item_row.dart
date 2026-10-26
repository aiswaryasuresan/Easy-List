import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/writers/item_writer.dart';
import '../../../data/models/shopping_item.dart';
import '../../item_form/item_form_sheet.dart';
import '../../../theme/app_theme.dart';
import '../home_controller.dart';
import 'item_options_sheet.dart';

class ItemRow extends StatelessWidget {
  final ShoppingItem item;
  final ItemWriter? writer;

  const ItemRow({super.key, required this.item, this.writer});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final controller = writer ?? Get.find<HomeController>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isPurchased ? t.lightSage : t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Checkbox(
              value: item.isPurchased,
              onChanged: (_) => controller.togglePurchased(item.id),
              activeColor: t.primary,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              side: BorderSide(color: t.divider, width: 1.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: item.isPurchased ? 0.55 : 1,
              child: SizedBox(
                width: 34,
                child: Center(
                  child: Text(productIconFor(item.name),
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: item.isPurchased
                          ? t.textSecondary
                          : t.textPrimary,
                      decoration: item.isPurchased
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (item.quantityLabel.isNotEmpty)
                    Text(
                      item.quantityLabel,
                      style: TextStyle(
                          fontSize: 13, color: t.textSecondary),
                    ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 22, color: t.textSecondary),
            color: t.surface,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  ItemFormSheet.showEdit(item, writer: writer);
                case 'duplicate':
                  controller.duplicateItem(item.id);
                case 'delete':
                  ItemOptionsSheet.confirmDelete(context, item,
                      writer: writer);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined, size: 20),
                      title: Text('Edit item'))),
              const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.copy, size: 20),
                      title: Text('Duplicate item'))),
              PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline,
                          size: 20, color: t.destructive),
                      title: Text('Delete item',
                          style: TextStyle(color: t.destructive)))),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
