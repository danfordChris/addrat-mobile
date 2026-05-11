import 'package:dio/dio.dart';
import 'package:pesa_lending/core/network/api_client.dart';

class ReferenceApiService {
  ReferenceApiService._();
  static final ReferenceApiService instance = ReferenceApiService._();

  Dio get _dio => ApiClient().dio;

  Future<Map<String, dynamic>> getBanks() => _get('/reference/banks');

  Future<Map<String, dynamic>> getBranches(int bankId) =>
      _get('/reference/banks/$bankId/branches');

  // ── Helpers ───────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _dio.get(path);
    return res.data as Map<String, dynamic>;
  }
}
