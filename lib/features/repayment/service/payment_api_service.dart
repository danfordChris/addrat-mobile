import 'dart:convert';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/services/api_manager.dart';

class _Endpoints {
  _Endpoints._();

  static const String repay = "/payments/repay";
}

class PaymentApiService {
  PaymentApiService._();

  static Future<Map<String, dynamic>> makeRepayment(Map<String, dynamic> body) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.repay,
      body: jsonEncode(body),
    );
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }
}
