import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/components/navigation/app_back_button.dart';

class KycHeader extends StatelessWidget {
  const KycHeader({super.key, required this.onBack, required this.title});

  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          AppBackButton(onPressed: onBack),
          const SizedBox(width: AppSpacing.md),
          Text(title, style: context.bodyLarge.copyWith(color: context.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
