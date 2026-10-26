import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_list/app/data/models/saved_list.dart';
import 'package:shopping_list/app/data/repositories/cart_repository.dart';
import 'package:shopping_list/app/data/repositories/saved_list_repository.dart';
import 'package:shopping_list/app/modules/home/home_controller.dart';
import 'package:shopping_list/app/modules/previous_lists/previous_list_controller.dart';
import 'package:shopping_list/app/modules/previous_lists/previous_list_detail_view.dart';
import 'package:shopping_list/app/modules/previous_lists/previous_lists_view.dart';
import 'package:shopping_list/app/theme/app_theme.dart';

PreviousListController get previous => Get.find<PreviousListController>();

HomeController get home => Get.find<HomeController>();

/// Creates a list the way the UI does and unwraps it for behaviour tests.
SavedList create(String name) => previous.createList(name)!;

Future<void> pumpListsView(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const PreviousListsView()),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpDetailView(WidgetTester tester, int listId) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: PreviousListDetailView(listId: listId),
  ));
  await tester.pumpAndSettle();
}

Future<void> dismissSnack(WidgetTester tester) async {
  // Let GetX's snackbar run out its own duration and close animation, or the
  // test tears down the overlay with a live ticker.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> pumpDetailInGetX(WidgetTester tester, int listId) async {
  await tester.pumpWidget(GetMaterialApp(
    theme: AppTheme.light,
    initialRoute: '/',
    getPages: [
      GetPage(
        name: '/',
        page: () => PreviousListDetailView(listId: listId),
      ),
    ],
  ));
  await tester.pumpAndSettle();
}

Future<void> pumpListsTabInGetX(WidgetTester tester) async {
  await tester.pumpWidget(GetMaterialApp(
    theme: AppTheme.light,
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => const PreviousListsView()),
    ],
  ));
  await tester.pumpAndSettle();
}

