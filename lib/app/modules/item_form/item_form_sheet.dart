import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';
import '../../core/widgets/tap_pulse.dart';
import '../../data/grocery_suggestions.dart';
import '../../data/models/shopping_item.dart';
import '../../theme/app_theme.dart';
import '../home/home_controller.dart';
import '../home/widgets/item_options_sheet.dart';

class ItemFormSheet extends StatefulWidget {
  final ShoppingItem? item;
  final String? initialName;
  final String? initialUnit;

  const ItemFormSheet({
    super.key,
    this.item,
    this.initialName,
    this.initialUnit,
  });

  static Future<void> showAdd({String? name, String? unit}) => Get.bottomSheet(
    ItemFormSheet(initialName: name, initialUnit: unit),
    isScrollControlled: true,
    ignoreSafeArea: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );

  static Future<void> showEdit(ShoppingItem item) => Get.bottomSheet(
    ItemFormSheet(item: item),
    isScrollControlled: true,
    ignoreSafeArea: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  String? _unit;
  String? _nameError;

  bool get isEditing => widget.item != null;

  AppTokens get _t => AppTokens.of(context);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item?.name ?? widget.initialName ?? '',
    );
    final q = widget.item?.quantity;
    _quantityController = TextEditingController(
      text: q == null
          ? ''
          : (q == q.roundToDouble() ? q.toInt().toString() : '$q'),
    );
    _unit = widget.item?.unit ?? widget.initialUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _stepQuantity(int step) {
    final current = double.tryParse(_quantityController.text.trim()) ?? 0;
    var next = current + step;
    if (next < 0) next = 0;
    final text = next == next.roundToDouble()
        ? next.toInt().toString()
        : '$next';
    setState(() => _quantityController.text = next == 0 ? '' : text);
    HapticService.selection();
  }

  void _save() {
    final controller = Get.find<HomeController>();
    final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter an item name.');
      return;
    }
    final quantityText = _quantityController.text.trim();
    double? quantity;
    if (quantityText.isNotEmpty) {
      quantity = double.tryParse(quantityText);
      if (quantity == null || quantity <= 0) {
        Get.snackbar(
          'Invalid quantity',
          'Quantity must be a positive number.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _t.destructiveBackground,
          colorText: _t.destructive,
          margin: const EdgeInsets.all(12),
        );
        return;
      }
    }
    if (isEditing) {
      controller.updateItem(widget.item!.id, name, quantity, _unit);
    } else {
      controller.addItem(name, quantity, _unit);
    }
    Get.back();
  }

  void _delete() {
    if (!isEditing) return;
    Get.back();
    ItemOptionsSheet.confirmDelete(context, widget.item!);
  }

  @override
  Widget build(BuildContext context) {
    final available =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Container(
        height: available * 0.9,
        decoration: BoxDecoration(
          color: _t.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _t.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isEditing) ...[
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Item',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Add Item',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Item name',
                        style: TextStyle(
                          fontSize: 13,
                          color: _t.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildNameField(),
                      const SizedBox(height: 18),
                      Text(
                        'Quantity (optional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: _t.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildQuantityStepper(),
                      const SizedBox(height: 18),
                      Text(
                        'Unit (optional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: _t.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUnitGrid(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _delete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: _t.destructive,
                        ),
                        label: Text(
                          'Delete',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _t.destructive,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: _t.destructiveBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                )
              else
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Add Item'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Autocomplete<String>(
      optionsBuilder: (value) {
        final text = value.text.toLowerCase().trim();
        if (text.isEmpty) return const <String>[];
        final matches = kAllGrocerySuggestions
            .where((s) => s.toLowerCase().contains(text))
            .toList();
        final prefix =
            matches.where((s) => s.toLowerCase().startsWith(text)).toList();
        final partial =
            matches.where((s) => !s.toLowerCase().startsWith(text)).toList();
        return [...prefix, ...partial].take(6).toList();
      },
      onSelected: (selection) {
        _nameController.text = selection;
        setState(() => _nameError = null);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width - 40,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: _t.divider),
                itemBuilder: (_, i) {
                  final option = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(
                      horizontal: 0,
                      vertical: -1,
                    ),
                    leading: Icon(
                      Icons.search,
                      size: 18,
                      color: _t.textSecondary,
                    ),
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: _nameController,
              focusNode: focusNode,
              onSubmitted: (_) => onFieldSubmitted(),
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Enter item name',
                errorText: _nameError,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _nameController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.cancel,
                          size: 18,
                          color: _t.textSecondary,
                        ),
                        onPressed: () {
                          _nameController.clear();
                          setState(() => _nameError = null);
                        },
                      ),
              ),
              onChanged: (_) {
                setState(() {
                  if (_nameError != null) _nameError = null;
                });
              },
            );
          },
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _t.chipBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          TapPulse(
            onTap: () => _stepQuantity(-1),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.remove, color: _t.textPrimary),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _quantityController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              decoration: const InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          TapPulse(
            onTap: () => _stepQuantity(1),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.add, color: _t.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitGrid() {
    final rows = <List<String>>[
      kUnits.take(4).toList(),
      kUnits.skip(4).toList(),
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (final u in row) ...[
                  Expanded(child: _unitChip(u)),
                  if (u != row.last) const SizedBox(width: 10),
                ],
                for (int i = row.length; i < 4; i++)
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _unitChip(String u) {
    final selected = _unit == u;
    return TapPulse(
      onTap: () {
        setState(() => _unit = selected ? null : u);
        HapticService.selection();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _t.primaryDark : _t.chipBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          u,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : _t.textPrimary,
          ),
        ),
      ),
    );
  }
}
