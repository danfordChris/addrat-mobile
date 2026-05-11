enum OtpPurpose {
  registration('REGISTRATION'),
  login('LOGIN'),
  transaction('TRANSACTION'),
  passwordReset('PASSWORD_RESET');

  const OtpPurpose(this.value);
  final String value;
}
