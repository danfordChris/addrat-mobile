import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class InfoStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const InfoStat({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelSmall.copyWith(color: labelColor ?? cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: context.bodyMedium.bold.copyWith(color: valueColor ?? cs.onSurface)),
      ],
    );
  }
}
