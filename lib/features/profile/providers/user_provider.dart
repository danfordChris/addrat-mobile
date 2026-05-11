import 'package:pesa_lending/models/user_model.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

class UserProvider extends BaseProvider {
  bool? _isLoading;
  bool get isLoading => _isLoading ?? false;

  UserModel? _user;
  UserModel? get user => _user;

  String? _error;
  String? get error => _error;

  void setLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void setLoaded(UserModel user) {
    _user = user;
    _isLoading = false;
    notifyListeners();
  }

  void setFailure(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }
}
