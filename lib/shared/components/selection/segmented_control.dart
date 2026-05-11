import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  const SegmentOption({required this.value, required this.label});
}

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final selectedIdx = options.indexWhere((o) => o.value == selected);
    return LayoutBuilder(
      builder: (_, constraints) {
        final itemWidth = constraints.maxWidth / options.length;
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: selectedIdx * itemWidth + 3,
                top: 3,
                bottom: 3,
                width: itemWidth - 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              Row(
                children: options.map((opt) {
                  final isSelected = opt.value == selected;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(opt.value),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          opt.label,
                          style: isSelected
                              ? context.labelMedium.copyWith(color: cs.onPrimary)
                              : context.labelMedium.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
