import 'package:pesa_lending/features/auth/preference/auth_preference.dart';
import 'package:pesa_lending/core/preferences/preferences_service.dart';

class Preferences {
  Preferences._();

  static final Preferences instance = Preferences._();

  Future<void> get logoutUser async {
    await AuthPreference.instance.logoutUser;
    await PreferencesService.instance.clearAll();
  }
}
