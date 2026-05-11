import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/features/auth/preference/auth_preference.dart';
import 'package:pesa_lending/services/api_manager.dart';
import 'package:pesa_lending/services/preferences.dart';

class _Endpoints {
  _Endpoints._();

  static const String refreshToken = "/auth/refresh";
}

class JwtService {
  JwtService._();

  static Future<String?> get _token async {
    final String? token = await AuthPreference.instance.apiToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  static Future<String?> get newToken async {
    try {
      final bool refreshSuccess = await _newToken;
      if (!refreshSuccess) {
        await logout();
        throw Exception("Session expired. User logged out.");
      }
      return await _token;
    } catch (e) {
      AppUtility.log("Error refreshing token: $e");
      rethrow;
    } finally {
    }
  }

  static Future<bool> get _newToken async {
    AuthPreference preferences = AuthPreference.instance;
    String? refreshTokenId = await preferences.apiRefreshToken;
    if (refreshTokenId == null || refreshTokenId.isEmpty) throw Exception("Refresh token not found");
    APIManager apiManager = APIManager.instance;
    APIResponse apiResponse = await apiManager.apiAuthPost(
      _Endpoints.refreshToken,
      body: {"refreshToken": refreshTokenId},
    );
    apiResponse.raiseOnError();
    Map<String, dynamic>? response = apiResponse.responseBody;
    if (response == null) throw Exception("Response is NULL");
    String? accessToken = response["data"]["accessToken"];
    // In Pesa app, we might get refreshToken back or not. Solomon handles it via cookies or body.
    String? newRefreshToken = response["data"]["refreshToken"]; 
    
    if (accessToken != null) preferences.save(AuthPrefKeys.apiToken, accessToken);
    if (newRefreshToken != null) preferences.save(AuthPrefKeys.apiRefreshToken, newRefreshToken);
    
    AppUtility.log("Token refreshed successfully");
    return accessToken != null;
  }

  static Future<void> logout() async {
    await AuthPreference.instance.logoutUser;
    await Preferences.instance.logoutUser;
    // await DatabaseManager.instance.deleteAll; // Need to implement this in DatabaseManager
  }

  static Future<bool> isAuthenticated() async {
    final token = await _token;
    return token != null && token.isNotEmpty;
  }
}
