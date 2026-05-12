import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/services/api_manager.dart';
import 'package:pesa_lending/services/storage_service.dart';

class _Endpoints {
  _Endpoints._();

  static const String products = "/loans/products";
  static const String calculate = "/loans/calculate";
  static const String apply = "/loans/applications";
  static const String myLoans = "/loans";
  static const String activeLoan = "/loans/active";
  static String stream(String id) => "/loans/$id/events/stream";
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

  static Future<Map<String, dynamic>> calculate(
      Map<String, dynamic> body) async {
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

  static Future<List<Map<String, dynamic>>> getMyLoans(
      {int page = 0, int size = 10}) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthGet(
      _Endpoints.myLoans,
      params: {'page': page.toString(), 'size': size.toString()},
    );
    apiResponse.raiseOnError();
    final data = apiResponse.responseBody['data'];
    final content = data is Map ? data['content'] as List : data as List;
    return List<Map<String, dynamic>>.from(content);
  }

  static Future<Map<String, dynamic>> getLoan(String loanId) async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse =
        await apiManager.apiAuthGet(_Endpoints.loan(loanId));
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Future<Map<String, dynamic>?> get activeLoan async {
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse =
        await apiManager.apiAuthGet(_Endpoints.activeLoan);
    if (apiResponse.statusCode == 404) return null;
    apiResponse.raiseOnError();
    return apiResponse.mapData;
  }

  static Stream<Map<String, dynamic>> streamLoanEvents(String loanId) async* {
    final token = await StorageService.getAccessToken();
    final baseUri = Uri.parse(APIManager.apiBaseUrl);
    final streamUri = baseUri.replace(
      path: "${baseUri.path}${_Endpoints.stream(loanId)}",
      queryParameters: null,
    );

    final client = HttpClient();
    final request = await client.getUrl(streamUri);
    request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }

    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      client.close(force: true);
      throw Exception('SSE connection failed (${response.statusCode})');
    }

    String? eventName;
    final dataBuffer = StringBuffer();
    try {
      await for (final line
          in response.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.isEmpty) {
          if (dataBuffer.isNotEmpty) {
            final jsonData =
                jsonDecode(dataBuffer.toString()) as Map<String, dynamic>;
            yield {
              'event': eventName ?? 'message',
              'data': jsonData,
            };
          }
          eventName = null;
          dataBuffer.clear();
          continue;
        }
        if (line.startsWith('event:')) {
          eventName = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          dataBuffer.write(line.substring(5).trim());
        }
      }
    } finally {
      client.close(force: true);
    }
  }
}
