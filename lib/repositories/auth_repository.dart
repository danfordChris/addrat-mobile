import 'package:dio/dio.dart';
import 'package:pesa_lending/models/token_response.dart';
import 'package:pesa_lending/core/network/api_client.dart';
import 'package:pesa_lending/core/utils/result.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  Dio get _dio => ApiClient().dio;

  Future<Result<void>> requestOtp(String phoneNumber,
      {String purpose = 'LOGIN'}) async {
    try {
      await _dio.post('/auth/otp/request',
          data: {'phoneNumber': phoneNumber, 'purpose': purpose});
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.message ?? 'Failed to send OTP', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<TokenResponse>> verifyOtp(
      String phoneNumber, String otp,
      {String purpose = 'LOGIN'}) async {
    try {
      final res = await _dio.post('/auth/otp/verify',
          data: {'phoneNumber': phoneNumber, 'otp': otp, 'purpose': purpose});
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(TokenResponse.fromJson(data));
    } on DioException catch (e) {
      return Failure(e.message ?? 'OTP verification failed', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<TokenResponse>> refreshToken(String refreshToken) async {
    try {
      final res = await _dio.post('/auth/refresh',
          data: {'refreshToken': refreshToken});
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Success(TokenResponse.fromJson(data));
    } on DioException catch (e) {
      return Failure(e.message ?? 'Token refresh failed', e);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
