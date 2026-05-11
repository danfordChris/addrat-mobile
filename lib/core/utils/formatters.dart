import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 9 ? digits.substring(0, 9) : digits;
    return newValue.copyWith(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

String normalizeTzPhoneNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');

  if (digits.length == 12 && digits.startsWith('255')) {
    return '+$digits';
  }

  if (digits.length == 10 &&
      digits.startsWith('0') &&
      RegExp(r'^0[67]').hasMatch(digits)) {
    return '+255${digits.substring(1)}';
  }

  if (digits.length == 9 && RegExp(r'^[67]').hasMatch(digits)) {
    return '+255$digits';
  }

  return value.trim();
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
