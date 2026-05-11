import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/dashboard/widgets/result_row.dart';
import 'package:pesa_lending/shared/widgets/shared_widgets.dart';

class CalcResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const CalcResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final disbursed = (result['disbursedAmount'] as num).toDouble();
    final interest = (result['totalInterest'] as num).toDouble();
    final fee = (result['processingFee'] as num).toDouble();
    final total = (result['totalRepayable'] as num).toDouble();
    final apr = result['effectiveAprPct'];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1141A8), cs.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Column(
              children: [
                Text('Utapata', style: context.bodySmall.medium.copyWith(color: Colors.white.withValues(alpha: 0.65))),
                const SizedBox(height: 6),
                Text(disbursed.tzs, style: context.displaySmall.extraBold.copyWith(color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('kwenye simu yako', style: context.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ResultRow(icon: HugeIcons.strokeRoundedPercentCircle, label: 'Riba', value: interest.tzs, iconColor: cs.tertiary),
                const SizedBox(height: 10),
                ResultRow(icon: HugeIcons.strokeRoundedMoneyBag01, label: 'Ada ya Usindikaji', value: fee.tzs, iconColor: cs.onSurfaceVariant),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: cs.outlineVariant, height: 1),
                ),
                ResultRow(
                    icon: HugeIcons.strokeRoundedMoneySend01, label: 'Jumla ya Kulipa', value: total.tzs, iconColor: cs.secondary, isBold: true),
                const SizedBox(height: 10),
                ResultRow(icon: HugeIcons.strokeRoundedPercentSquare, label: 'APR (mwaka)', value: '$apr%', iconColor: cs.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
