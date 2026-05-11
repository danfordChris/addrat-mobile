extension StringExt on String {
  String toTitleCase() => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  String maskedPhone() {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return this;
    final prefix = digits.substring(0, digits.length - 9);
    final last3 = digits.substring(digits.length - 3);
    return '${prefix.isEmpty ? '' : '+$prefix '}${digits[digits.length - 9]}XX XXX $last3';
  }

  bool isValidTanzanianPhone() {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('255')) {
      return RegExp(r'^255[67]\d{8}$').hasMatch(digits);
    }
    if (digits.length == 10 && digits.startsWith('0')) {
      return RegExp(r'^0[67]\d{8}$').hasMatch(digits);
    }
    if (digits.length == 9) {
      return RegExp(r'^[67]\d{8}$').hasMatch(digits);
    }
    return false;
  }

  String initials() {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
