import 'package:pesa_lending/core/utils/error_utils.dart';
import 'package:pesa_lending/features/loans/services/loans_api_service.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

const _kUseDummyData = true;

const _dummyProducts = <Map<String, dynamic>>[
  {
    'id': 'prod-1',
    'productCode': 'MKOPO_HARAKA',
    'name': 'Mkopo Haraka',
    'description': 'Mkopo wa haraka kwa mahitaji ya kawaida',
    'minAmount': 5000.0,
    'maxAmount': 800000.0,
    'minTermDays': 91,
    'maxTermDays': 91,
    'monthlyInterestRate': 0.05,
  },
  {
    'id': 'prod-2',
    'productCode': 'BIASHARA',
    'name': 'Mkopo wa Biashara',
    'description': 'Mkopo wa kukuza biashara yako',
    'minAmount': 5000.0,
    'maxAmount': 800000.0,
    'minTermDays': 120,
    'maxTermDays': 120,
    'monthlyInterestRate': 0.04,
  },
  {
    'id': 'prod-3',
    'productCode': 'KILIMO',
    'name': 'Mkopo wa Kilimo',
    'description': 'Mkopo kwa wakulima na kilimo',
    'minAmount': 10000.0,
    'maxAmount': 200000.0,
    'minTermDays': 180,
    'maxTermDays': 180,
    'monthlyInterestRate': 0.03,
  },
];

class LoanNotifier extends BaseProvider {
  final _loansApi = LoansApiService.instance;

  bool? _isLoading;
  bool get isLoading => _isLoading ?? false;

  bool? _isSubmitting;
  bool get isSubmitting => _isSubmitting ?? false;

  List<Map<String, dynamic>> products = [];
  Map<String, dynamic>? calculation;
  Map<String, dynamic>? currentLoan;
  List<Map<String, dynamic>> myLoans = [];
  String? error;

  Future<void> loadProducts() async {
    _setLoading(true);
    if (_kUseDummyData) {
      await Future.delayed(const Duration(milliseconds: 600));
      products = List<Map<String, dynamic>>.from(_dummyProducts);
      _setLoading(false);
      return;
    }
    try {
      final res = await _loansApi.getLoanProducts();
      products = List<Map<String, dynamic>>.from(res['data']);
      error = null;
    } catch (e) {
      error = userMessage(e);
    }
    _setLoading(false);
  }

  Future<void> calculate(Map<String, dynamic> params) async {
    _setLoading(true);
    if (_kUseDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final amount   = (params['amount'] as num).toDouble();
      final termDays = (params['termDays'] as num).toInt();
      final prod = _dummyProducts.firstWhere(
        (p) => p['id'] == params['productId'],
        orElse: () => _dummyProducts.first,
      );
      final rate     = (prod['monthlyInterestRate'] as num).toDouble();
      final interest = amount * rate * (termDays / 30);
      final fee      = amount * 0.02;
      final total    = amount + interest + fee;
      final disbursed = amount - fee;
      final apr = ((interest / amount) * (365 / termDays) * 100).toStringAsFixed(1);
      calculation = {
        'disbursedAmount': disbursed,
        'totalInterest': interest,
        'processingFee': fee,
        'totalRepayable': total,
        'effectiveAprPct': apr,
      };
      _setLoading(false);
      return;
    }
    try {
      final res = await _loansApi.calculateLoan(params);
      calculation = res['data'] as Map<String, dynamic>;
      error = null;
    } catch (e) {
      error = userMessage(e);
    }
    _setLoading(false);
  }

  Future<Map<String, dynamic>> applyLoan(Map<String, dynamic> params) async {
    _setSubmitting(true);
    if (_kUseDummyData) {
      await Future.delayed(const Duration(milliseconds: 800));
      final stub = <String, dynamic>{
        'id': 'loan-dummy-001',
        'status': 'APPROVED',
        'principalAmount': params['amount'],
        'loanNumber': 'LN-2026-001',
        'termDays': params['termDays'],
        'purpose': params['purpose'] ?? '',
      };
      currentLoan = stub;
      _setSubmitting(false);
      return stub;
    }
    try {
      final res = await _loansApi.applyLoan(params);
      currentLoan = res['data'] as Map<String, dynamic>;
      _setSubmitting(false);
      return currentLoan!;
    } catch (e) {
      error = userMessage(e);
      _setSubmitting(false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptLoan(String loanId, String pin) async {
    _setSubmitting(true);
    try {
      final res = await _loansApi.acceptLoan(loanId, pin);
      currentLoan = res['data'] as Map<String, dynamic>;
      _setSubmitting(false);
      return currentLoan!;
    } catch (e) {
      error = userMessage(e);
      _setSubmitting(false);
      rethrow;
    }
  }

  Future<void> loadMyLoans() async {
    _setLoading(true);
    try {
      final res = await _loansApi.getMyLoans();
      myLoans = res;
      error = null;
    } catch (e) {
      error = userMessage(e);
    }
    _setLoading(false);
  }

  Future<void> loadLoan(String loanId) async {
    _setLoading(true);
    try {
      final res = await _loansApi.getLoan(loanId);
      currentLoan = res['data'] as Map<String, dynamic>;
      error = null;
    } catch (e) {
      error = userMessage(e);
    }
    _setLoading(false);
  }

  Future<Map<String, dynamic>?> loadActiveLoan() async {
    try {
      final res = await _loansApi.getActiveLoan();
      return res['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  void clearCalculation() {
    calculation = null;
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
