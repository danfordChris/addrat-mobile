import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/shared/components/badges/status_badge.dart';
import 'package:pesa_lending/shared/components/cards/app_card.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loanId,
    required this.status,
    required this.principalAmount,
    required this.outstandingAmount,
    this.nextDueDate,
    this.onTap,
  });

  final String loanId;
  final String status;
  final double principalAmount;
  final double outstandingAmount;
  final DateTime? nextDueDate;
  final VoidCallback? onTap;

  static final _fmt =
      NumberFormat.currency(locale: 'en_TZ', symbol: 'TZS ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loan Amount', style: context.bodySmall),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _fmt.format(principalAmount),
            style: context.headlineSmall.bold.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outstanding', style: context.bodySmall),
                    Text(
                      _fmt.format(outstandingAmount),
                      style: context.bodyMedium.semiBold.copyWith(color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              if (nextDueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Due Date', style: context.bodySmall),
                    Text(
                      DateFormat('dd MMM yyyy').format(nextDueDate!),
                      style: context.bodyMedium.semiBold.copyWith(color: cs.tertiary),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
