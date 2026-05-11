import 'package:dio/dio.dart';
import 'package:pesa_lending/models/kyc_models.dart';
import 'package:pesa_lending/core/network/api_client.dart';
import 'package:pesa_lending/core/utils/result.dart';

class KycRepository {
  KycRepository._();
  static final KycRepository instance = KycRepository._();

  Dio get _dio => ApiClient().dio;

  Future<Result<KycStatusResponse>> getStatus() async {
    try {
      final res = await _dio.get('/auth/kyc/status');
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(KycStatusResponse.fromJson(data));
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to get KYC status', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getProfile() async {
    try {
      final res = await _dio.get('/auth/kyc');
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(data);
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to get KYC profile', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> savePersonalInfo(PersonalInfoDto dto) async {
    try {
      await _dio.post('/auth/kyc/personal-info', data: dto.toJson());
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to save personal info', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> saveEmploymentInfo(EmploymentInfoDto dto) async {
    try {
      await _dio.post('/auth/kyc/employment-info', data: dto.toJson());
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to save employment info', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> saveFinancialDetails(FinancialDetailsDto dto) async {
    try {
      await _dio.post('/auth/kyc/financial-details', data: dto.toJson());
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to save financial details', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<KycStatusResponse>> submit() async {
    try {
      final res = await _dio.post('/auth/kyc/submit');
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(KycStatusResponse.fromJson(data));
    } on DioException catch (e) {
      return Failure(e.message ?? 'KYC submission failed', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
