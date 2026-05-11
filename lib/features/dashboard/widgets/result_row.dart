import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class ResultRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  final bool isBold;

  const ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: HugeIcon(icon: icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: context.bodyMedium.copyWith(color: isBold ? cs.onSurface : cs.onSurfaceVariant)),
        ),
        Text(value, style: isBold ? context.titleSmall.copyWith(color: cs.onSurface) : context.labelMedium.copyWith(color: cs.onSurface)),
      ],
    );
  }
}
