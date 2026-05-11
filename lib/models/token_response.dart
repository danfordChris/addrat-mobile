class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String fullName;
  final String kycStatus;
  final String creditLimit;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.userId = '',
    this.fullName = '',
    this.kycStatus = 'NOT_STARTED',
    this.creditLimit = '0',
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return TokenResponse(
      accessToken: json['accessToken'] ,
      refreshToken: json['refreshToken'] ,
      userId: user['id']  ?? '',
      fullName: user['fullName']  ?? '',
      kycStatus: user['kycStatus']  ?? 'NOT_STARTED',
      creditLimit: user['creditLimit']  ?? '0',
    );
  }
}
