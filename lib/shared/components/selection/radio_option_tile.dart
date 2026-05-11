import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class RadioOptionTile<T> extends StatelessWidget {
  const RadioOptionTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.subtitle,
  });

  final T value;
  final T? groupValue;
  final String label;
  final String? subtitle;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? cs.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? cs.primary : cs.outlineVariant,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Icon(Icons.circle, color: cs.onPrimary, size: 8),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.bodyMedium.medium.copyWith(
                      color: selected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: context.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
