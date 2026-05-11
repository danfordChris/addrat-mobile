import 'dart:convert';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/services/api_manager.dart';

class _Endpoints {
  _Endpoints._();

  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String requestOtp = "/auth/otp/request";
  static const String verifyOtp = "/auth/otp/verify";
  static const String refreshToken = "/auth/refresh";
  static const String setPin = "/auth/users/me/pin";
  static const String profile = "/auth/users/me";
  static const String updateDeviceToken = "/auth/users/me/device-token";
}

class AuthApiService {
  AuthApiService._();

  static Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.register,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.login,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> requestOtp(String phone, String purpose) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.requestOtp,
      body: jsonEncode({'phoneNumber': phone, 'purpose': purpose}),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.verifyOtp,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> refreshToken(String token) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.refreshToken,
      body: jsonEncode({'refreshToken': token}),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> setPin(String pin) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.setPin,
      body: jsonEncode({'pin': pin}),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> get profile async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(_Endpoints.profile);
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> updateDeviceToken(String token) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPatch(
      _Endpoints.updateDeviceToken,
      body: jsonEncode({'deviceToken': token}),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }
}
