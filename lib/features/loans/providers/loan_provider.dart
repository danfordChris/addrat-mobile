import 'package:pesa_lending/features/loans/service/loan_api_service.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';
import 'dart:async';

class LoanProvider extends BaseProvider {
  static const Duration _pollInterval = Duration(seconds: 20);
  static const Duration _streamReconnectDelay = Duration(seconds: 5);

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

  StreamSubscription<Map<String, dynamic>>? _loanEventSub;
  Timer? _pollTimer;
  Timer? _reconnectTimer;
  String? _trackedLoanId;

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

  Future<void> startLoanTracking(String loanId) async {
    stopLoanTracking();
    _trackedLoanId = loanId;
    await loadLoan(loanId);
    _startPolling(loanId);
    _connectEventStream(loanId);
  }

  void stopLoanTracking() {
    _trackedLoanId = null;
    _loanEventSub?.cancel();
    _loanEventSub = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
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

  void _startPolling(String loanId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (_trackedLoanId != loanId) return;
      await _loadLoanSilently(loanId);
    });
  }

  void _connectEventStream(String loanId) {
    _loanEventSub?.cancel();
    _loanEventSub = LoanApiService.streamLoanEvents(loanId).listen(
      (event) async {
        if (_trackedLoanId != loanId) return;
        final data = event['data'];
        final eventType = (event['event'] ?? '').toString();
        if (eventType == 'HEARTBEAT' ||
            (data is Map && data['type'] == 'HEARTBEAT')) {
          return;
        }
        await _loadLoanSilently(loanId);
      },
      onError: (_) => _scheduleReconnect(loanId),
      onDone: () => _scheduleReconnect(loanId),
      cancelOnError: true,
    );
  }

  void _scheduleReconnect(String loanId) {
    if (_trackedLoanId != loanId) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_streamReconnectDelay, () {
      if (_trackedLoanId == loanId) {
        _connectEventStream(loanId);
      }
    });
  }

  Future<void> _loadLoanSilently(String loanId) async {
    try {
      _currentLoan = await LoanApiService.getLoan(loanId);
      _error = null;
      notifyListeners();
    } catch (_) {
      // Keep silent retries to avoid noisy toasts during transient outages.
    }
  }
}
