import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item_form/item_form_sheet.dart';
import '../previous_lists/previous_lists_view.dart';
import '../previous_lists/widgets/previous_list_dialogs.dart';
import '../settings/settings_controller.dart';
import '../share/share_view.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/item_filter_chips.dart';
import '../../core/widgets/tap_pulse.dart';
import '../../data/default_product_catalog.dart';
import '../../theme/app_theme.dart';
import 'home_controller.dart';
import 'widgets/app_drawer.dart';
import 'widgets/clear_purchased_dialog.dart';
import 'widgets/item_row.dart';

final GlobalKey<ScaffoldState> _homeScaffoldKey = GlobalKey<ScaffoldState>();

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Scaffold(
      key: _homeScaffoldKey,
      backgroundColor: t.background,
      drawer: const AppDrawer(),
      // The docked Add button hangs into the body, so keep content clear of it.
      body: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Obx(
          () => switch (controller.tab.value) {
            1 => const _SettingsPage(),
            2 => const SharePage(),
            3 => const PreviousListsView(),
            _ => Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _LeafBackground(
                    leafColor: t.lightSage,
                    softLeafColor: t.lightSage.withValues(alpha: 0.45),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _homeScaffoldKey.currentState?.openDrawer();
                                HapticService.selection();
                              },
                              icon: const Icon(Icons.menu),
                              color: t.textPrimary,
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  controller.searchFocus.requestFocus(),
                              icon: const Icon(Icons.search),
                              color: t.textPrimary,
                            ),
                            _ListMenuButton(icon: Icons.more_vert),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shopping List',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: t.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Let's get what you need ✨",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: t.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/illustrations/splash_basket.png',
                              width: 84,
                              height: 84,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _SearchPill(),
                      ),
                      Obx(() {
                        if (!controller.showSuggestions) {
                          return const SizedBox.shrink();
                        }
                        return Flexible(
                          child: _SuggestionsPanel(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: _FilterChips(controller: controller),
                      ),
                      Expanded(
                        child: Obx(() {
                          if (controller.isEmpty) {
                            return CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: const _EmptyState(),
                                ),
                              ],
                            );
                          }
                          return _FilteredList(
                            controller: controller,
                            onClear: () =>
                                ClearPurchasedDialog.confirm(context),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            HapticService.selection();
            PreviousListDialogs.createNewList(context);
          },
          shape: const CircleBorder(),
          backgroundColor: t.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          tooltip: 'Create New List',
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _ListMenuButton extends GetView<HomeController> {
  final IconData icon;

  const _ListMenuButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return PopupMenuButton<String>(
      color: t.surface,
      icon: Icon(icon, color: t.textPrimary),
      onSelected: (value) {
        switch (value) {
          case 'finish':
            PreviousListDialogs.finishShopping(context);
          case 'clear':
            ClearPurchasedDialog.confirm(context);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'finish',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline, size: 20),
            title: const Text('Finish shopping'),
          ),
        ),
        if (controller.hasPurchased)
          PopupMenuItem(
            value: 'clear',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_outline,
                size: 20,
                color: t.destructive,
              ),
              title: Text(
                'Clear purchased items',
                style: TextStyle(color: t.destructive),
              ),
            ),
          )
        else
          const PopupMenuItem(
            enabled: false,
            child: Text('No purchased items to clear'),
          ),
      ],
    );
  }
}

class _SearchPill extends GetView<HomeController> {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        SizedBox(
          height: 56,
          child: Material(
            color: t.surface,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.only(left: 18, right: 70),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: t.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      focusNode: controller.searchFocus,
                      controller: controller.searchController,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(fontSize: 14),
                      onChanged: (v) => controller.query.value = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'Add an item...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: t.textSecondary,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -4,
          child: TapPulse(
            onTap: () {
              controller.searchFocus.unfocus();
              ItemFormSheet.showAdd();
            },
            child: Material(
              color: t.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionsPanel extends GetView<HomeController> {
  final double maxHeight;

  const _SuggestionsPanel({required this.maxHeight});

  void _select(AppTokens t, ProductSuggestion s) {
    controller.searchFocus.unfocus();
    final block = controller.blockReasonFor(s);
    if (block != null) {
      Get.snackbar(
        'Duplicate item',
        '"${s.name}" is already on your list.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: t.destructiveBackground,
        colorText: t.destructive,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    ItemFormSheet.showAdd(name: s.name, unit: s.unit);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final q = controller.query.value.trim();
    final suggestions = controller.suggestionsFor(q);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      constraints: BoxConstraints(maxHeight: maxHeight),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: suggestions.isEmpty
          ? _AddCustomTile(query: q, onTap: () => _addCustom(t))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: t.divider),
                    itemBuilder: (_, i) {
                      final s = suggestions[i];
                      return ListTile(
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -2,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: t.lightSage,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            s.fromHistory
                                ? Icons.history
                                : categoryIconFor(s.category),
                            size: 18,
                            color: t.primaryDark,
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: t.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          s.category,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: t.textSecondary,
                          ),
                        ),
                        onTap: () => _select(t, s),
                      );
                    },
                  ),
                ),
                Divider(height: 1, color: t.divider),
                _AddCustomTile(query: q, onTap: () => _addCustom(t)),
              ],
            ),
    );
  }

  void _addCustom(AppTokens t) {
    final q = controller.query.value.trim();
    controller.searchFocus.unfocus();
    ItemFormSheet.showAdd(name: q);
  }
}

