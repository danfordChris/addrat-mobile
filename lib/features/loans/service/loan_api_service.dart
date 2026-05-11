import 'dart:convert';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/services/api_manager.dart';

class _Endpoints {
  _Endpoints._();

  static const String products = "/loans/products";
  static const String calculate = "/loans/calculate";
  static const String apply = "/loans/apply";
  static const String myLoans = "/loans";
  static const String activeLoan = "/loans/active";
  static String loan(String id) => "/loans/$id";
  static String accept(String id) => "/loans/$id/accept";
}

class LoanApiService {
  LoanApiService._();

  static Future<List<Map<String, dynamic>>> get products async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(_Endpoints.products);
    apiResponse.raiseOnError();
    return List<Map<String, dynamic>>.from(apiResponse.responseBody['data']);
  }

  static Future<Map<String, dynamic>> calculate(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.calculate,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> apply(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.apply,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>> accept(String loanId, String pin) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.accept(loanId),
      body: jsonEncode({'pin': pin}),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<List<Map<String, dynamic>>> getMyLoans({int page = 0, int size = 10}) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(
      _Endpoints.myLoans,
      params: {'page': page.toString(), 'size': size.toString()},
    );
    apiResponse.raiseOnError();
    return List<Map<String, dynamic>>.from(apiResponse.responseBody['data']);
  }

  static Future<Map<String, dynamic>> getLoan(String loanId) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(_Endpoints.loan(loanId));
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>?> get activeLoan async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(_Endpoints.activeLoan);
    if (apiResponse.statusCode == 404) return null;
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }
}
