import 'package:dio/dio.dart';

String userMessage(Object e) {
  if (e is DioException) return e.message ?? 'An error occurred';
  final s = e.toString();
  return s.startsWith('Exception: ') ? s.substring(11) : s;
}
