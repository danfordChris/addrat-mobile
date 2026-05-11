import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class ApplyButton extends StatelessWidget {
  final Map<String, dynamic> calc;
  final Map<String, dynamic>? product;
  final double amount, term;

  const ApplyButton({
    required this.calc,
    required this.product,
    required this.amount,
    required this.term,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return GestureDetector(
      onTap: () => context.push(AppRoute.loansApply.path, extra: {
        ...calc,
        'productId': product?['id'],
        'productName': product?['name'] ?? 'Mkopo',
        'amount': amount,
        'termDays': term.toInt(),
      }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, const Color(0xFF4F8EFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppShadows.button,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedCreditCard, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Omba Mkopo Huu', style: context.labelLarge.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
