import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_list/app/core/widgets/tap_pulse.dart';
import 'package:shopping_list/app/modules/home/home_controller.dart';
import 'package:shopping_list/app/modules/home/home_view.dart';
import 'package:shopping_list/app/modules/item_form/item_form_sheet.dart';
import 'package:shopping_list/app/modules/previous_lists/previous_list_controller.dart';
import 'package:shopping_list/app/modules/settings/settings_controller.dart';
import 'package:shopping_list/app/modules/share/share_view.dart';
import 'package:shopping_list/app/theme/app_theme.dart';

HomeController get home => Get.find<HomeController>();

PreviousListController get previous => Get.find<PreviousListController>();

void main() {
  late GetStorage box;
  String? clipboardText;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('shopping_list_nav');
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
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        });
    final controller = Get.put(HomeController());
    controller.onInit();
    Get.put(PreviousListController());
    final settings = Get.put(SettingsController());
    settings.onInit();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const HomeView()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapNav(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(BottomAppBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dismissSnack(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Finder navText(String label) => find.descendant(
    of: find.byType(BottomAppBar),
    matching: find.text(label),
  );

  // The home screen keeps a search field on screen, so the dialog's own
  // field has to be addressed inside the dialog.
  Finder dialogField() => find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );

  testWidgets('the bar holds the four slots around the centre button', (
    tester,
  ) async {
    await pumpHome(tester);

    final labels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(BottomAppBar),
            matching: find.byType(Text),
          ),
        )
        .map((e) => e.data ?? '')
        .toList();
    expect(labels, ['Home', 'Share', 'Save', 'Settings']);

    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
    );
    // Create Lists now lives in the drawer, not in the bar.
    expect(navText('Create Lists'), findsNothing);
  });

  testWidgets('the centre button is circular and creates a named list', (
    tester,
  ) async {
    await pumpHome(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.shape, isA<CircleBorder>());
    final size = tester.getSize(find.byType(FloatingActionButton));
    expect(size.width, size.height);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(ItemFormSheet), findsNothing);
    expect(find.text('New list'), findsOneWidget);

    await tester.enterText(dialogField(), 'Weekly Grocery');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Create list'));
    await tester.pumpAndSettle();

    expect(previous.lists.single.name, 'Weekly Grocery');
    // The new list opens ready to fill in, and the home list is untouched.
    expect(find.text('No items yet'), findsOneWidget);
    expect(home.items, isEmpty);
  });

  testWidgets('items are still added from the search row', (tester) async {
    await pumpHome(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(TapPulse),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ItemFormSheet), findsOneWidget);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(ItemFormSheet),
            matching: find.byType(TextField),
          )
          .first,
      'Milk',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ItemFormSheet),
        matching: find.widgetWithText(FilledButton, 'Add Item'),
      ),
    );
    await tester.pumpAndSettle();

    expect(home.items.map((e) => e.name).toList(), ['Milk']);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.byType(ItemFormSheet), findsNothing);
  });

  testWidgets('Save names a list without touching the home list', (
    tester,
  ) async {
    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', 1, 'loaf');

    await pumpHome(tester);
    await tapNav(tester, 'Save');

    expect(find.text('Save Current List'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);

    await tester.enterText(dialogField(), 'Weekly Grocery');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save List'));
    await tester.pumpAndSettle();

    expect(previous.lists.single.name, 'Weekly Grocery');
    expect(previous.lists.single.items.map((e) => e.quantityLabel).toList(), [
      '2 L',
      '1 loaf',
    ]);
    expect(home.items, hasLength(2));
    expect(find.text('List saved'), findsOneWidget);
    await dismissSnack(tester);
    expect(home.items, hasLength(2));
  });

  testWidgets('Save refuses a blank and a duplicate name', (tester) async {
    previous.createList('Weekly Grocery');
    home.addItem('Milk', 2, 'L');

    await pumpHome(tester);
    await tapNav(tester, 'Save');

    await tester.enterText(dialogField(), '   ');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save List'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a list name.'), findsOneWidget);

    await tester.enterText(dialogField(), '  weekly grocery  ');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save List'));
    await tester.pumpAndSettle();

    // Case and padding are ignored, and the dialog keeps the typed name.
    expect(find.textContaining('already have a list'), findsOneWidget);
    expect(find.text('Save Current List'), findsOneWidget);
    expect(previous.lists, hasLength(1));

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(previous.lists, hasLength(1));
  });

  testWidgets('Save on an empty list explains itself instead of saving', (
    tester,
  ) async {
    await pumpHome(tester);
    await tapNav(tester, 'Save');

    expect(find.text('Nothing to save'), findsOneWidget);
    expect(find.text('Save Current List'), findsNothing);
    expect(previous.lists, isEmpty);
    await dismissSnack(tester);
  });

  testWidgets('Share previews the real items with both actions', (
    tester,
  ) async {
    home.addItem('Milk', 2, 'L');
    home.addItem('തക്കാളി', 1, 'kg');

    await pumpHome(tester);
    await tapNav(tester, 'Share');

    expect(home.tab.value, 2);
    expect(find.text('My Shopping List'), findsOneWidget);
    expect(find.text('Share via App'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('2 L'), findsOneWidget);
    expect(find.text('തക്കാളി'), findsOneWidget);
  });

  testWidgets('Copy puts the numbered list on the clipboard', (tester) async {
    home.addItem('Rice', 5, 'kg');
    home.addItem('Milk', 2, 'L');

    await pumpHome(tester);
    await tapNav(tester, 'Share');
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(
      clipboardText,
      'My Shopping List\n\n1. Rice — 5 kg\n2. Milk — 2 L\n',
    );
    expect(find.text('Copied'), findsOneWidget);
    await dismissSnack(tester);
  });

  testWidgets('an empty list cannot be shared or copied', (tester) async {
    await pumpHome(tester);
    await tapNav(tester, 'Share');

    expect(find.text('Nothing to share yet'), findsOneWidget);
    final share = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Share via App'),
        matching: find.byType(FilledButton),
      ),
    );
    final copy = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Copy'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(share.onPressed, isNull);
    expect(copy.onPressed, isNull);
  });

  testWidgets('the bar clears the system navigation inset', (tester) async {
    // A gesture-nav bar of 24dp must push the content up, not sit under it.
    tester.view.padding = FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPadding);

    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', 1, 'loaf');
    await pumpHome(tester);

    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('share text numbers the live items under any title', () {
    home.addItem('Rice', 5, 'kg');
    home.addItem('Bread', null, null);
    home.togglePurchased(home.items.last.id);

    expect(
      buildShareText(home.items),
      'My Shopping List\n\n1. Rice — 5 kg\n2. Bread ✓\n',
    );
    expect(
      buildShareText(home.items, title: 'Weekly Grocery'),
      startsWith('Weekly Grocery\n\n'),
    );
  });
}
