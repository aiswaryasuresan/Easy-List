import 'package:flutter/material.dart';

import '../../core/services/haptic_service.dart';
import '../../theme/app_theme.dart';

/// The All / To Buy / Purchased chip row, shared by the main List screen and
/// every custom list so both filter the same way.
class ItemFilterChips extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const ItemFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Row(
      children: List.generate(labels.length, (index) {
        final isSelected = selected == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(labels[index]),
            selected: isSelected,
            showCheckmark: false,
            backgroundColor: t.surface,
            selectedColor: t.primary,
            side: BorderSide(color: t.divider),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : t.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) {
              onChanged(index);
              HapticService.selection();
            },
          ),
        );
      }),
    );
  }
}
