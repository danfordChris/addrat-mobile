import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/components/inputs/app_dropdown_field.dart';

class AppSearchableDropdown<T> extends StatefulWidget {
  const AppSearchableDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  State<AppSearchableDropdown<T>> createState() =>
      _AppSearchableDropdownState<T>();
}

class _AppSearchableDropdownState<T>
    extends State<AppSearchableDropdown<T>> {
  String? get _selectedLabel =>
      widget.items.where((i) => i.value == widget.value).map((i) => i.label).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.enabled ? () => _showPicker(context) : null,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: widget.errorText != null ? cs.error : cs.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.label != null)
                        Text(
                          widget.label!,
                          style: context.labelSmall.copyWith(color: cs.onSurfaceVariant),
                        ),
                      Text(
                        _selectedLabel ?? widget.hint ?? 'Select...',
                        style: context.bodyLarge.copyWith(
                          color: _selectedLabel != null ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: cs.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(widget.errorText!,
                style: context.bodySmall.copyWith(color: cs.error)),
          ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _SearchablePicker<T>(
        label: widget.label,
        items: widget.items,
        selected: widget.value,
        onSelected: (val) {
          widget.onChanged(val);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchablePicker<T> extends StatefulWidget {
  const _SearchablePicker({
    required this.items,
    required this.selected,
    required this.onSelected,
    this.label,
  });

  final List<DropdownItem<T>> items;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final String? label;

  @override
  State<_SearchablePicker<T>> createState() => _SearchablePickerState<T>();
}

class _SearchablePickerState<T> extends State<_SearchablePicker<T>> {
  late List<DropdownItem<T>> _filtered;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filtered = query.isEmpty
            ? widget.items
            : widget.items
                .where((i) =>
                    i.label.toLowerCase().contains(query.toLowerCase()))
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: _onSearch,
              style: context.bodyLarge.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Search ${widget.label?.toLowerCase() ?? ''}...',
                prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final item = _filtered[i];
                final selected = item.value == widget.selected;
                return InkWell(
                  onTap: () => widget.onSelected(item.value),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: selected
                                ? context.bodyLarge.semiBold.copyWith(color: cs.primary)
                                : context.bodyLarge.copyWith(color: cs.onSurface),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check, color: cs.primary, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
