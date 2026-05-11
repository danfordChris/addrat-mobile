import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/shared/components/cards/app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final color = accentColor ?? cs.primary;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.titleLarge.bold.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
