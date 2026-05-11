import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeaturePill({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: context.colorScheme.tertiary),
          const SizedBox(width: 6),
          Text(label, style: context.labelMedium.copyWith(color: Colors.white)),
        ]),
      );
}
