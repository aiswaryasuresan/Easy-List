import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../modules/settings/settings_controller.dart';

/// Single entry point for haptic feedback. Every call checks the existing
/// "Haptic Feedback" preference in [SettingsController] first, so the
/// Settings toggle remains the only source of truth.
///
/// A device may accept these calls without producing a vibration, so callers
/// must not treat haptics as the only confirmation — every haptic call is
/// paired with independent visual feedback (see `TapPulse`).
class HapticService {
  HapticService._();

  static bool get isEnabled {
    if (!Get.isRegistered<SettingsController>()) return false;
    return Get.find<SettingsController>().hapticsEnabled.value;
  }

  static void _run(void Function() feedback) {
    if (!isEnabled) return;
    try {
      feedback();
    } catch (_) {
      // Haptics are a nicety; never let an unsupported device break an action.
    }
  }

  /// Selecting a unit chip, filter, or other small control.
  static void selection() => _run(HapticFeedback.selectionClick);

  /// Marking an item purchased / unmarking it.
  static void lightTap() => _run(HapticFeedback.lightImpact);

  /// Successfully saving an item.
  static void success() => _run(HapticFeedback.mediumImpact);

  /// Confirming a destructive action.
  static void delete() => _run(HapticFeedback.heavyImpact);
}