/// Opens the soft keyboard, confirms, then hides the keyboard while the dialog
/// route is still animating out - the sequence that used to rebuild the field
/// against a disposed controller.
Future<void> confirmWithKeyboard(WidgetTester tester, String label) async {
  tester.view.viewInsets = FakeViewPadding(bottom: 260);
  await tester.pump();
  await tester.tap(find.widgetWithText(TextButton, label));
  tester.view.resetViewInsets();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  late GetStorage box;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('shopping_list_test');
    // get_storage resolves its folder through path_provider even when a path
    // is supplied, so the channel has to answer in tests.
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
    final home = Get.put(HomeController());
    home.onInit();
    Get.put(PreviousListController());
  });

  void seedActiveList() {
    home.addItem('Milk', 2, 'L');
    home.addItem('തക്കാളി', 1, 'kg');
    home.togglePurchased(home.items.first.id);
  }

  test('finishing shopping archives the trip and clears the active list', () {
    seedActiveList();
    expect(home.items.length, 2);

    final saved = previous.saveActiveList('Weekly groceries',
        clearActiveList: true);

    expect(previous.lists.length, 1);
    expect(saved.name, 'Weekly groceries');
    expect(saved.items.length, 2);
    expect(saved.purchasedCount, 1);
    expect(home.items, isEmpty);
  });

  test('saving a snapshot keeps the active list and stays independent', () {
    seedActiveList();

    final saved = previous.saveActiveList('Monthly essentials',
        clearActiveList: false);

    expect(home.items, hasLength(2));
    expect(previous.lists.single.name, 'Monthly essentials');

    home.addItem('Bread', null, null);
    home.togglePurchased(home.items.first.id);

    expect(saved.items, hasLength(2));
    expect(previous.byId(saved.id)!.items, hasLength(2));
  });

  test('an archived trip survives a reload from storage', () {
    seedActiveList();
    previous.saveActiveList('Weekly groceries', clearActiveList: false);

    final reloaded = SavedListRepository().load();
    expect(reloaded, hasLength(1));
    expect(reloaded.first.name, 'Weekly groceries');
    expect(
      reloaded.first.items.map((e) => '${e.name}|${e.quantityLabel}').toList(),
      ['Milk|2 L', 'തക്കാളി|1 kg'],
    );
  });

  test('reusing copies names, quantities and units as unchecked items', () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    final added = previous.reuse(saved.id);

    expect(added, 2);
    expect(home.items.every((e) => !e.isPurchased), isTrue);
    expect(home.items[0].name, 'Milk');
    expect(home.items[0].quantityLabel, '2 L');
    expect(home.items[1].name, 'തക്കാളി');
    expect(home.items[1].quantityLabel, '1 kg');
    expect(home.remainingCount, 2);
  });

  test('reusing leaves the archived trip untouched', () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    previous.reuse(saved.id);

    final stored = previous.byId(saved.id)!;
    expect(stored.items, hasLength(2));
    expect(stored.purchasedCount, 1);
  });

  test('a second reuse adds nothing and cannot duplicate items', () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    previous.reuse(saved.id);
    final second = previous.reuse(saved.id);

    expect(second, 0);
    expect(home.items, hasLength(2));
  });

  test('reusing onto a partly overlapping list only adds the missing items',
      () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);
    home.addItem('Bread', null, null);

    final added = previous.reuse(saved.id);

    expect(added, 2);
    expect(home.items.map((e) => e.name).toList(),
        containsAll(['Bread', 'Milk', 'തക്കാളി']));
  });

  test('replace reuse discards active items and copies the whole snapshot',
      () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);
    home.addItem('Bread', 1, null);
    home.togglePurchased(home.items.first.id);

    final added = previous.reuse(saved.id, replace: true);

    expect(added, 2);
    expect(
      home.items.map((e) => '${e.name}|${e.quantityLabel}').toList(),
      ['Milk|2 L', 'തക്കാളി|1 kg'],
    );
    expect(home.items.every((e) => !e.isPurchased), isTrue);
    expect(home.remainingCount, 2);
    expect(home.hasPurchased, isFalse);
    expect(previous.reuseInProgress, isFalse);
  });

  test('replace reuse never modifies the saved original and repeats cleanly',
      () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    expect(previous.reuse(saved.id, replace: true), 2);
    home.addItem('Bread', 1, null);
    expect(previous.reuse(saved.id, replace: true), 2);

    expect(home.items, hasLength(2));
    expect(previous.byId(saved.id)!.items, hasLength(2));
    expect(previous.byId(saved.id)!.purchasedCount, 1);
  });

  test('reused items are persisted to local storage', () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    previous.reuse(saved.id, replace: true);

    final reloaded = CartRepository().loadItems();
    expect(reloaded, hasLength(2));
    expect(reloaded.every((e) => !e.isPurchased), isTrue);
    expect(reloaded.map((e) => e.quantityLabel).toList(), ['2 L', '1 kg']);
  });

  test('deleting an archived trip does not touch the active list', () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: false);
    final activeBefore = home.items.map((e) => e.name).toList();

    previous.delete(saved.id);

    expect(previous.lists, isEmpty);
    expect(home.items.map((e) => e.name).toList(), activeBefore);
  });

  test('renaming an archived trip persists the new name', () {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: false);

    previous.rename(saved.id, 'Ration run');

    expect(previous.byId(saved.id)!.name, 'Ration run');
    expect(SavedListRepository().load().first.name, 'Ration run');
  });

  test('corrupt stored records are skipped, not fatal', () {
    seedActiveList();
    previous.saveActiveList('Good list', clearActiveList: false);

    final raw = jsonDecode(jsonEncode([
      {'id': 99, 'name': 'Broken', 'createdAt': 1, 'items': 'not-a-list'},
      {'name': null},
      ...previous.lists.map((e) => e.toJson()),
    ]));
    box.write('previous_lists', raw);

    final loaded = SavedListRepository().load();
    expect(loaded, hasLength(2));
    expect(loaded.first.name, 'Broken');
    expect(loaded.first.items, isEmpty);
    expect(loaded.last.name, 'Good list');
  });

  test('a named list starts empty and never touches the main List', () {
    final first = create('Weekly Groceries');
    final second = create('Monthly Essentials');

    expect(first.items, isEmpty);
    // Newest first, and the main List is never involved.
    expect(previous.lists.map((e) => e.id).toList(), [second.id, first.id]);
    expect(home.items, isEmpty);
  });

  test('a list name is required', () {
    expect(previous.createList(''), isNull);
    expect(previous.createList('   '), isNull);
    expect(previous.lists, isEmpty);
  });

  test('names are collapsed and capped, duplicates are refused', () {
    final spaced = create('  Monthly   essentials  ');
    final long = create('a' * 90);

    expect(spaced.name, 'Monthly essentials');
    expect(long.name, hasLength(PreviousListController.maxListNameLength));
    // Same name ignoring case and extra spaces, so it is refused.
    expect(previous.createList('monthly  ESSENTIALS'), isNull);
    expect(previous.nameTaken('Monthly Essentials'), isTrue);
    expect(previous.nameTaken('Monthly Essentials', exceptId: spaced.id),
        isFalse);
    expect(previous.lists, hasLength(2));
  });

  test('renaming to a name another list uses is refused', () {
    final weekly = create('Weekly Groceries');
    create('Monthly Essentials');

    previous.rename(weekly.id, 'Monthly Essentials');
    expect(previous.byId(weekly.id)!.name, 'Weekly Groceries');

    previous.rename(weekly.id, 'Fruits & Vegetables');
    expect(previous.byId(weekly.id)!.name, 'Fruits & Vegetables');
  });

  test('editing a list stamps its update time and persists it', () {
    final list = create('Weekly Groceries');
    final created = list.updatedAt;

    SavedListWriter(list.id, controller: previous).addItem('Milk', 2, 'L');

    expect(list.updatedAt, greaterThan(created));
    final reloaded = SavedListRepository().load().first;
    expect(reloaded.updatedAt, list.updatedAt);
  });

  test('a stored list without an update time still loads', () {
    final list = create('Weekly Groceries');
    final legacy = list.toJson()..remove('updatedAt');
    box.write('previous_lists', [legacy]);

    final loaded = SavedListRepository().load().single;
    expect(loaded.name, 'Weekly Groceries');
    expect(loaded.updatedAt, loaded.createdAt);
  });

  test('clearing purchased items empties one list only', () {
    final weekly = create('Weekly Groceries');
    final monthly = create('Monthly Essentials');
    final weeklyWriter = SavedListWriter(weekly.id, controller: previous);
    final monthlyWriter = SavedListWriter(monthly.id, controller: previous);

    weeklyWriter.addItem('Milk', 2, 'L');
    weeklyWriter.addItem('Bread', 1, null);
    weeklyWriter.togglePurchased(weekly.items.last.id);
    monthlyWriter.addItem('Rice', 5, 'kg');
    home.addItem('Eggs', 12, null);
    home.togglePurchased(home.items.first.id);

    weeklyWriter.clearPurchased();

    expect(weekly.items.map((e) => e.name).toList(), ['Milk']);
    expect(weekly.purchasedCount, 0);
    expect(monthly.items, hasLength(1));
    expect(home.items, hasLength(1));
    expect(home.hasPurchased, isTrue);
  });

  test('items can be added, edited, checked and removed inside a saved list',
      () {
    final list = create('Weekly Groceries');
    final writer = SavedListWriter(list.id, controller: previous);

    writer.addItem('Milk', 2, 'L');
    writer.addItem('Bread', null, null);
    expect(list.items.map((e) => e.quantityLabel).toList(), ['2 L', '']);

    final milk = list.items.first;
    writer.updateItem(milk.id, 'Milk', 3, 'L');
    writer.togglePurchased(list.items.last.id);
    expect(list.purchasedCount, 1);

    writer.duplicateItem(milk.id);
    expect(list.items.map((e) => e.name).toList(), ['Milk', 'Milk', 'Bread']);
    // The copy lands beside the source and always starts as To Buy.
    expect(list.items[1].isPurchased, isFalse);

    writer.deleteItem(list.items[1].id);
    expect(list.items.map((e) => e.name).toList(), ['Milk', 'Bread']);

    final reloaded = SavedListRepository().load().first;
    expect(reloaded.name, 'Weekly Groceries');
    expect(reloaded.items.map((e) => '${e.name}|${e.quantityLabel}').toList(),
        ['Milk|3 L', 'Bread|']);
    expect(reloaded.purchasedCount, 1);
  });

  test('editing one saved list leaves other lists and the active list alone',
      () {
    home.addItem('Eggs', 12, null);
    final weekly = create('Weekly Groceries');
    final monthly = create('Monthly Essentials');
    final weeklyWriter = SavedListWriter(weekly.id, controller: previous);
    final monthlyWriter = SavedListWriter(monthly.id, controller: previous);

    weeklyWriter.addItem('Milk', 2, 'L');
    monthlyWriter.addItem('Rice', 5, 'kg');
    home.addItem('Bread', 1, null);

    expect(weekly.items.map((e) => e.name).toList(), ['Milk']);
    expect(monthly.items.map((e) => e.name).toList(), ['Rice']);
    expect(home.items.map((e) => e.name).toList(), ['Eggs', 'Bread']);
    expect(weekly.items.single.id, monthly.items.single.id);

    monthlyWriter.togglePurchased(monthly.items.single.id);
    expect(weekly.items.single.isPurchased, isFalse);
    expect(home.items.first.isPurchased, isFalse);
  });

  test('an edited saved list reuses with its newest contents', () {
    final list = create('Weekly Groceries');
    final writer = SavedListWriter(list.id, controller: previous);
    writer.addItem('Milk', 2, 'L');
    writer.togglePurchased(list.items.single.id);
    writer.addItem('തക്കാളി', 1, 'kg');

    final added = previous.reuse(list.id);

    expect(added, 2);
    expect(home.items.every((e) => !e.isPurchased), isTrue);
    expect(home.items.map((e) => e.quantityLabel).toList(), ['2 L', '1 kg']);
    expect(list.purchasedCount, 1);
  });

  testWidgets('shows the empty state and both create buttons', (tester) async {
    await pumpListsView(tester);

    expect(find.text('Create Lists'), findsOneWidget);
    expect(find.text('No lists yet'), findsOneWidget);
    expect(find.text('Create New List'), findsOneWidget);
    expect(find.text('Save Current'), findsOneWidget);
  });

  testWidgets('renders lists as cards with name, counts and update date',
      (tester) async {
    home.addItem('Milk', 2, 'L');
    home.addItem('തക്കാളി', 1, 'kg');
    previous.saveActiveList('Weekly groceries', clearActiveList: false);

    await pumpListsView(tester);

    expect(find.text('Weekly groceries'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.textContaining('Updated '), findsOneWidget);
    expect(find.text('Milk, തക്കാളി'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.text('No lists yet'), findsNothing);
  });

  testWidgets('detail screen shows the snapshot with quantities and units',
      (tester) async {
    home.addItem('Milk', 2, 'L');
    home.addItem('തക്കാളി', 1, 'kg');
    final saved = previous.saveActiveList('Weekly groceries',
        clearActiveList: false);

    await pumpDetailView(tester, saved.id);

    expect(find.text('Weekly groceries'), findsOneWidget);
    expect(find.textContaining('Created '), findsOneWidget);
    expect(find.textContaining('Updated '), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('2 L'), findsOneWidget);
    expect(find.text('തക്കാളി'), findsOneWidget);
    expect(find.text('1 kg'), findsOneWidget);
    expect(find.text('Reuse This List'), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Add item'), findsOneWidget);
    // The app bar menu plus one menu per item row.
    expect(find.byIcon(Icons.more_vert), findsNWidgets(3));
  });

  testWidgets('detail screen reports a list that is no longer available',
      (tester) async {
    home.addItem('Milk', 2, 'L');
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: false);
    previous.delete(saved.id);

    await pumpDetailView(tester, saved.id);

    expect(find.text('This list is no longer available.'), findsOneWidget);
    expect(find.text('Reuse This List'), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('empty saved list disables the reuse button', (tester) async {
    final blank = SavedList(
      id: 4242,
      name: 'Empty list',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      items: const [],
    );
    previous.lists.add(blank);

    await pumpDetailView(tester, blank.id);

    expect(find.text('No items yet'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.ancestor(
      of: find.text('Reuse This List'),
      matching: find.byType(FilledButton),
    ));
    expect(button.onPressed, isNull);
  });

  testWidgets('the detail screen form writes into the saved list only',
      (tester) async {
    home.addItem('Eggs', 12, null);
    final list = create('Weekly Groceries');

    await pumpDetailInGetX(tester, list.id);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add item'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Milk');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add Item'));
    await tester.pumpAndSettle();

    expect(list.items.map((e) => e.name).toList(), ['Milk']);
    expect(home.items.map((e) => e.name).toList(), ['Eggs']);
    expect(find.text('Milk'), findsOneWidget);
  });

  testWidgets('each list filters its own items', (tester) async {
    final list = create('Weekly Groceries');
    final writer = SavedListWriter(list.id, controller: previous);
    writer.addItem('Milk', 2, 'L');
    writer.addItem('Bread', 1, null);
    writer.togglePurchased(list.items.last.id);

    await pumpDetailView(tester, list.id);

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);

    await tester.tap(find.text('To Buy (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Bread'), findsNothing);

    await tester.tap(find.text('Purchased (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Milk'), findsNothing);
    expect(find.text('Bread'), findsOneWidget);

    // Checking an item updates the counts and the visible rows immediately.
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('Purchased (0)'), findsOneWidget);
    expect(find.text('Nothing purchased yet.'), findsOneWidget);
    expect(find.text('To Buy (2)'), findsOneWidget);
  });

  testWidgets('clearing purchased from the detail menu keeps other lists',
      (tester) async {
    final list = create('Weekly Groceries');
    final other = create('Monthly Essentials');
    final writer = SavedListWriter(list.id, controller: previous);
    writer.addItem('Milk', 2, 'L');
    writer.addItem('Bread', 1, null);
    writer.togglePurchased(list.items.last.id);
    SavedListWriter(other.id, controller: previous).addItem('Rice', 5, 'kg');
    home.addItem('Eggs', 12, null);
    home.togglePurchased(home.items.first.id);

    await pumpDetailView(tester, list.id);
    await tester.tap(find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.more_vert),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear purchased (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Clear purchased items?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(list.items.map((e) => e.name).toList(), ['Milk']);
    expect(other.items, hasLength(1));
    expect(home.items, hasLength(1));
    expect(home.hasPurchased, isTrue);
  });

  testWidgets('Create New List names the list and opens it for editing',
      (tester) async {
    await pumpListsTabInGetX(tester);
    await tester.tap(find.text('Create New List'));
    await tester.pumpAndSettle();

    expect(find.text('New list'), findsOneWidget);
    expect(find.text('List name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Weekly Groceries');
    await confirmWithKeyboard(tester, 'Create list');

    expect(previous.lists.single.name, 'Weekly Groceries');
    expect(find.text('No items yet'), findsOneWidget);
  });

  testWidgets('a cancelled New List leaves nothing behind', (tester) async {
    await pumpListsTabInGetX(tester);
    await tester.tap(find.text('Create New List'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Weekly Groceries');
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(previous.lists, isEmpty);
    expect(find.text('No items yet'), findsNothing);
  });

  testWidgets('Save Current snapshots the active list and keeps it',
      (tester) async {
    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', null, null);

    await pumpListsTabInGetX(tester);
    await tester.tap(find.text('Save Current'));
    await tester.pumpAndSettle();

    expect(find.text('Save Current List'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Household Items');
    await confirmWithKeyboard(tester, 'Save List');

    expect(previous.lists.single.name, 'Household Items');
    expect(previous.lists.single.items, hasLength(2));
    expect(home.items, hasLength(2));
    await dismissSnack(tester);
  });

  testWidgets('an empty or taken name is refused and the dialog stays open',
      (tester) async {
    create('Weekly Groceries');

    await pumpListsTabInGetX(tester);
    await tester.tap(find.text('Create New List'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.widgetWithText(TextButton, 'Create list'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a list name.'), findsOneWidget);
    expect(previous.lists, hasLength(1));

    await tester.enterText(find.byType(TextField), 'weekly groceries');
    await tester.tap(find.widgetWithText(TextButton, 'Create list'));
    await tester.pumpAndSettle();
    expect(
        find.text('You already have a list called "weekly groceries".'),
        findsOneWidget);
    expect(previous.lists, hasLength(1));

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(previous.lists, hasLength(1));
  });

  testWidgets('reuse dialog shows the spec copy and Cancel changes nothing',
      (tester) async {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    await pumpDetailInGetX(tester, saved.id);
    await tester.tap(find.text('Reuse This List'));
    await tester.pumpAndSettle();

    expect(find.text('Reuse this list?'), findsOneWidget);
    expect(find.text('This will create a new shopping list with the same '
        'items. All items will be marked as To Buy.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Reuse List'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(home.items, isEmpty);
  });

  testWidgets('the reuse flow locks the button until it settles',
      (tester) async {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    await pumpDetailInGetX(tester, saved.id);
    await tester.tap(find.text('Reuse This List'));
    await tester.pumpAndSettle();

    expect(previous.reusing.value, isTrue);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(previous.reusing.value, isFalse);
    expect(home.items, isEmpty);
  });

  testWidgets('reusing onto an empty list copies unchecked items',
      (tester) async {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    await pumpDetailInGetX(tester, saved.id);
    await tester.tap(find.text('Reuse This List'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reuse List'));
    await tester.pumpAndSettle();

    expect(home.items, hasLength(2));
    expect(home.items.every((e) => !e.isPurchased), isTrue);
    expect(home.remainingCount, 2);
    expect(find.text('List reused successfully!'), findsOneWidget);

    await dismissSnack(tester);
  });

  testWidgets('a non-empty list is asked to add rather than discard',
      (tester) async {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);
    home.addItem('Bread', 1, null);

    await pumpDetailInGetX(tester, saved.id);
    await tester.tap(find.text('Reuse This List'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reuse List'));
    await tester.pumpAndSettle();

    expect(find.text('Your list already has items'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Add to current list'),
        findsOneWidget);
    expect(
        find.widgetWithText(TextButton, 'Replace current list'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Add to current list'));
    await tester.pumpAndSettle();

    expect(home.items.map((e) => e.name).toList(),
        containsAll(['Bread', 'Milk', 'തക്കാളി']));
    expect(find.text('List reused successfully!'), findsOneWidget);

    await dismissSnack(tester);
  });

  testWidgets('replace discards the active list only after confirmation',
      (tester) async {
    seedActiveList();
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);
    home.addItem('Bread', 1, null);

    await pumpDetailInGetX(tester, saved.id);
    await tester.tap(find.text('Reuse This List'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reuse List'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Replace current list'));
    await tester.pumpAndSettle();

    expect(home.items.map((e) => e.name).toList(), ['Milk', 'തക്കാളി']);
    expect(home.items.any((e) => e.name == 'Bread'), isFalse);
    expect(previous.byId(saved.id)!.items, hasLength(2));

    await dismissSnack(tester);
  });
}
