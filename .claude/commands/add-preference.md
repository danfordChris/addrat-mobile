# Add Preference — Persist App Settings with SharedPreferences

Use this skill to add new persistent key-value data using the project's `BasePreferences` pattern.

## Arguments
`$ARGUMENTS` — preference class and keys to add, e.g. `PortfolioPreference: lastViewedPortfolioId(int), showBalances(bool)`

---

## Architecture

- `BasePreferences` from `ipf_flutter_starter_pack` wraps `SharedPreferences`.
- Each feature or domain gets its own preference class extending `BasePreferences`.
- Preference keys are stored as `const String` in a companion `PrefKeys` class inside the same file.

## Existing Preference Classes

| Class | File | Keys |
|---|---|---|
| `Preferences` | `lib/services/preferences.dart` | `devicePin`, `allowBiometric` |
| `AuthPreference` | `lib/features/auth/preference/auth_preference.dart` | `phoneNumber`, `apiToken`, `apiRefreshToken`, `userPin`, `changeLdmPdf`, `changeLdmStatus`, `cdsNumber` |
| `SettingsPreference` | `lib/features/profile/preference/` | `language`, `darkMode` |

## Template — New Preference Class

```dart
// lib/features/portfolio/preference/portfolio_preference.dart
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class PortfolioPreference extends BasePreferences {
  PortfolioPreference._();
  static final PortfolioPreference instance = PortfolioPreference._();

  Future<int?> get lastViewedPortfolioId async =>
      await fetch<int?>(PrefKeys.lastViewedPortfolioId);

  Future<void> setLastViewedPortfolioId(int id) async =>
      await save(PrefKeys.lastViewedPortfolioId, id);

  Future<bool?> get showBalances async =>
      await fetch<bool?>(PrefKeys.showBalances);

  Future<void> setShowBalances(bool value) async =>
      await save(PrefKeys.showBalances, value);

  Future<void> clearPortfolioPrefs() async {
    await remove(PrefKeys.lastViewedPortfolioId);
    await remove(PrefKeys.showBalances);
  }
}

class PrefKeys {
  PrefKeys._();
  static const String lastViewedPortfolioId = 'portfolio_last_viewed_id';
  static const String showBalances          = 'portfolio_show_balances';
}
```

## Adding Keys to an Existing Class

Open the existing preference file and add a getter + setter pair:

```dart
// In AuthPreference:
Future<String?> get cdsNumber async => await fetch<String?>(PrefKeys.cdsNumber);
Future<void> setCdsNumber(String value) async => await save(PrefKeys.cdsNumber, value);

// In PrefKeys inside the same file:
static const String cdsNumber = 'cds_number';
```

## Supported Types

`BasePreferences.fetch<T>()` and `save()` support: `String`, `int`, `double`, `bool`, `List<String>`.

For complex objects, serialize to/from JSON string:
```dart
Future<PortfolioModel?> get cachedPortfolio async {
  final raw = await fetch<String?>(PrefKeys.cachedPortfolio);
  if (raw == null) return null;
  return PortfolioModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

Future<void> setCachedPortfolio(PortfolioModel model) async =>
    await save(PrefKeys.cachedPortfolio, jsonEncode(model.toJson));
```

## Usage in Provider or Service

```dart
// Read:
final id = await PortfolioPreference.instance.lastViewedPortfolioId;

// Write:
await PortfolioPreference.instance.setLastViewedPortfolioId(portfolio.id ?? 0);

// Clear on logout (add to JwtService.logout or AuthProvider.logout):
await PortfolioPreference.instance.clearPortfolioPrefs();
```

## Rules

- Always use a `static final instance` singleton — never instantiate directly in calling code.
- Keep preference key strings in a `PrefKeys` companion class **in the same file**.
- Key strings must be globally unique across the app — use a feature prefix (e.g., `portfolio_`).
- Add a `clear*Prefs()` method and call it from the logout flow in `JwtService` or `AuthProvider`.
- Do not use `BasePreferences` for sensitive data that should survive logout (e.g., device ID) — those go in `SessionManager`.
