import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard({
    super.key,
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
  });

  final String languageCode;
  final String languageName;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;

  String get _flag => languageCode == 'sw' ? '🇹🇿' : '🇬🇧';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.08) : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(_flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style:context.bodyMedium.copyWith(color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurface.withValues(alpha: 0.8)).semiBold,
                  ),
                  Text(
                    nativeName,
                    style: context.bodySmall.copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? context.colorScheme.primary: Colors.transparent,
                border: Border.all(
                  color: isSelected ? context.colorScheme.primary :   context.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: context.colorScheme.onPrimary, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
