import 'package:flutter/material.dart' show ThemeMode;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/haptic_service.dart';

class SettingsController extends GetxController {
  static const _themeKey = 'theme_mode';
  static const _hapticsKey = 'haptics_enabled';

  final GetStorage _box = GetStorage();

  final isDark = false.obs;
  final hapticsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _box.read<String?>(_themeKey) == 'dark';
    // Off unless the user previously turned it on.
    hapticsEnabled.value = _box.read<bool?>(_hapticsKey) ?? false;
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  void setDark(bool value) {
    if (isDark.value == value) return;
    isDark.value = value;
    _box.write(_themeKey, value ? 'dark' : 'light');
    HapticService.selection();
  }

  void toggleTheme() => setDark(!isDark.value);

  void setHaptics(bool value) {
    hapticsEnabled.value = value;
    _box.write(_hapticsKey, value);
    // Turning it on confirms itself; turning it off must stay silent.
    if (value) HapticService.selection();
  }
}
