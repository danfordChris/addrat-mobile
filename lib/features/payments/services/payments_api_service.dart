import 'package:dio/dio.dart';
import 'package:pesa_lending/core/network/api_client.dart';

class PaymentsApiService {
  PaymentsApiService._();
  static final PaymentsApiService instance = PaymentsApiService._();

  Dio get _dio => ApiClient().dio;

  Future<Map<String, dynamic>> makeRepayment(Map<String, dynamic> body) =>
      _post('/payments/repay', body);

  Future<Map<String, dynamic>> getPaymentHistory({int page = 0, int size = 10}) =>
      _get('/payments/history?page=$page&size=$size');

  Future<Map<String, dynamic>> getPaymentStatus(String transactionId) =>
      _get('/payments/$transactionId/status');

  // ── Helpers ───────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _dio.get(path);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, dynamic data) async {
    final res = await _dio.post(path, data: data);
    return res.data as Map<String, dynamic>;
  }
}
