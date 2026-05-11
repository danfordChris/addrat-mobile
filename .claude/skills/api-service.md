# API Service — Create a New Feature Service

Use this skill to create a new API service class following the project's established pattern.

## Arguments
`$ARGUMENTS` — feature name and endpoints to implement, e.g. `Portfolio: fetchAll, fetchById(id), create, delete(id)`

---

## Architecture Overview

- All HTTP calls go through `APIManager` (singleton at `lib/services/api_manager.dart`).
- `APIManager` extends `BaseAPIManager` from `ipf_flutter_starter_pack`.
- Auth headers (`Authorization`, `x-api-key`, `x-device-id`, `x-locale`) are injected automatically.
- Token refresh on 401 is handled automatically by the `refreshOnUnauthorized` getter in `APIManager`.
- Feature services are **static-method-only classes** with a **private constructor** and a private `_Endpoints` inner class.
- Location: `lib/features/<feature>/service/<feature>_service.dart`

## Response Handling Pattern

```dart
final response = await APIManager.instance.apiAuthGet(_Endpoints.fetchAll);
response.log();           // logs response in debug mode
response.raiseOnError();  // throws APIException on non-2xx

// Single object:
final data = response.mapData<PortfolioModel>(PortfolioModel.fromJson);

// List:
final list = (response.responseBody['data'] as List)
    .map((e) => PortfolioModel.fromJson(e))
    .toList();
```

## Full Service Template

```dart
import 'package:solomon/models/portfolio_model.dart';
import 'package:solomon/services/api_manager.dart';

class PortfolioServices {
  PortfolioServices._(); // prevents instantiation

  static Future<List<PortfolioModel>> fetchAll() async {
    final response = await APIManager.instance.apiAuthGet(_Endpoints.fetchAll);
    response.log();
    response.raiseOnError();
    return (response.responseBody['data'] as List)
        .map((e) => PortfolioModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<PortfolioModel> fetchById(int id) async {
    final response = await APIManager.instance
        .apiAuthGet(_Endpoints.fetchById(id));
    response.log();
    response.raiseOnError();
    return response.mapData<PortfolioModel>(PortfolioModel.fromJson);
  }

  static Future<void> create(Map<String, dynamic> body) async {
    final response = await APIManager.instance
        .apiAuthPost(_Endpoints.create, body: jsonEncode(body));
    response.log();
    response.raiseOnError();
  }

  static Future<void> delete(int id) async {
    final response = await APIManager.instance
        .apiAuthDelete(_Endpoints.deleteById(id));
    response.log();
    response.raiseOnError();
  }
}

class _Endpoints {
  _Endpoints._();
  static const String fetchAll = '/portfolio';
  static const String create = '/portfolio';
  static String fetchById(int id) => '/portfolio/$id';
  static String deleteById(int id) => '/portfolio/$id';
}
```

## HTTP Methods Available on `APIManager`

| Method | Use for |
|---|---|
| `apiAuthGet(endpoint, params: {})` | GET with query params |
| `apiAuthPost(endpoint, body: jsonEncode({}))` | POST with JSON body |
| `apiAuthPut(endpoint, body: jsonEncode({}))` | PUT/update |
| `apiAuthPatch(endpoint, body: jsonEncode({}))` | PATCH |
| `apiAuthDelete(endpoint)` | DELETE |
| `apiAuthPostMultipart(endpoint, fields, files)` | Multipart file upload |

## File Upload (Multipart)

Use `FileUploadService` from `lib/services/file_upload_service.dart` to pick a file, then call `apiAuthPostMultipart`.

## Do's and Don'ts

- **Do** keep the `_Endpoints` inner class private and scoped to the service file.
- **Do** always call `response.log()` before `response.raiseOnError()`.
- **Do** always call `response.raiseOnError()` before accessing `response.mapData` or `response.responseBody`.
- **Do not** instantiate `APIManager` with `new` — always use `APIManager.instance`.
- **Do not** hardcode auth tokens or API keys in service files — they are injected by `APIManager`.
- **Do not** create a singleton or `ChangeNotifier` for the service — keep it purely static.
- **Do** use `dart:convert`'s `jsonEncode` for POST/PUT bodies.
