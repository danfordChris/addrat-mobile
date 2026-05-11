import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  static const _keyLanguage = 'app_selected_language';
  static const _keyOnboarding = 'app_has_seen_onboarding';
  static const _keyKycStatus = 'app_kyc_status';
  static const _keyThemeMode = 'app_theme_mode';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String> getLanguage() async =>
      (await _prefs).getString(_keyLanguage) ?? 'en';

  Future<void> setLanguage(String code) async =>
      (await _prefs).setString(_keyLanguage, code);

  Future<bool> getHasSeenOnboarding() async =>
      (await _prefs).getBool(_keyOnboarding) ?? false;

  Future<void> setHasSeenOnboarding(bool value) async =>
      (await _prefs).setBool(_keyOnboarding, value);

  Future<String?> getKycStatus() async =>
      (await _prefs).getString(_keyKycStatus);

  Future<void> setKycStatus(String status) async =>
      (await _prefs).setString(_keyKycStatus, status);

  Future<void> clearKycStatus() async =>
      (await _prefs).remove(_keyKycStatus);

  Future<String> getThemeMode() async =>
      (await _prefs).getString(_keyThemeMode) ?? 'system';

  Future<void> setThemeMode(String mode) async =>
      (await _prefs).setString(_keyThemeMode, mode);

  Future<void> clearAll() async => (await _prefs).clear();
}
