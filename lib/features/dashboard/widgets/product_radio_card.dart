import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/dashboard/widgets/info_stats.dart';
import 'package:pesa_lending/features/dashboard/widgets/inline_slider.dart';

class ProductRadioCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  // Expansion props — only meaningful when isSelected = true
  final double amount;
  final bool isCalculating;
  final Map<String, dynamic>? calculation;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const ProductRadioCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.amount,
    required this.isCalculating,
    required this.calculation,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final minA = (product['minAmount'] as num).toDouble();
    final maxA = (product['maxAmount'] as num).toDouble();
    final maxDays = (product['maxTermDays'] as num?)?.toInt() ?? 30;
    final minDays = (product['minTermDays'] as num?)?.toInt() ?? 7;

    // Header text colours flip when card is selected (dark bg)
    final titleColor = isSelected ? Colors.white : cs.onSurface;
    final labelColor = isSelected ? Colors.white.withValues(alpha: 0.65) : cs.onSurfaceVariant;
    final valueColor = isSelected ? Colors.white : cs.onSurface;
    final category = (product['category'] as String?)?.toUpperCase() ?? '';
    final riskBand = (product['riskBand'] as String?) ?? '';
    final eligible = (product['eligible'] as bool?) ?? true;
    final recommendation = (product['creditRecommendation'] as String?) ?? '';
    final recommendedAmount = (product['recommendedAmount'] as num?)?.toDouble();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF0D2456), Color(0xFF1141A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isSelected ? null : Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row (always visible) ─────────────────
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kiasi: Tsh ${_fmt(minA)} - Tsh ${_fmt(maxA)}',
                          style: context.titleSmall.copyWith(color: titleColor),
                        ),
                        if (category.isNotEmpty || riskBand.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${category.isNotEmpty ? category : ''}${category.isNotEmpty && riskBand.isNotEmpty ? ' • ' : ''}${riskBand.isNotEmpty ? 'Risk: $riskBand' : ''}',
                            style: context.bodySmall.copyWith(color: labelColor),
                          ),
                        ],
                        if (!eligible && product['reasonIfNotEligible'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            product['reasonIfNotEligible'].toString(),
                            style: context.bodySmall.copyWith(color: Colors.redAccent),
                          ),
                        ],
                        if (recommendedAmount != null && eligible) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Pendekezo: Tsh ${_fmt(recommendedAmount)}${recommendation.isNotEmpty ? ' • $recommendation' : ''}',
                            style: context.bodySmall.copyWith(color: labelColor),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            InfoStat(
                              label: 'Muda wa mkopo',
                              value: minDays == maxDays ? '$maxDays Siku' : '$minDays–$maxDays Siku',
                              labelColor: labelColor,
                              valueColor: valueColor,
                            ),
                            const SizedBox(width: 24),
                            InfoStat(
                              label: 'Riba kwa mwezi',
                              value: '${((product['monthlyInterestRate'] as num? ?? 0) * 100).toStringAsFixed(1)}%',
                              labelColor: labelColor,
                              valueColor: valueColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : cs.outlineVariant,
                        width: 2,
                      ),
                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                ],
              ),
            ),
          ),

          // ── Inline expansion (slides open when selected) ─
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            child: isSelected
                ? InlineSlider(
                    product: product,
                    amount: amount,
                    isCalculating: isCalculating,
                    calculation: calculation,
                    onChanged: onChanged,
                    onChangeEnd: onChangeEnd,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn(duration: 350.ms).slideY(begin: 0.08);
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}
