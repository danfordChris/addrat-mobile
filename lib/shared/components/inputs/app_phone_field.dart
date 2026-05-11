import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/core/utils/formatters.dart';

class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: errorText != null ? cs.error : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Text('🇹🇿', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '+255',
                      style: context.bodyLarge.medium.copyWith(color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: cs.outlineVariant),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  onChanged: onChanged,
                  style: context.bodyLarge.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    hintText: '7XX XXX XXX',
                    hintStyle: context.bodyLarge.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: context.bodySmall.copyWith(color: cs.error),
            ),
          ),
      ],
    );
  }
}
