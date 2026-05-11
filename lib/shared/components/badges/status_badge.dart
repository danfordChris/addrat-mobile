import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  Color _color(ColorScheme cs) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'COMPLETE':
      case 'ACTIVE':
      case 'DISBURSED':
        return cs.secondary;
      case 'PENDING':
      case 'INCOMPLETE':
      case 'IN_PROGRESS':
        return cs.tertiary;
      case 'REJECTED':
      case 'DEFAULTED':
      case 'OVERDUE':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final color = _color(cs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.toUpperCase(),
        style: context.labelSmall.bold.copyWith(
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
