import 'dart:convert';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/services/api_manager.dart';

class _Endpoints {
  _Endpoints._();

  static const String profile = "/auth/users/me/kyc";
  static const String submit = "/auth/users/me/kyc/submit";
  static String step(int n) => "/auth/users/me/kyc/step/$n";
  static const String documents = "/auth/users/me/kyc/documents";
}

class KycApiService {
  KycApiService._();

  static Future<Map<String, dynamic>> get kycProfile async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(_Endpoints.profile);
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> savePersonalInfo(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.step(0),
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> saveEmploymentInfo(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.step(1),
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> saveFinancialDetails(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.step(2),
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> uploadDocuments(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.documents,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> submitKyc(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.submit,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }
}
