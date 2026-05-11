# Add Provider — Create a State Management Provider

Use this skill to create a new feature provider following the project's `BaseProvider` + `LoggerMixin` pattern.

## Arguments
`$ARGUMENTS` — feature name and state to manage, e.g. `Portfolio: list of PortfolioModel, selected item, isFetching`

---

## Architecture Overview

- **Package:** `provider: ^6.1.5+1`
- **Base chain:** `StarterChangeNotifier` (starter pack) → `BaseProvider` → feature provider
- **File:** `lib/features/<feature>/providers/<feature>_provider.dart`
- **Registration:** `lib/shared/providers/providers.dart` — flat list of `ChangeNotifierProvider`s

## Provider Template

```dart
import 'package:flutter/material.dart';
import 'package:solomon/core/mixins/logger_mixin.dart';
import 'package:solomon/features/portfolio/service/portfolio_services.dart';
import 'package:solomon/models/portfolio_model.dart';
import 'package:solomon/shared/providers/base_provider.dart';

class PortfolioProvider extends BaseProvider with LoggerMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  bool? _isFetching;
  List<PortfolioModel> _portfolios = [];
  PortfolioModel? _selected;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isFetching => _isFetching ?? false;
  List<PortfolioModel> get portfolios => _portfolios;
  PortfolioModel? get selected => _selected;

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> fetchPortfolios() async {
    try {
      _setIsFetching(true);
      _portfolios = await PortfolioServices.fetchAll();
    } catch (e) {
      logError('fetchPortfolios: $e');
    } finally {
      _setIsFetching(false);
    }
  }

  void select(PortfolioModel portfolio) {
    _selected = portfolio;
    notifyListeners();
  }

  // ── Private setters ────────────────────────────────────────────────────────
  void _setIsFetching(bool value) {
    _isFetching = value;
    notifyListeners();
  }
}
```

## Registering the Provider

Open `lib/shared/providers/providers.dart` and add to the list:

```dart
ChangeNotifierProvider(create: (_) => PortfolioProvider()),
```

## Paginated Provider (with OffsetPaginationController)

Use `OffsetPaginationController<T>` from `easy_scroll_pagination` for lists with infinite scroll:

```dart
class PortfolioProvider extends BaseProvider with LoggerMixin {
  late final OffsetPaginationController<PortfolioModel> _controller;

  PortfolioProvider() {
    _controller = OffsetPaginationController<PortfolioModel>(
      fetcher: _fetch,
      limit: 20,
    );
  }

  OffsetPaginationController<PortfolioModel> get controller => _controller;

  Future<List<PortfolioModel>> _fetch(int page, int limit) async {
    return PortfolioServices.fetchAll(page: page, pageSize: limit);
  }
}
```

In the UI, pass `controller` to a `PaginatedListView` or equivalent widget.

## Consuming Providers in the UI

```dart
// Read once (actions, inside callbacks):
context.read<PortfolioProvider>().fetchPortfolios();

// Watch entire provider (rebuilds on any notifyListeners):
final provider = context.watch<PortfolioProvider>();

// Select specific field (minimal rebuilds — preferred):
final isFetching = context.select<PortfolioProvider, bool>((p) => p.isFetching);

// Consumer widget:
Consumer<PortfolioProvider>(
  builder: (context, provider, _) => Text(provider.portfolios.length.toString()),
)
```

## Init Pattern

For providers that need to load data as soon as a screen opens:

```dart
// In the screen's initState or didChangeDependencies:
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<PortfolioProvider>().fetchPortfolios();
  });
}
```

## Rules

- Keep all state fields **private** (`_fieldName`). Expose via public getters only.
- Every private setter that mutates state **must** call `notifyListeners()`.
- Use `LoggerMixin` methods (`logInfo`, `logWarning`, `logError`) — never `print()`.
- Never call the service directly from the UI — always go through the provider.
- Keep business logic in the provider, not in service classes.
- `BaseProvider` exposes `loadingWidget` (returns `CircularProgressIndicator`); use it for full-screen loading states.
