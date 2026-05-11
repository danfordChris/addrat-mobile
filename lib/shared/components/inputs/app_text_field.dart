import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.validator,
    this.enabled = true,
    this.inputFormatters,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    Widget? effectiveSuffix = suffixIcon;
    if (readOnly && suffixIcon == null) {
      effectiveSuffix = Icon(Icons.lock_outline, size: 18, color: cs.onSurfaceVariant);
    }

    return Opacity(
      opacity: readOnly ? 0.6 : 1.0,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        onChanged: onChanged,
        onTap: onTap,
        focusNode: focusNode,
        validator: validator,
        enabled: enabled,
        inputFormatters: inputFormatters,
        style: context.bodyLarge.copyWith(color: cs.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: effectiveSuffix,
        ),
      ),
    );
  }
}
