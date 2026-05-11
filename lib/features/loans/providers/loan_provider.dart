import 'package:pesa_lending/features/loans/service/loan_api_service.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

class LoanProvider extends BaseProvider {
  bool? _isLoading;
  bool get isLoading => _isLoading ?? false;

  bool? _isSubmitting;
  bool get isSubmitting => _isSubmitting ?? false;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> get products => _products;

  Map<String, dynamic>? _calculation;
  Map<String, dynamic>? get calculation => _calculation;

  Map<String, dynamic>? _currentLoan;
  Map<String, dynamic>? get currentLoan => _currentLoan;

  List<Map<String, dynamic>> _myLoans = [];
  List<Map<String, dynamic>> get myLoans => _myLoans;

  String? _error;
  String? get error => _error;

  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;
    try {
      _products = await LoanApiService.products;
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> calculate(Map<String, dynamic> params) async {
    _setLoading(true);
    _error = null;
    try {
      _calculation = await LoanApiService.calculate(params);
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> applyLoan(Map<String, dynamic> params) async {
    _setSubmitting(true);
    _error = null;
    try {
      final res = await LoanApiService.apply(params);
      _currentLoan = res;
      return res;
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<Map<String, dynamic>> acceptLoan(String loanId, String pin) async {
    _setSubmitting(true);
    _error = null;
    try {
      final res = await LoanApiService.accept(loanId, pin);
      _currentLoan = res;
      return res;
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> loadMyLoans() async {
    _setLoading(true);
    _error = null;
    try {
      _myLoans = await LoanApiService.getMyLoans();
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLoan(String loanId) async {
    _setLoading(true);
    _error = null;
    try {
      _currentLoan = await LoanApiService.getLoan(loanId);
    } catch (e) {
      _error = e.toString();
      SessionManager.showError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> loadActiveLoan() async {
    try {
      return await LoanApiService.activeLoan;
    } catch (e) {
      return null;
    }
  }

  void clearCalculation() {
    _calculation = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
