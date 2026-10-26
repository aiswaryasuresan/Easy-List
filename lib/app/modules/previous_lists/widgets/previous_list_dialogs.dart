import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/haptic_service.dart';
import '../../../data/models/saved_list.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../home/home_controller.dart';
import '../previous_list_controller.dart';
import '../previous_list_detail_view.dart';

class PreviousListDialogs {
  PreviousListDialogs._();

  static Future<void> finishShopping(BuildContext context) async {
    final t = AppTokens.of(context);
    final home = Get.find<HomeController>();
    final previous = Get.find<PreviousListController>();

    final count = home.items.length;
    if (count == 0) {
      _snack(
        t,
        title: 'Nothing to save',
        message: 'Add a few items first, then finish shopping.',
        destructive: false,
      );
      return;
    }

    final name = previous.suggestedName();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          backgroundColor: t.lightSage,
          child: Icon(Icons.check_circle_outline, color: t.primaryDark),
        ),
        title: const Text(
          'Finish shopping?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Your $count ${count == 1 ? 'item' : 'items'} will be saved as '
          '"$name" under Create Lists, and the list screen will be cleared '
          'for your next trip.',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: _actionRow(
          ctx,
          confirmLabel: 'Save & clear',
          onConfirm: () {
            Navigator.of(ctx).pop();
            previous.saveActiveList(name, clearActiveList: true);
            _snack(
              t,
              title: 'List saved',
              message: 'Find it any time under Create Lists.',
              destructive: false,
            );
          },
        ),
      ),
    );
  }

  /// Copies the active list's items into a new named list. The main List is
  /// left exactly as it was — no items are removed or re-checked.
  static Future<void> saveCurrentList(BuildContext context) async {
    final t = AppTokens.of(context);
    final home = Get.find<HomeController>();
    final previous = Get.find<PreviousListController>();

    final count = home.items.length;
    if (count == 0) {
      _snack(
        t,
        title: 'Nothing to save',
        message: 'Add items to your list first, then save it here.',
        destructive: false,
      );
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NamePromptDialog(
        title: 'Save Current List',
        confirmLabel: 'Save List',
        message:
            'Copies your $count ${count == 1 ? 'item' : 'items'} into a '
            'new list. The main List stays as it is.',
        hintText: 'e.g. Weekly Grocery',
        helperText:
            'Try "Weekly Grocery", "Monthly Essentials" or '
            '"Fruits & Vegetables".',
        validator: (raw) => _validateName(raw, previous),
      ),
    );
    if (name == null) return;
    final saved = previous.saveActiveList(name, clearActiveList: false);
    _snack(
      t,
      title: 'List saved',
      message: '"${saved.name}" is now in your lists.',
      destructive: false,
    );
  }

  /// Creates an empty list and opens it for editing.
  static Future<void> createNewList(BuildContext context) async {
    final previous = Get.find<PreviousListController>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NamePromptDialog(
        title: 'New list',
        confirmLabel: 'Create list',
        hintText: 'e.g. Weekly Grocery',
        helperText: 'You can add items next, and rename the list at any time.',
        validator: (raw) => _validateName(raw, previous),
      ),
    );
    if (name == null) return;
    final saved = previous.createList(name);
    if (saved == null) return;
    Get.to(() => PreviousListDetailView(listId: saved.id));
  }

  static String? _validateName(String raw, PreviousListController previous) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Please enter a list name.';
    if (previous.nameTaken(trimmed)) {
      return 'You already have a list called "$trimmed".';
    }
    return null;
  }

  static Future<void> confirmReuse(BuildContext context, SavedList list) async {
    final previous = Get.find<PreviousListController>();
    if (!previous.tryBeginReuse()) return;
    try {
      await _reuseFlow(context, list);
    } finally {
      previous.endReuse();
    }
  }

  static Future<void> _reuseFlow(BuildContext context, SavedList list) async {
    final t = AppTokens.of(context);
    final home = Get.find<HomeController>();
    final previous = Get.find<PreviousListController>();

    final started = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          backgroundColor: t.lightSage,
          child: Icon(Icons.replay, color: t.primaryDark),
        ),
        title: const Text(
          'Reuse this list?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will create a new shopping list with the same items. '
          'All items will be marked as To Buy.',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: _actionRow(
          ctx,
          confirmLabel: 'Reuse List',
          onConfirm: () => Navigator.of(ctx).pop(true),
        ),
      ),
    );
    if (started != true) return;
    if (!context.mounted) return;

    var replace = home.items.isEmpty;
    if (!replace) {
      // Discarding items the user is still holding needs its own yes/no.
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Your list already has items',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Add keeps the ${home.items.length} '
            '${home.items.length == 1 ? 'item' : 'items'} on your list and '
            'skips anything already there. Replace starts a fresh list from '
            '"${list.name}" and discards what is on your list now.',
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: _stackedActions(ctx, const [
            _Choice(value: 'add', label: 'Add to current list'),
            _Choice(
              value: 'replace',
              label: 'Replace current list',
              destructive: true,
            ),
            _Choice(value: null, label: 'Cancel', muted: true),
          ]),
        ),
      );
      switch (choice) {
        case 'add':
          replace = false;
        case 'replace':
          replace = true;
        default:
          return;
      }
    }

    final added = previous.reuse(list.id, replace: replace);
    // Land on the List tab so the freshly copied items are immediately visible.
    home.tab.value = 0;
    Get.until(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
    if (added > 0) HapticService.success();
    _snack(
      t,
      title: added > 0 ? 'List reused successfully!' : 'Nothing to add',
      message: added > 0
          ? '$added ${added == 1 ? 'item' : 'items'} added as To Buy.'
          : 'Every item from "${list.name}" is already on your list.',
      destructive: false,
    );
  }

  static Future<void> rename(BuildContext context, SavedList list) async {
    final previous = Get.find<PreviousListController>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NamePromptDialog(
        title: 'Rename list',
        confirmLabel: 'Save',
        initial: list.name,
        validator: (raw) {
          final trimmed = raw.trim();
          if (trimmed.isEmpty) return 'Please enter a list name.';
          if (previous.nameTaken(trimmed, exceptId: list.id)) {
            return 'You already have a list called "$trimmed".';
          }
          return null;
        },
      ),
    );
    if (name == null) return;
    previous.rename(list.id, name);
  }

  static Future<void> confirmDelete(
    BuildContext context,
    SavedList list, {
    VoidCallback? afterDelete,
  }) async {
    final t = AppTokens.of(context);
    final previous = Get.find<PreviousListController>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          backgroundColor: t.destructiveBackground,
          child: Icon(Icons.delete_outline, color: t.destructive),
        ),
        title: const Text(
          'Delete this list?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${list.name}" and its ${list.items.length} '
          '${list.items.length == 1 ? 'item' : 'items'} will be deleted from '
          'this device. Your main List is not affected.',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: _actionRow(
          ctx,
          confirmLabel: 'Delete',
          destructive: true,
          onConfirm: () {
            Navigator.of(ctx).pop();
            previous.delete(list.id);
            afterDelete?.call();
          },
        ),
      ),
    );
  }

  static List<Widget> _stackedActions(BuildContext ctx, List<_Choice> choices) {
    final t = AppTokens.of(ctx);
    return [
      Column(
        children: [
          for (final choice in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(choice.value),
                style: TextButton.styleFrom(
                  backgroundColor: choice.muted
                      ? t.chipBackground
                      : choice.destructive
                      ? t.destructive
                      : t.primary,
                  foregroundColor: choice.muted ? t.textPrimary : Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(choice.label),
              ),
            ),
        ],
      ),
    ];
  }

  static List<Widget> _actionRow(
    BuildContext ctx, {
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool destructive = false,
  }) {
    final t = AppTokens.of(ctx);
    return [
      Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                backgroundColor: t.chipBackground,
                foregroundColor: t.textPrimary,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: onConfirm,
              style: TextButton.styleFrom(
                backgroundColor: destructive ? t.destructive : t.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(confirmLabel),
            ),
          ),
        ],
      ),
    ];
  }

  static void _snack(
    AppTokens t, {
    required String title,
    required String message,
    required bool destructive,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: destructive ? t.destructiveBackground : t.lightSage,
      colorText: destructive ? t.destructive : t.primaryDark,
      margin: const EdgeInsets.all(12),
    );
  }
}

