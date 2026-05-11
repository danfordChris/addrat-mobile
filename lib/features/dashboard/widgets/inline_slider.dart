import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/extensions/extensions.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/dashboard/widgets/calc_chip.dart';

class InlineSlider extends StatelessWidget {
  final Map<String, dynamic> product;
  final double amount;
  final bool isCalculating;
  final Map<String, dynamic>? calculation;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const InlineSlider({
    required this.product,
    required this.amount,
    required this.isCalculating,
    required this.calculation,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final minA = (product['minAmount'] as num).toDouble();
    final maxA = (product['maxAmount'] as num).toDouble();
    final clamped = amount.clamp(minA, maxA);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 16),

          // Amount label + display
          Align(
            alignment: Alignment.center,
            child: Text(
              'Chagua kiasi cha mkopo (Tsh)',
              style: context.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.center,
            child: Text(
              _fmtAmount(clamped),
              style: context.displaySmall.extraBold.copyWith(color: Colors.white, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 10),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: clamped,
              min: minA,
              max: maxA,
              divisions: ((maxA - minA) / 1000).round().clamp(1, 200),
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tsh ${_compact(minA)}', style: context.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
              Text('Tsh ${_compact(maxA)}', style: context.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),

          // Calculation summary
          if (isCalculating) ...[
            const SizedBox(height: 14),
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
          ] else if (calculation != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CalcChip(
                    label: 'Utapata',
                    value: (calculation!['disbursedAmount'] as num).toTZSCompact(),
                  ),
                  CalcChip(
                    label: 'Kulipa',
                    value: (calculation!['totalRepayable'] as num).toTZSCompact(),
                  ),
                  CalcChip(
                    label: 'APR',
                    value: '${calculation!['effectiveAprPct']}%',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtAmount(double v) {
    if (v >= 1000000) {
      return 'TZS ${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      return 'TZS ${(v / 1000).toStringAsFixed(0)},000';
    }
    return 'TZS ${v.toStringAsFixed(0)}';
  }

  String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}
