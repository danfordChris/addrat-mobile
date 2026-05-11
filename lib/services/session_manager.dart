import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/models/user_model.dart';
import 'package:pesa_lending/shared/components/feedback/app_snackbar.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager _instance = SessionManager._();

  static SessionManager get instance => _instance;

  UserModel? _user;
  UserModel? get user => _user;

  void setUser(UserModel? user) {
    _user = user;
  }

  static void handleError(Object exception) {
    _handleError(exception);
  }

  static void showError(Object exception) {
    _handleError(exception);
  }

  static void _handleError(Object exception) {
    final formattedError = exception.toString().replaceAll('Exception: ', '');
    AppUtility.log(formattedError);
    AppSnackbar.error(formattedError);
  }
}
