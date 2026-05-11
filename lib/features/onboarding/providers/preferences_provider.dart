import 'package:pesa_lending/core/preferences/app_preferences.dart';
import 'package:pesa_lending/core/preferences/preferences_service.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

class PreferencesProvider extends BaseProvider {
  AppPreferences _prefs = const AppPreferences();
  AppPreferences get prefs => _prefs;

  String get selectedLanguage => _prefs.selectedLanguage;
  bool get hasSeenOnboarding => _prefs.hasSeenOnboarding;
  String? get kycStatus => _prefs.kycStatus;
  String get themeMode => _prefs.themeMode;

  Future<void> load() async {
    _prefs = AppPreferences(
      selectedLanguage: await PreferencesService.instance.getLanguage(),
      hasSeenOnboarding: await PreferencesService.instance.getHasSeenOnboarding(),
      kycStatus: await PreferencesService.instance.getKycStatus(),
      themeMode: await PreferencesService.instance.getThemeMode(),
    );
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    await PreferencesService.instance.setLanguage(code);
    _prefs = _prefs.copyWith(selectedLanguage: code);
    notifyListeners();
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await PreferencesService.instance.setHasSeenOnboarding(value);
    _prefs = _prefs.copyWith(hasSeenOnboarding: value);
    notifyListeners();
  }

  Future<void> setKycStatus(String status) async {
    await PreferencesService.instance.setKycStatus(status);
    _prefs = _prefs.copyWith(kycStatus: status);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    await PreferencesService.instance.setThemeMode(mode);
    _prefs = _prefs.copyWith(themeMode: mode);
    notifyListeners();
  }

  Future<void> clear() async {
    await PreferencesService.instance.clearAll();
    _prefs = const AppPreferences();
    notifyListeners();
  }
}
