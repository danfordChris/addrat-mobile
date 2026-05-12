import 'package:pesa_lending/core/preferences/app_preferences.dart';
import 'package:pesa_lending/core/preferences/preferences_service.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

class PreferencesProvider extends BaseProvider {
  AppPreferences _prefs = const AppPreferences();
  AppPreferences get prefs => _prefs;

  String? _error;
  String? get error => _error;

  String get selectedLanguage => _prefs.selectedLanguage;
  bool get hasSeenOnboarding => _prefs.hasSeenOnboarding;
  String? get kycStatus => _prefs.kycStatus;
  String get themeMode => _prefs.themeMode;

  Future<void> load() async {
    _error = null;
    try {
      _prefs = AppPreferences(
        selectedLanguage: await PreferencesService.instance.getLanguage(),
        hasSeenOnboarding: await PreferencesService.instance.getHasSeenOnboarding(),
        kycStatus: await PreferencesService.instance.getKycStatus(),
        themeMode: await PreferencesService.instance.getThemeMode(),
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.handleError(e);
    }
  }

  Future<void> setLanguage(String code) async {
    _error = null;
    try {
      await PreferencesService.instance.setLanguage(code);
      _prefs = _prefs.copyWith(selectedLanguage: code);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.handleError(e);
    }
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _error = null;
    try {
      await PreferencesService.instance.setHasSeenOnboarding(value);
      _prefs = _prefs.copyWith(hasSeenOnboarding: value);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.handleError(e);
    }
  }

  Future<void> setKycStatus(String status) async {
    _error = null;
    try {
      await PreferencesService.instance.setKycStatus(status);
      _prefs = _prefs.copyWith(kycStatus: status);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.handleError(e);
    }
  }

  Future<void> setThemeMode(String mode) async {
    _error = null;
    try {
      await PreferencesService.instance.setThemeMode(mode);
      _prefs = _prefs.copyWith(themeMode: mode);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.handleError(e);
    }
  }

  Future<void> clear() async {
    _error = null;
    try {
      await PreferencesService.instance.clearAll();
      _prefs = const AppPreferences();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.handleError(e);
    }
  }
}
