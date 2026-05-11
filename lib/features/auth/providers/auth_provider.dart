import 'package:pesa_lending/services/storage_service.dart';
import 'package:pesa_lending/core/utils/formatters.dart';
import 'package:pesa_lending/features/auth/service/auth_api_service.dart';
import 'package:pesa_lending/features/kyc/service/kyc_api_service.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/enums/kyc_status_enum.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

class AuthProvider extends BaseProvider {
  bool? _isLoading;
  bool get isLoading => _isLoading ?? false;

  bool? _isAuthenticated;
  bool get isAuthenticated => _isAuthenticated ?? false;

  String? _userId;
  String? get userId => _userId;

  String? _phone;
  String? get phone => _phone;

  String? _fullName;
  String? get fullName => _fullName;

  String? _kycStatus;
  String? get kycStatus => _kycStatus;

  String? _creditLimit;
  String? get creditLimit => _creditLimit;

  String? _error;
  String? get error => _error;

  Future<void> checkAuth() async {
    final loggedIn = await StorageService.isLoggedIn();
    if (loggedIn) {
      _isAuthenticated = true;
      _userId = await StorageService.getUserId();
      _phone = await StorageService.getPhone();
      _fullName = await StorageService.getFullName();
      _kycStatus = await StorageService.getKycStatus();
      _creditLimit = await StorageService.getCreditLimit();
      notifyListeners();
    }
  }

  Future<void> refreshFromServer() async {
    final loggedIn = await StorageService.isLoggedIn();
    if (!loggedIn) return;
    try {
      final res = await AuthApiService.profile;
      final user = res; // mapData is directly returned from AuthApiService.profile
      _kycStatus = user['kycStatus'] as String? ?? _kycStatus ?? KycStatus.notStarted.value;
      _creditLimit = user['creditLimit']?.toString() ?? _creditLimit ?? '0';
      _fullName = user['fullName'] as String? ?? _fullName ?? '';
      _userId = user['id'] as String? ?? _userId ?? '';
      
      await StorageService.saveUserInfo(
        userId: _userId!,
        phone: _phone ?? '',
        fullName: _fullName!,
        kycStatus: _kycStatus!,
        creditLimit: _creditLimit!,
      );
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      // Silent
    }
  }

  Future<void> register(String phone, String fullName, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final normalizedPhone = normalizeTzPhoneNumber(phone);
      await AuthApiService.register({
        'phoneNumber': normalizedPhone,
        'fullName': fullName,
        'password': password
      });
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String phone, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final normalizedPhone = normalizeTzPhoneNumber(phone);
      final res = await AuthApiService.login({
        'phoneNumber': normalizedPhone,
        'password': password
      });
      await _saveSession(res);
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendOtp(String phone, String purpose) async {
    _setLoading(true);
    _error = null;
    try {
      await AuthApiService.requestOtp(normalizeTzPhoneNumber(phone), purpose);
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp(String phone, String otp, String purpose) async {
    _setLoading(true);
    _error = null;
    try {
      final normalizedPhone = normalizeTzPhoneNumber(phone);
      final res = await AuthApiService.verifyOtp({
        'phoneNumber': normalizedPhone,
        'otp': otp,
        'purpose': purpose
      });
      await _saveSession(res);
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setPin(String pin) async {
    _setLoading(true);
    _error = null;
    try {
      await AuthApiService.setPin(pin);
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitKyc(String nida, String employment, double income) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await KycApiService.submitKyc({
        'nidaNumber': nida,
        'employmentType': employment,
        'monthlyIncome': income,
      });
      _kycStatus = res['kycStatus'] as String;
      _creditLimit = res['creditLimit']?.toString() ?? '0';
      await StorageService.updateKycStatus(_kycStatus!);
      await StorageService.updateCreditLimit(_creditLimit!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await StorageService.clearSession();
    _isAuthenticated = false;
    _userId = null;
    _phone = null;
    _fullName = null;
    _kycStatus = null;
    _creditLimit = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    String accessToken = data['accessToken'];
    String refreshToken = data['refreshToken'];
    await StorageService.saveTokens(accessToken, refreshToken);
    
    final user = data['user'] as Map<String, dynamic>;
    _userId = user['id'];
    _phone = user['phoneNumber'];
    _fullName = user['fullName'];
    _kycStatus = user['kycStatus'];
    _creditLimit = user['creditLimit']?.toString();

    await StorageService.saveUserInfo(
      userId: _userId!,
      phone: _phone!,
      fullName: _fullName ?? '',
      kycStatus: _kycStatus ?? '',
      creditLimit: _creditLimit ?? '0',
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