class _AddCustomTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const _AddCustomTile({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: const Icon(Icons.add_circle_outline, size: 22),
      title: Text(
        'Add "$query"',
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: t.primaryDark,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _FilterChips extends StatelessWidget {
  final HomeController controller;

  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ItemFilterChips(
        labels: [
          'All (${controller.items.length})',
          'To Buy (${controller.remainingCount})',
          'Purchased (${controller.items.where((e) => e.isPurchased).length})',
        ],
        selected: controller.filter.value,
        onChanged: (index) => controller.filter.value = index,
      );
    });
  }
}

class _FilteredList extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onClear;

  const _FilteredList({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.filter.value) {
        case 1:
          final pending = controller.pendingItems;
          if (pending.isEmpty) {
            return const _NoItemsHint('Nothing left to buy.');
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: pending.map((item) => ItemRow(item: item)).toList(),
          );
        case 2:
          final purchased = controller.purchasedItems;
          if (purchased.isEmpty) {
            return const _NoItemsHint(
              'No purchased items yet.\nCheck off an item to move it here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: [
              ...purchased.map((item) => ItemRow(item: item)),
              const SizedBox(height: 4),
              _ClearButton(onClear: onClear),
            ],
          );
        default:
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: [
              ...controller.pendingItems.map((item) => ItemRow(item: item)),
              if (controller.hasPurchased) _PurchasedSection(onClear: onClear),
            ],
          );
      }
    });
  }
}

class _NoItemsHint extends StatelessWidget {
  final String message;

  const _NoItemsHint(this.message);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: constraints.maxHeight,
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: t.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onClear;

