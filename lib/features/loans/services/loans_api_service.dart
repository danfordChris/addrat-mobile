import 'package:dio/dio.dart';
import 'package:pesa_lending/core/network/api_client.dart';

class LoansApiService {
  LoansApiService._();
  static final LoansApiService instance = LoansApiService._();

  Dio get _dio => ApiClient().dio;

  Future<Map<String, dynamic>> getLoanProducts() =>
      _get('/loans/products');

  Future<Map<String, dynamic>> calculateLoan(Map<String, dynamic> body) =>
      _post('/loans/calculate', body);

  Future<Map<String, dynamic>> applyLoan(Map<String, dynamic> body) =>
      _post('/loans/apply', body);

  Future<Map<String, dynamic>> acceptLoan(String loanId, String pin) =>
      _post('/loans/$loanId/accept', {'pin': pin});

  Future<List<Map<String, dynamic>>> getMyLoans({int page = 0, int size = 10}) async {
    final res = await _dio.get('/loans', queryParameters: {'page': page, 'size': size});
    final envelope = res.data as Map<String, dynamic>;
    final data = envelope['data'] as Map<String, dynamic>;
    final content = data['content'] as List;
    return List<Map<String, dynamic>>.from(content);
  }

  Future<Map<String, dynamic>> getLoan(String loanId) =>
      _get('/loans/$loanId');

  Future<Map<String, dynamic>> getActiveLoan() =>
      _get('/loans/active');

  // ── Helpers ───────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _dio.get(path);
    final envelope = res.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, dynamic data) async {
    final res = await _dio.post(path, data: data);
    final envelope = res.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
  }
}
