import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class CalcChip extends StatelessWidget {
  final String label;
  final String value;

  const CalcChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: context.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.65))),
          const SizedBox(height: 3),
          Text(value, style: context.bodySmall.bold.copyWith(color: Colors.white)),
        ],
      );
}
