import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/haptic_service.dart';
import '../../data/models/shopping_item.dart';
import '../../theme/app_theme.dart';
import '../home/home_controller.dart';

/// The home list has no stored name of its own, so shared text carries this.
const activeListTitle = 'My Shopping List';

class SharePage extends GetView<HomeController> {
  const SharePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    controller.tab.value = 0;
                    HapticService.selection();
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: t.textPrimary,
                ),
                Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: t.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeListTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Send a snapshot of your list to anyone.',
                  style: TextStyle(fontSize: 13, color: t.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final items = controller.items.toList();
              if (items.isEmpty) return const _ShareEmptyState();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (i == items.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        '${items.length} '
                        '${items.length == 1 ? 'item' : 'items'} • '
                        '${items.where((e) => e.isPurchased).length} purchased',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: t.textSecondary,
                        ),
                      ),
                    );
                  }
                  return _ShareItemCard(item: items[i]);
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Obx(() {
              final hasItems = controller.items.isNotEmpty;
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      onPressed: hasItems ? () => _share(context) : null,
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Share via App'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: hasItems
                          ? () => _copyToClipboard(context)
                          : null,
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: t.primaryDark,
                        side: BorderSide(color: t.primary),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final t = AppTokens.of(context);
    final text = buildShareText(controller.items);
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      final result = await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: origin),
      );
      if (result.status == ShareResultStatus.success) {
        HapticService.success();
      }
    } catch (e) {
      Get.snackbar(
        'Sharing failed',
        'Could not open the share sheet. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: t.destructiveBackground,
        colorText: t.destructive,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final t = AppTokens.of(context);
    await Clipboard.setData(
      ClipboardData(text: buildShareText(controller.items)),
    );
    HapticService.success();
    Get.snackbar(
      'Copied',
      'Your list is on the clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: t.lightSage,
      colorText: t.primaryDark,
      margin: const EdgeInsets.all(12),
    );
  }
}

/// Plain-text form of [items]: a title, then one numbered line per item with
/// its quantity and unit, and a tick for anything already bought.
String buildShareText(
  List<ShoppingItem> items, {
  String title = activeListTitle,
}) {
  final buffer = StringBuffer('$title\n\n');
  var number = 1;
  for (final item in items) {
    buffer.write('$number. ${item.name}');
    final label = item.quantityLabel;
    if (label.isNotEmpty) buffer.write(' — $label');
    if (item.isPurchased) buffer.write(' ✓');
    buffer.write('\n');
    number++;
  }
  return buffer.toString();
}

class _ShareItemCard extends StatelessWidget {
  final ShoppingItem item;

  const _ShareItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final label = item.quantityLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.divider),
      ),
      child: Row(
        children: [
          Text(productIconFor(item.name), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: t.textPrimary,
                decoration: item.isPurchased
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: t.textSecondary,
              ),
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(fontSize: 13.5, color: t.textSecondary),
            ),
          if (item.isPurchased) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, size: 18, color: t.primary),
          ],
        ],
      ),
    );
  }
}

class _ShareEmptyState extends StatelessWidget {
  const _ShareEmptyState();

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
              'Nothing to share yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items on the List tab and they will appear here, '
              'ready to share.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: t.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