  const _ClearButton({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return OutlinedButton.icon(
      onPressed: onClear,
      icon: Icon(Icons.delete_outline, size: 20, color: t.destructive),
      label: Text(
        'Clear purchased items',
        style: TextStyle(color: t.destructive),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: t.destructiveBackground,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _PurchasedSection extends GetView<HomeController> {
  final VoidCallback onClear;

  const _PurchasedSection({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => controller.purchasedSectionExpanded.toggle(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: t.beige,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Obx(
                  () => Text(
                    'Purchased (${controller.purchasedItems.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Icon(
                    controller.purchasedSectionExpanded.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => controller.purchasedSectionExpanded.value
              ? Column(
                  children: [
                    ...controller.purchasedItems.map(
                      (item) => ItemRow(item: item),
                    ),
                    const SizedBox(height: 4),
                    _ClearButton(onClear: onClear),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SettingsPage extends GetView<HomeController> {
  const _SettingsPage();

  SettingsController get _settings => Get.find<SettingsController>();

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
                  onPressed: () => controller.tab.value = 0,
                  icon: const Icon(Icons.arrow_back),
                  color: t.textPrimary,
                ),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                Obx(
                  () => Column(
                    children: [
                      _SettingsTile(
                        icon: _settings.isDark.value
                            ? Icons.dark_mode
                            : Icons.brightness_6,
                        iconColor: t.textPrimary,
                        title: 'App Theme',
                        subtitle: _settings.isDark.value ? 'Dark' : 'Light',
                        showChevron: true,
                        onTap: () => _settings.toggleTheme(),
                      ),
                      // _SettingsTile(
                      //   icon: Icons.volume_up,
                      //   iconColor: t.textPrimary,
                      //   title: 'Haptic Feedback',
                      //   trailingSwitch: true,
                      //   switchValue: _settings.hapticsEnabled.value,
                      //   onSwitch: _settings.setHaptics,
                      // ),
                      _SettingsTile(
                        icon: Icons.delete_outline,
                        iconColor: t.destructive,
                        title: 'Clear Purchased Items',
                        showChevron: true,
                        onTap: () => ClearPurchasedDialog.confirm(context),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                //   child: Text(
                //     'Appearance',
                //     style: TextStyle(
                //       fontSize: 15,
                //       fontWeight: FontWeight.w600,
                //       color: t.textPrimary,
                //     ),
                //   ),
                // ),
                // Obx(
                //   () => _AppearanceSegment(
                //     isDark: _settings.isDark.value,
                //     onSelect: _settings.setDark,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool showChevron;
  final bool trailingSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitch;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.showChevron = false,
    this.trailingSwitch = false,
    this.switchValue = false,
    this.onSwitch,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: t.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.divider),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.only(
            left: 14,
            right: showChevron ? 6 : 14,
          ),
          leading: Icon(icon, size: 24, color: iconColor),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: TextStyle(fontSize: 12.5, color: t.textSecondary),
                ),
          trailing: trailingSwitch
              ? Switch(
                  value: switchValue,
                  activeThumbColor: Colors.white,
                  activeTrackColor: t.primary,
                  onChanged: onSwitch,
                )
              : showChevron
              ? Icon(Icons.chevron_right, color: t.textSecondary)
              : null,
        ),
      ),
    );
  }
}

// Kept for the commented-out Appearance section above.
// ignore: unused_element
class _AppearanceSegment extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onSelect;

  const _AppearanceSegment({required this.isDark, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(t, 'Light', !isDark, () => onSelect(false))),
          Expanded(child: _segment(t, 'Dark', isDark, () => onSelect(true))),
        ],
      ),
    );
  }

  Widget _segment(
    AppTokens t,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Material(
      color: selected ? t.primaryDark : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: selected
                  ? (t.primaryDark.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : t.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends GetView<HomeController> {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return BottomAppBar(
      color: t.surface,
      elevation: 8,
      height: 68,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Obx(() {
        final active = controller.tab.value;
        return Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: active == 0,
                onTap: () => _go(tab: 0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.ios_share,
                label: 'Share',
                selected: active == 2,
                onTap: () => _go(tab: 2),
              ),
            ),
            // Left open for the docked Add button.
            const Expanded(child: SizedBox()),
            Expanded(
              child: _NavItem(
                icon: Icons.save_outlined,
                label: 'Save',
                onTap: () {
                  HapticService.selection();
                  PreviousListDialogs.saveCurrentList(context);
                },
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: active == 1,
                onTap: () => _go(tab: 1),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _go({required int tab}) {
    controller.tab.value = tab;
    HapticService.selection();
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final color = selected ? t.primaryDark : t.textSecondary;
    return Material(
      color: selected ? t.lightSage : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeafBackground extends StatelessWidget {
  final Color leafColor;
  final Color softLeafColor;

  const _LeafBackground({required this.leafColor, required this.softLeafColor});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: CustomPaint(
          painter: _LeafPainter(
            leafColor: leafColor,
            softLeafColor: softLeafColor,
          ),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color leafColor;
  final Color softLeafColor;

  _LeafPainter({required this.leafColor, required this.softLeafColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    _leaf(
      canvas,
      center: Offset(w * 0.52, -18),
      length: w * 0.42,
      width: w * 0.16,
      angle: math.pi * 0.56,
      color: leafColor,
    );
    _leaf(
      canvas,
      center: Offset(w * 0.12, 8),
      length: w * 0.30,
      width: w * 0.11,
      angle: math.pi * 0.72,
      color: softLeafColor,
    );
    _leaf(
      canvas,
      center: Offset(w * 0.94, 40),
      length: w * 0.26,
      width: w * 0.10,
      angle: math.pi * 0.35,
      color: leafColor,
    );
  }

  void _leaf(
    Canvas canvas, {
    required Offset center,
    required double length,
    required double width,
    required double angle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(-length / 2, 0)
      ..quadraticBezierTo(0, -width, length / 2, 0)
      ..quadraticBezierTo(0, width, -length / 2, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.leafColor != leafColor ||
      oldDelegate.softLeafColor != softLeafColor;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/illustrations/grocery_bag.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your list is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items whenever you remember something to buy.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: t.textSecondary),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => ItemFormSheet.showAdd(),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}
