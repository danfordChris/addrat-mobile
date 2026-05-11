import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class AuthPrefKeys {
  AuthPrefKeys._();
  static const String phoneNumber = "phone_number";
  static const String apiToken = "api_token";
  static const String apiRefreshToken = "api_refresh_token";
  static const String userPin = "user_pin";
  static const String userId = "user_id";
  static const String fullName = "full_name";
  static const String kycStatus = "kyc_status";
  static const String creditLimit = "credit_limit";
}

class AuthPreference extends BasePreferences {
  AuthPreference._();
  static final AuthPreference _instance = AuthPreference._();
  static AuthPreference get instance => _instance;

  Future<String?> get phoneNumber async => await fetch<String?>(AuthPrefKeys.phoneNumber);
  Future<String?> get apiToken async => await fetch<String?>(AuthPrefKeys.apiToken);
  Future<String?> get apiRefreshToken async => await fetch<String?>(AuthPrefKeys.apiRefreshToken);
  Future<String?> get userPin async => await fetch<String?>(AuthPrefKeys.userPin);
  Future<String?> get userId async => await fetch<String?>(AuthPrefKeys.userId);
  Future<String?> get fullName async => await fetch<String?>(AuthPrefKeys.fullName);
  Future<String?> get kycStatus async => await fetch<String?>(AuthPrefKeys.kycStatus);
  Future<String?> get creditLimit async => await fetch<String?>(AuthPrefKeys.creditLimit);

  Future<void> get logoutUser async {
    remove(AuthPrefKeys.apiToken);
    remove(AuthPrefKeys.apiRefreshToken);
    remove(AuthPrefKeys.userPin);
    remove(AuthPrefKeys.userId);
    remove(AuthPrefKeys.fullName);
    remove(AuthPrefKeys.kycStatus);
    remove(AuthPrefKeys.creditLimit);
  }
}
