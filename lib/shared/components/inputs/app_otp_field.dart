import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class AppOtpField extends StatelessWidget {
  const AppOtpField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.hasError = false,
    this.autoFocus = true,
    this.onChanged,
  });

  final int length;
  final void Function(String) onCompleted;
  final bool hasError;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return PinCodeTextField(
      appContext: context,
      length: length,
      autoFocus: autoFocus,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      onCompleted: onCompleted,
      onChanged: onChanged ?? (_) {},
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(AppRadius.md),
        fieldHeight: 56,
        fieldWidth: 48,
        activeFillColor: cs.surfaceContainer,
        inactiveFillColor: cs.surfaceContainer,
        selectedFillColor: cs.surfaceContainerHighest,
        activeColor: hasError ? cs.error : cs.primary,
        inactiveColor: hasError ? cs.error : cs.outlineVariant,
        selectedColor: hasError ? cs.error : cs.primary,
      ),
      enableActiveFill: true,
      textStyle: context.titleMedium.bold.copyWith(color: cs.onSurface),
      cursorColor: cs.primary,
    );
  }
}
