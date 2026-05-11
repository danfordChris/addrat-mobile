# Add Route — Register a New Screen in GoRouter

Use this skill to add a new route to the app's GoRouter configuration.

## Arguments
`$ARGUMENTS` — route name, path, screen class, data it receives, and where it belongs (auth flow / main app / modal), e.g. `portfolioDetails, /portfolio/:portfolioId, PortfolioDetailsScreen, receives portfolioId as path param and PortfolioModel as extra, main app under markets branch`

---

## Files to Edit

| File | What to change |
|---|---|
| `lib/core/router/router.dart` | Add `AppRoute` enum value + `GoRoute` entry |
| `lib/core/router/navigation_keys.dart` | Add `GlobalKey` only if a new nested navigator is needed |

---

## Step 1 — Add the `AppRoute` Enum Value

Open `lib/core/router/router.dart`. Find the `AppRoute` enum and add the new entry:

```dart
enum AppRoute {
  // ... existing routes ...
  portfolioDetails('/portfolio/:portfolioId'),  // path param syntax
  portfolioCreate('/portfolio/create'),          // static path
  ;

  const AppRoute(this.path);
  final String path;

  // helpers already defined — do not change them:
  static AppRoute byPath(String path) => ...
  String appendId(int? id) => '$path/$id';
}
```

**Path param syntax:** use `:paramName` inside the path string.

---

## Step 2 — Add the `GoRoute` Entry

Find the correct location in the `routes` list:

- **Auth/onboarding screens** → inside the first `StatefulShellRoute` (onboarding shell)
- **LDM waiting screens** → inside the second `StatefulShellRoute`
- **Main app screens** (home/markets/orders/updates/myStory) → inside the matching `StatefulShellBranch` under the main `StatefulShellRoute`
- **Modal / bottom sheet screens** → `pageBuilder` with `ModalSheetPage`
- **Global screens** (accessible from anywhere) → at the top-level routes list with `parentNavigatorKey: NavigationKeys.root`

### Standard screen:
```dart
GoRoute(
  path: AppRoute.portfolioDetails.path,
  pageBuilder: (context, state) {
    final portfolioId = int.parse(state.pathParameters['portfolioId']!);
    final portfolio = state.extra as PortfolioModel?;
    return AppTransitions.fadeAndSlideTransition(
      state,
      PortfolioDetailsScreen(portfolioId: portfolioId, portfolio: portfolio),
    );
  },
),
```

### Modal sheet screen:
```dart
GoRoute(
  path: AppRoute.portfolioCreate.path,
  parentNavigatorKey: NavigationKeys.root,
  pageBuilder: (context, state) => ModalSheetPage(
    swipeDismissible: true,
    child: const PortfolioCreateSheet(),
  ),
),
```

---

## Step 3 — Navigate to the New Route

```dart
// Simple push:
context.push(AppRoute.portfolioDetails.path.replaceFirst(':portfolioId', '$id'));

// With extra data:
context.push(
  AppRoute.portfolioDetails.path.replaceFirst(':portfolioId', '$id'),
  extra: portfolio,
);

// Replace current route (no back button):
context.go(AppRoute.portfolioCreate.path);

// Pop back:
context.pop();

// Pop with result:
context.pop(resultValue);
```

---

## Available Transition Helpers (`AppTransitions`)

| Helper | Effect |
|---|---|
| `AppTransitions.fadeAndSlideTransition(state, widget)` | Default push transition |
| `AppTransitions.slideTransition(state, widget)` | Slide from right |
| `AppTransitions.popTransition(state, widget)` | Used for pop-like screens |
| `AppTransitions.fadeCurveTransition(state, widget)` | Fade only |

---

## Passing Complex Data

When a screen needs a model object (not just an ID):

**Push:**
```dart
context.push(AppRoute.portfolioDetails.path.replaceFirst(':portfolioId', '$id'), extra: {'portfolio': portfolio});
```

**Receive (in route builder):**
```dart
final extra = state.extra as Map<String, dynamic>;
final portfolio = extra['portfolio'] as PortfolioModel;
```

Use `BaseModel.castToInt/castToBool/castToString` when extracting primitives from the extra map.

---

## Navigation Keys — When to Add One

Only add a new `GlobalKey<NavigatorState>` in `navigation_keys.dart` when:
- You are adding a **new tab** to the bottom navigation bar (new `StatefulShellBranch`).

For all other routes, reuse an existing key or rely on `NavigationKeys.root`.

---

## Checklist

- [ ] `AppRoute` enum value added with correct path string
- [ ] `GoRoute` entry added in the right shell/branch
- [ ] Path parameters match between enum path and `state.pathParameters` key
- [ ] Transition helper used (not raw `MaterialPage`)
- [ ] Navigation call uses `AppRoute.<name>.path` (never a hardcoded string)
