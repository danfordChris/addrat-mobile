import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessToken = 'access_token';
  static const _refreshToken = 'refresh_token';
  static const _userId = 'user_id';
  static const _kycStatus = 'kyc_status';
  static const _creditLimit = 'credit_limit';
  static const _fullName = 'full_name';
  static const _phone = 'phone_number';

  // ── Tokens ─────────────────────────────────────────────────
  static Future<void> saveTokens(String access, String refresh) async {
    AppUtility.log('Saving tokens...');
    AppUtility.log('Access: $access');
    AppUtility.log('Refresh: $refresh');
    await Future.wait([
      _storage.write(key: _accessToken, value: access),
      _storage.write(key: _refreshToken, value: refresh),
    ]);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessToken);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshToken);

  // ── User info ──────────────────────────────────────────────
  static Future<void> saveUserInfo({
    required String userId,
    required String phone,
    required String fullName,
    required String kycStatus,
    required String creditLimit,
  }) async {
    await Future.wait([
      _storage.write(key: _userId, value: userId),
      _storage.write(key: _phone, value: phone),
      _storage.write(key: _fullName, value: fullName),
      _storage.write(key: _kycStatus, value: kycStatus),
      _storage.write(key: _creditLimit, value: creditLimit),
    ]);
  }

  static Future<String?> getUserId() => _storage.read(key: _userId);
  static Future<String?> getFullName() => _storage.read(key: _fullName);
  static Future<String?> getPhone() => _storage.read(key: _phone);
  static Future<String?> getKycStatus() => _storage.read(key: _kycStatus);
  static Future<String?> getCreditLimit() => _storage.read(key: _creditLimit);

  static Future<void> updateKycStatus(String status) =>
      _storage.write(key: _kycStatus, value: status);
  static Future<void> updateCreditLimit(String limit) =>
      _storage.write(key: _creditLimit, value: limit);

  // ── Session ────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    AppUtility.log('Token: $token');
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() => _storage.deleteAll();
}
