import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class SliderCard extends StatelessWidget {
  final String label, displayValue, minLabel, maxLabel;
  final Color valueColor;
  final IconData icon;
  final double min, max, value;
  final int divisions;
  final ValueChanged<double> onChanged;

  const SliderCard({
    required this.label,
    required this.displayValue,
    required this.valueColor,
    required this.icon,
    required this.min,
    required this.max,
    required this.value,
    required this.divisions,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            HugeIcon(icon: icon, color: valueColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: context.labelMedium.copyWith(color: cs.onSurfaceVariant)),
          ]),
          const SizedBox(height: 10),
          Center(
            child: Text(displayValue, style: context.displayLarge.copyWith(color: valueColor)),
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: valueColor,
              inactiveTrackColor: cs.surfaceContainer,
              thumbColor: valueColor,
              overlayColor: valueColor.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: context.labelSmall.copyWith(color: cs.onSurfaceVariant)),
              Text(maxLabel, style: context.labelSmall.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
