import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/shared/components/buttons/app_primary_button.dart';
import 'package:pesa_lending/shared/components/buttons/app_secondary_button.dart';

class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ConfirmationSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              title,
              style: context.titleLarge.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: confirmLabel,
              isLoading: context.stateWatch<KycProvider>().isSubmitting,
              onPressed: () {
                context.stateRead<KycProvider>().completeKyc();

                context.pop(true);
              },
            ),
            const SizedBox(height: 12),
            AppSecondaryButton(
              label: cancelLabel,
              onPressed: () => context.pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
