import 'package:dio/dio.dart';
import 'package:pesa_lending/models/loan_models.dart';
import 'package:pesa_lending/core/network/api_client.dart';
import 'package:pesa_lending/core/utils/result.dart';

class LoanRepository {
  LoanRepository._();
  static final LoanRepository instance = LoanRepository._();

  Dio get _dio => ApiClient().dio;

  Future<Result<List<LoanModel>>> getLoans() async {
    try {
      final res = await _dio.get('/loans');
      final list = (res.data['data'] ?? res.data) as List;
      return Success(
          list.map((e) => LoanModel.fromJson(e as Map<String, dynamic>)).toList());
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to load loans', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<LoanModel?>> getActiveLoan() async {
    try {
      final res = await _dio.get('/loans/active');
      final data = res.data['data'];
      if (data == null) return const Success(null);
      return Success(LoanModel.fromJson(data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Success(null);
      return Failure(e.message ?? 'Failed to load active loan', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<LoanModel>> applyForLoan(LoanApplicationDto dto) async {
    try {
      final res = await _dio.post('/loans/apply', data: dto.toJson());
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(LoanModel.fromJson(data));
    } on DioException catch (e) {
      return Failure(e.message ?? 'Loan application failed', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<LoanModel>> getLoan(String id) async {
    try {
      final res = await _dio.get('/loans/$id');
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(LoanModel.fromJson(data));
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to load loan', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
