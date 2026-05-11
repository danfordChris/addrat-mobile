import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/components/buttons/app_primary_button.dart';

class SubmissionSuccessSheet extends StatelessWidget {
  const SubmissionSuccessSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: context.colorScheme.secondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, color: context.colorScheme.secondary, size: 40),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'KYC Submitted!',
          style: context.titleLarge.copyWith(color: context.colorScheme.onSurface),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your application is under review.\nWe\'ll notify you within 1-2 business days.',
          style: context.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: 'Go to Home',
          onPressed: onDone,
        ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 400.ms),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
