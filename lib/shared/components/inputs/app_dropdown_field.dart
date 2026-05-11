import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({required this.value, required this.label});
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
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

  String? get _selectedLabel =>
      items.where((i) => i.value == value).map((i) => i.label).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: enabled ? () => _showPicker(context) : null,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: enabled ? cs.surfaceContainer : cs.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: errorText != null ? cs.error : cs.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (label != null)
                        Text(
                          label!,
                          style: context.labelSmall.copyWith(color: cs.onSurfaceVariant),
                        ),
                      Text(
                        _selectedLabel ?? hint ?? 'Select...',
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
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText!, style: context.bodySmall.copyWith(color: cs.error)),
          ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (label != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final selected = item.value == value;
                  return InkWell(
                    onTap: () {
                      onChanged(item.value);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: selected
                                  ? Theme.of(ctx).textTheme.bodyLarge?.semiBold.copyWith(color: cs.primary)
                                  : Theme.of(ctx).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
