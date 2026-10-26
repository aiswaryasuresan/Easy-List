import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_info.dart';
import '../../../core/services/haptic_service.dart';
import '../../../theme/app_theme.dart';
import '../../about/about_view.dart';
import '../../legal/legal_pages.dart';
import '../home_controller.dart';

/// The app's only navigation menu: the shopping list itself stays on the bottom
/// bar, everything else starts here.
class AppDrawer extends GetView<HomeController> {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Drawer(
      backgroundColor: t.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                        onPressed: () => Scaffold.of(context).closeDrawer(),
                        icon: const Icon(Icons.close),
                        color: t.textPrimary,
                        tooltip: 'Close menu',
                      ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 6, 12),
              child: Image.asset(
                'assets/illustrations/splash_basket.png',
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.1,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 6, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppInfo.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: t.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppInfo.tagline,
                    style: TextStyle(fontSize: 13, color: t.textSecondary),
                  ),
                ],
              ),
            ),

            Divider(color: t.divider, height: 1),
            Expanded(
              child: Obx(() {
                // The tab the home Scaffold is showing, so its row can light up.
                final tab = controller.tab.value;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  children: [
                    _DrawerTile(
                      icon: Icons.add_circle_outline,
                      label: 'Lists',
                      selected: tab == 3,
                      onTap: () => _goTab(context, 3),
                    ),
                    _DrawerTile(
                      icon: Icons.ios_share,
                      label: 'Share App',
                      onTap: () => _shareApp(context),
                    ),
                    _DrawerTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      selected: tab == 1,
                      onTap: () => _goTab(context, 1),
                    ),
                    _DrawerTile(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () => _open(context, const AboutPage()),
                    ),
                    _DrawerTile(
                      icon: Icons.shield_outlined,
                      label: 'Privacy Policy',
                      onTap: () => _open(context, const PrivacyPolicyPage()),
                    ),
                    _DrawerTile(
                      icon: Icons.description_outlined,
                      label: 'Terms and Conditions',
                      onTap: () => _open(context, const TermsPage()),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _goTab(BuildContext context, int tab) {
    Scaffold.of(context).closeDrawer();
    controller.tab.value = tab;
    HapticService.selection();
  }

  void _open(BuildContext context, Widget page) {
    Scaffold.of(context).closeDrawer();
    HapticService.selection();
    Get.to(() => page);
  }

  Future<void> _shareApp(BuildContext context) async {
    Scaffold.of(context).closeDrawer();
    HapticService.selection();
    final t = AppTokens.of(context);
    try {
      await SharePlus.instance.share(ShareParams(text: AppInfo.shareText));
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
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? t.lightSage : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(icon, size: 22, color: t.primaryDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? t.primaryDark : t.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
