import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/services/storage_service.dart';

class APIManager extends BaseAPIManager {
  APIManager._() : super(apiBaseUrl, _manager);

  static APIManager get instance => APIManager._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://61c6-102-205-251-154.ngrok-free.app/api/v1',
  );

  static StarterAPIManagement get _manager {
    return StarterAPIManagement(
      authorization: _authorization,
    );
  }

  static Future<Map<String, String>?> get _authorization async {
    String? token = await StorageService.getAccessToken();

    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  @override
  Future<StarterAPIManagement>? get refreshOnUnauthorized async {
    // Implement token refresh logic here if needed
    // Similar to Solomon app's JwtService.newToken
    return _manager;
  }
}
