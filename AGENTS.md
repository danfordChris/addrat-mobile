# Agent Guide

## Project map
- Flutter app for Pesa Lending Tanzania; entry point is `lib/main.dart`.
- App shell is `MaterialApp.router` with a single light theme from `lib/core/theme/app_theme.dart`.
- Core services live under `lib/core/`: `network/` (`api_client.dart`, `app_router.dart`), `storage/`, `providers/`, and `theme/`.
- Feature UI lives under `lib/features/<area>/...`; shared reusable widgets are in `lib/shared/widgets/shared_widgets.dart`.

## Architecture to preserve
- Navigation is centralized in `lib/core/network/app_router.dart` using `go_router`.
- Auth gating happens in router `redirect` by checking `StorageService.isLoggedIn()`; unauthenticated users are sent to `/auth/welcome`.
- Routes commonly pass data through `state.extra` maps, e.g. `/auth/otp`, `/loans/apply`, and `/loans/:loanId/repay`.
- Session data is stored only via `lib/core/storage/storage_service.dart` (`flutter_secure_storage`).
- Network calls go through the singleton `ApiClient` in `lib/core/network/api_client.dart`, which adds auth headers, refreshes tokens on 401, and normalizes errors.

## State management patterns
- Newer screens use Riverpod (`flutter_riverpod`) with `authProvider` and `loanProvider` from `lib/core/providers/providers.dart`.
- Riverpod is the active state layer in the app; legacy BLoC examples are archived under `legacy/` and should not be extended for new flows.
- Provider state is map-based and API-shaped; keep request/response keys aligned with backend payloads.
- **API handling follows: UI (Screen) → Provider (State) → Repository (API Service)**
  - See `MOBILE_API_PATTERNS.md` for detailed examples
  - Use `API_IMPLEMENTATION_CHECKLIST.md` when implementing new features
  - Repositories return `Result<T>` (Success/Failure) wrapped responses
  - Providers manage loading state and call `notifyListeners()` after updates
  - UI watches provider state and disables buttons during loading
  - Errors handled via `SessionManager.handleError()` (shows snackbar)

## UI conventions
- Reuse `PesaButton`, `PesaTextField`, `AmountCard`, `StatusBadge`, `LoadingOverlay`, and `showError/showSuccess` from `lib/shared/widgets/shared_widgets.dart`.
- Prefer `AppColors` and `AppTheme.light` instead of inline colors; the app already uses NunitoSans and Material 3.
- Screens mix English package names with Swahili user-facing text; keep existing copy style consistent.
- Navigation style: use `context.go(...)` for flow resets (login/logout/home), `context.push(...)` for drill-down screens.

## Developer workflow
- Install deps: `flutter pub get`.
- Analyze before shipping: `flutter analyze`.
- Run tests: `flutter test`.
- Regenerate code after touching Riverpod/json annotations: `dart run build_runner build --delete-conflicting-outputs`.
- Backend endpoint defaults to `http://10.0.2.2:8080/api/v1`; override with `--dart-define=API_BASE_URL=...` when needed.

## Edit carefully
- Before changing auth or loan flows, inspect `lib/core/network/app_router.dart`, `lib/core/providers/providers.dart`, `lib/core/network/api_client.dart`, and the relevant feature screen.
- Keep platform/build artifacts (`build/`, `Pods/`, generated files) out of manual edits unless the task is explicitly platform-specific.
