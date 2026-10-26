import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_list/app/core/app_info.dart';
import 'package:shopping_list/app/modules/about/about_view.dart';
import 'package:shopping_list/app/modules/home/home_controller.dart';
import 'package:shopping_list/app/modules/home/home_view.dart';
import 'package:shopping_list/app/modules/legal/legal_pages.dart';
import 'package:shopping_list/app/modules/previous_lists/previous_list_controller.dart';
import 'package:shopping_list/app/modules/settings/settings_controller.dart';
import 'package:shopping_list/app/theme/app_theme.dart';

HomeController get home => Get.find<HomeController>();

const drawerRows = [
  'Lists',
  'Share App',
  'Settings',
  'About',
  'Privacy Policy',
  'Terms and Conditions',
];

void main() {
  late GetStorage box;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('shopping_list_drawer');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => dir.path,
    );
    box = GetStorage();
    await box.initStorage;
  });

  setUp(() async {
    Get.reset();
    await box.erase();
    final controller = Get.put(HomeController());
    controller.onInit();
    Get.put(PreviousListController());
    final settings = Get.put(SettingsController());
    settings.onInit();
  });

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const HomeView()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
  }

  Future<void> tapRow(WidgetTester tester, String label) async {
    await tester.tap(find.descendant(
      of: find.byType(Drawer),
      matching: find.text(label),
    ));
    await tester.pumpAndSettle();
  }

  List<String> rowLabels(WidgetTester tester) => tester
      .widgetList<Text>(find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Text),
      ))
      .map((e) => e.data ?? '')
      .where(drawerRows.contains)
      .toList();

  testWidgets('shows the header and every row in the agreed order',
      (tester) async {
    await openDrawer(tester);

    expect(find.text('Easy List'), findsOneWidget);
    expect(find.text('Plan smarter. Shop easier.'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(rowLabels(tester), drawerRows);
    // Retired entries must not come back.
    expect(find.text('Previous Lists'), findsNothing);
    expect(find.text('Help & Feedback'), findsNothing);
  });

  testWidgets('the close button dismisses the drawer', (tester) async {
    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    expect(home.tab.value, 0);
  });

  testWidgets('Create New List opens the custom lists screen', (tester) async {
    await openDrawer(tester);
    await tapRow(tester, 'Lists');

    expect(home.tab.value, 3);
    expect(find.text('No lists yet'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets('the open tab is the row highlighted in sage', (tester) async {
    await openDrawer(tester);

    final t = AppTokens.of(tester.element(
      find.descendant(of: find.byType(Drawer), matching: find.text('Share App')),
    ));
    Finder highlighted() => find.descendant(
          of: find.byType(Drawer),
          matching: find.byWidgetPredicate(
            (widget) => widget is Material && widget.color == t.lightSage,
          ),
        );

    // The List tab owns no drawer row, so nothing is lit up.
    expect(highlighted(), findsNothing);

    home.tab.value = 3;
    await tester.pumpAndSettle();

    // Exactly one row carries the selection, and it is the open tab.
    expect(highlighted(), findsOneWidget);
  });

  testWidgets('Settings opens the existing settings screen', (tester) async {
    await openDrawer(tester);
    await tapRow(tester, 'Settings');

    expect(home.tab.value, 1);
    expect(find.text('App Theme'), findsOneWidget);
    expect(find.text('Clear Purchased Items'), findsOneWidget);
  });

  testWidgets('About shows the logo, name, description and version',
      (tester) async {
    await openDrawer(tester);
    await tapRow(tester, 'About');

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Easy List'), findsOneWidget);
    expect(
      find.text('A simple way to organize your shopping lists.'),
      findsOneWidget,
    );
    expect(find.text('Version ${AppInfo.versionName} (${AppInfo.buildNumber})'),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('Privacy Policy opens the in-app policy', (tester) async {
    await openDrawer(tester);
    await tapRow(tester, 'Privacy Policy');

    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(find.text('Data we do not collect'), findsOneWidget);
  });

  testWidgets('Terms and Conditions opens the in-app terms', (tester) async {
    await openDrawer(tester);
    await tapRow(tester, 'Terms and Conditions');

    expect(find.byType(TermsPage), findsOneWidget);
    expect(find.text('No warranty'), findsOneWidget);
  });

  testWidgets('Share App closes the drawer and survives a missing host',
      (tester) async {
    await openDrawer(tester);
    await tapRow(tester, 'Share App');

    // No share sheet exists in a widget test; the row must still close the
    // drawer and stay quiet rather than throwing.
    expect(find.byType(Drawer), findsNothing);
    expect(home.tab.value, 0);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('the app share text carries the name and the Play listing', () {
    expect(AppInfo.shareText, startsWith('Easy List'));
    expect(AppInfo.shareText, contains(AppInfo.description));
    // The id has to match android/app/build.gradle.kts applicationId.
    expect(
      AppInfo.shareText,
      contains(
        'https://play.google.com/store/apps/details?id=com.shopinglist2026.app',
      ),
    );
  });
}
