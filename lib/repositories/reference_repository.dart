import 'package:dio/dio.dart';
import 'package:pesa_lending/models/reference_models.dart';
import 'package:pesa_lending/core/network/api_client.dart';
import 'package:pesa_lending/core/utils/result.dart';

class ReferenceRepository {
  ReferenceRepository._();
  static final ReferenceRepository instance = ReferenceRepository._();

  Dio get _dio => ApiClient().dio;

  Future<Result<List<BankModel>>> getBanks() async {
    try {
      final res = await _dio.get('/reference/banks');
      final list = (res.data['data'] ?? res.data) as List;
      return Success(
          list.map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList());
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to load banks', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<BranchModel>>> getBranches(int bankId) async {
    try {
      final res = await _dio.get('/reference/banks/$bankId/branches');
      final list = (res.data['data'] ?? res.data) as List;
      return Success(
          list.map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList());
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to load branches', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
