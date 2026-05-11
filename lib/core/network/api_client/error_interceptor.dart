import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
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
