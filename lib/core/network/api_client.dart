import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class ApiClient {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/api/v1', // Android emulator localhost
  );

  static final _logger = Logger();
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(_LoggingInterceptor(_logger));
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;

  // ── Auth ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) =>
      _post('/auth/register', body);

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) =>
      _post('/auth/login', body);

  Future<Map<String, dynamic>> sendOtp(String phone, String purpose) =>
      _post('/auth/otp/request', {'phoneNumber': phone, 'purpose': purpose});

  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> body) =>
      _post('/auth/otp/verify', body);

  Future<Map<String, dynamic>> refreshToken(String token) =>
      _post('/auth/refresh', {'refreshToken': token});

  // ── Users ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() => _get('/auth/users/me');

  Future<Map<String, dynamic>> setPin(String pin) =>
      _post('/auth/users/me/pin', {'pin': pin});

  Future<Map<String, dynamic>> submitKyc(Map<String, dynamic> body) =>
      _post('/auth/users/me/kyc', body);

  Future<Map<String, dynamic>> updateDeviceToken(String token) =>
      _patch('/auth/users/me/device-token', {'deviceToken': token});

  // ── Loans ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> getLoanProducts() => _get('/loans/products');

  Future<Map<String, dynamic>> calculateLoan(Map<String, dynamic> body) =>
      _post('/loans/calculate', body);

  Future<Map<String, dynamic>> applyLoan(Map<String, dynamic> body) =>
      _post('/loans/apply', body);

  Future<Map<String, dynamic>> acceptLoan(String loanId, String pin) =>
      _post('/loans/$loanId/accept', {'pin': pin});

  Future<Map<String, dynamic>> getMyLoans({int page = 0, int size = 10}) =>
      _get('/loans?page=$page&size=$size');

  Future<Map<String, dynamic>> getLoan(String loanId) => _get('/loans/$loanId');

  Future<Map<String, dynamic>> getActiveLoan() => _get('/loans/active');

  // ── Payments ──────────────────────────────────────────────
  Future<Map<String, dynamic>> makeRepayment(Map<String, dynamic> body) =>
      _post('/payments/repay', body);

  // ── Helpers ───────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _dio.get(path);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, dynamic data) async {
    final res = await _dio.post(path, data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patch(String path, dynamic data) async {
    final res = await _dio.patch(path, data: data);
    return res.data as Map<String, dynamic>;
  }
}

// ── Auth Interceptor ──────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for public endpoints
    final publicPaths = [
      '/auth/register',
      '/auth/login',
      '/auth/otp/request',
      '/auth/otp/verify',
      '/auth/refresh',
      '/actuator'
    ];
    final isPublic = publicPaths.any((p) => options.path.startsWith(p));

    if (!isPublic) {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      try {
        final refresh = await _storage.read(key: 'refresh_token');
        if (refresh != null) {
          final res =
              await _dio.post('/auth/refresh', data: {'refreshToken': refresh});
          final newToken = res.data['data']['accessToken'];
          await _storage.write(key: 'access_token', value: newToken);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryRes = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryRes);
        }
      } catch (_) {
        await _storage.deleteAll();
      }
    }
    handler.next(err);
  }
}

// ── Logging Interceptor ──────────────────────────────────────
class _LoggingInterceptor extends Interceptor {
  final Logger _logger;
  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('→ ${options.method} ${options.path}');
    _logger.d('Request Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('← ${response.statusCode} ${response.requestOptions.path}');
    _logger.d('Response Body: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('✗ ${err.response?.statusCode} ${err.requestOptions.path}: '
        '${err.response?.data}');
    handler.next(err);
  }
}

// ── Error Interceptor ────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) { 
    String message = 'An error occurred. Please try again.';
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Check your internet connection.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'No internet connection.';
    } else if (err.response != null) {
      final data = err.response?.data;
      if (data is Map && data['message'] != null) {
        message = data['message'];
      }
    }
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
      message: message,
    ));
  }
}

// ── Api Exception ─────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}
