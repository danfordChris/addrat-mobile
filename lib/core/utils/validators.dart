class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final valid = (digits.length == 9 && RegExp(r'^[67]').hasMatch(digits)) ||
        (digits.length == 10 && digits.startsWith('0') && RegExp(r'^0[67]').hasMatch(digits)) ||
        (digits.length == 12 && digits.startsWith('255') && RegExp(r'^255[67]').hasMatch(digits));
    return valid ? null : 'Enter a valid Tanzanian phone number';
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) return 'Enter a valid 6-digit OTP';
    return null;
  }

  static String? accountNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Account number is required';
    if (value.trim().length < 10) return 'Account number must be at least 10 digits';
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) return 'Account number must contain digits only';
    return null;
  }

  static String? tinNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^\d{9}$').hasMatch(value.trim())) return 'TIN must be 9 digits';
    return null;
  }
}