class _Choice {
  final String? value;
  final String label;
  final bool destructive;
  final bool muted;

  const _Choice({
    required this.value,
    required this.label,
    this.destructive = false,
    this.muted = false,
  });
}

/// Name prompt for custom lists. It owns its TextEditingController: a
/// controller disposed as soon as `showDialog` returns is still read by the
/// field during the route's exit animation, which throws and blows up the
/// dialog layout.
class _NamePromptDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String? initial;
  final String? message;
  final String? hintText;
  final String? helperText;
  final String? Function(String name)? validator;

  const _NamePromptDialog({
    required this.title,
    required this.confirmLabel,
    this.initial,
    this.message,
    this.hintText,
    this.helperText,
    this.validator,
  });

  @override
  State<_NamePromptDialog> createState() => _NamePromptDialogState();
}

class _NamePromptDialogState extends State<_NamePromptDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.validator?.call(_controller.text);
    if (error != null) {
      // Stay open so the user can fix the name instead of losing their typing.
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[
            Text(
              widget.message!,
              style: TextStyle(fontSize: 14, color: t.textSecondary),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: PreviousListController.maxListNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'List name',
              hintText: widget.hintText,
              errorText: _error,
              counterText: '',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          if (widget.helperText != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.helperText!,
              style: TextStyle(fontSize: 12.5, color: t.textSecondary),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: PreviousListDialogs._actionRow(
        context,
        confirmLabel: widget.confirmLabel,
        onConfirm: _submit,
      ),
    );
  }
}
