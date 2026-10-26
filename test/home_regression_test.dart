import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_list/app/data/repositories/cart_repository.dart';
import 'package:shopping_list/app/data/repositories/saved_list_repository.dart';
import 'package:shopping_list/app/modules/home/home_controller.dart';
import 'package:shopping_list/app/modules/previous_lists/previous_list_controller.dart';
import 'package:shopping_list/app/modules/settings/settings_controller.dart';

HomeController get home => Get.find<HomeController>();

PreviousListController get previous => Get.find<PreviousListController>();

SettingsController get settings => Get.find<SettingsController>();

void main() {
  late GetStorage box;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('shopping_list_home');
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
    final settings = Get.put(SettingsController());
    settings.onInit();
  });

  /// Rebuilds the controller graph from storage, like a cold app start.
  void restartApp() {
    Get.reset();
    final home = Get.put(HomeController());
    home.onInit();
    final previous = Get.put(PreviousListController());
    previous.onInit();
    final settings = Get.put(SettingsController());
    settings.onInit();
  }

  test('add, edit, duplicate, purchase and delete all persist', () {
    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', null, null);
    final milk = home.items.first;

    home.updateItem(milk.id, 'Milk', 3, 'L');
    home.togglePurchased(home.items[1].id);
    expect(home.items[1].isPurchased, isTrue);

    home.duplicateItem(milk.id);
    expect(home.items, hasLength(3));
    expect(home.items[1].quantityLabel, '3 L');
    expect(home.remainingCount, 2);

    home.deleteItem(home.items[1].id);
    expect(home.items, hasLength(2));

    restartApp();
    expect(home.items.map((e) => '${e.name}|${e.quantityLabel}').toList(),
        ['Milk|3 L', 'Bread|']);
  });

  test('filters and counts stay correct across save and reuse', () {
    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', null, null);
    home.addItem('Eggs', 12, 'pcs');
    home.togglePurchased(home.items.last.id);

    expect(home.items, hasLength(3));
    expect(home.remainingCount, 2);
    expect(home.purchasedItems, hasLength(1));
    expect(home.hasPurchased, isTrue);

    final saved = previous.saveActiveList('Weekly groceries',
        clearActiveList: false);
    expect(home.items, hasLength(3));
    expect(saved.purchasedCount, 1);

    previous.reuse(saved.id, replace: true);

    expect(home.items, hasLength(3));
    expect(home.remainingCount, 3);
    expect(home.purchasedItems, isEmpty);
    expect(home.hasPurchased, isFalse);
    expect(home.pendingItems.map((e) => e.name).toList(),
        ['Milk', 'Bread', 'Eggs']);
  });

  test('clear purchased and clear list still work after a reuse', () {
    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', null, null);
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);
    expect(home.items, isEmpty);

    previous.reuse(saved.id);
    expect(home.items, hasLength(2));

    home.togglePurchased(home.items.first.id);
    home.clearPurchased();
    expect(home.items.map((e) => e.name).toList(), ['Bread']);
    expect(home.hasPurchased, isFalse);

    home.clearList();
    expect(home.isEmpty, isTrue);
    expect(CartRepository().loadItems(), isEmpty);
    expect(previous.lists, hasLength(1));
  });

  test('reused items keep feeding autocomplete and history', () {
    home.addItem('Bath Soap', 2, null);
    final saved =
        previous.saveActiveList('Monthly essentials', clearActiveList: true);

    previous.reuse(saved.id, replace: true);

    final suggestions = home.suggestionsFor('soap');
    expect(suggestions.map((e) => e.name), contains('Bath Soap'));
    final soap = suggestions.firstWhere((e) => e.name == 'Bath Soap');
    expect(home.blockReasonFor(soap), 'Already on your list');
  });

  test('English and Malayalam names round-trip through save and reuse', () {
    home.addItem('തക്കാളി', 1, 'kg');
    home.addItem('Milk', 2, 'L');
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: true);

    previous.reuse(saved.id, replace: true);
    restartApp();

    expect(home.items[0].name, 'തക്കാളി');
    expect(home.items[0].quantityLabel, '1 kg');
    expect(SavedListRepository().load().first.items[0].name, 'തക്കാളി');
  });

  test('active list and saved lists both survive a cold restart', () {
    home.addItem('Milk', 2, 'L');
    home.addItem('Bread', null, null);
    previous.saveActiveList('Weekly groceries', clearActiveList: false);
    home.togglePurchased(home.items.first.id);
    settings.setHaptics(true);
    settings.setDark(true);

    restartApp();

    expect(home.items, hasLength(2));
    expect(home.remainingCount, 1);
    expect(previous.lists.map((e) => e.name), ['Weekly groceries']);
    expect(settings.hapticsEnabled.value, isTrue);
    expect(settings.isDark.value, isTrue);
  });

  test('haptics enabled does not disturb saving or reusing', () {
    settings.setHaptics(true);
    home.addItem('Milk', 1, 'L');

    final saved = previous.saveActiveList('Trip', clearActiveList: true);

    expect(home.items, isEmpty);
    expect(previous.reuse(saved.id, replace: true), 1);
    expect(previous.reuse(saved.id), 0);
  });

  test('renaming and deleting from the reloaded graph still persist', () {
    home.addItem('Milk', 2, 'L');
    final saved =
        previous.saveActiveList('Weekly groceries', clearActiveList: false);

    restartApp();
    previous.rename(previous.lists.first.id, 'Ration run');
    expect(SavedListRepository().load().single.name, 'Ration run');

    previous.delete(previous.lists.first.id);
    expect(previous.lists, isEmpty);
    expect(home.items, hasLength(1));
    expect(SavedListRepository().load(), isEmpty);
    expect(saved.items, hasLength(1));
  });
}
