import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.isLocked = false,
    this.leading,
  });

  final String label;
  final String value;
  final bool isLocked;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.bodyMedium.semiBold.copyWith(
                    color: isLocked ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
