# Scaffold Feature — Create a Full Feature Module

Use this skill to scaffold the complete folder structure for a new feature following the project's architecture.

## Arguments
`$ARGUMENTS` — feature name and brief description, e.g. `portfolio: investment portfolio management with list, detail, and create screens`

---

## Feature Folder Structure

Every feature lives under `lib/features/<feature>/` with these subfolders:

```
lib/features/portfolio/
├── enum/                    # Feature-specific enums
│   └── portfolio_status_enum.dart
├── helper_model/            # Lightweight request/response DTOs (not DB-backed)
│   └── portfolio_create_request.dart
├── model/                   # If feature needs its own non-DB models
├── providers/               # State management
│   └── portfolio_provider.dart
├── screens/                 # Full screens (Scaffold wrappers)
│   ├── portfolio_list_screen.dart
│   ├── portfolio_details_screen.dart
│   └── portfolio_create_screen.dart
├── service/                 # API services
│   └── portfolio_services.dart
└── widgets/                 # Feature-specific reusable widgets
    ├── portfolio_card.dart
    └── portfolio_summary_widget.dart
```

---

## Scaffolding Order (do these in sequence)

### 1. Model (if new DB table is needed)
Follow `/scaffold-feature` → use `/ipf-gen` skill to add the model to `ipf_generator.dart` and run `make ipf_gen`.

Then create `lib/models/portfolio_model.dart`:
```dart
import 'package:solomon/starter_models/portfolio_model.g.dart';

class PortfolioModel extends PortfolioModelGen {
  factory PortfolioModel.fromDatabase(Map<String, dynamic> map) =>
      PortfolioModelGen.fromDatabase(map);
  factory PortfolioModel.fromJson(Map<String, dynamic> map) =>
      PortfolioModelGen.fromJson(map);
}
```

### 2. Enums
Create `lib/features/portfolio/enum/portfolio_status_enum.dart`. See `/add-enum` skill.

### 3. Service
Create `lib/features/portfolio/service/portfolio_services.dart`. See `/api-service` skill.

### 4. Provider
Create `lib/features/portfolio/providers/portfolio_provider.dart`. See `/add-provider` skill.
Register it in `lib/shared/providers/providers.dart`.

### 5. Localization strings
Add keys to `lib/l10n/intl_en.arb` and `lib/l10n/intl_sw.arb`, then run generator. See `/add-l10n` skill.

### 6. Screens

Minimal screen template:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:solomon/features/portfolio/providers/portfolio_provider.dart';
import 'package:solomon/services/strings.dart';
import 'package:solomon/shared/widgets/app_button.dart';

class PortfolioListScreen extends StatefulWidget {
  const PortfolioListScreen({super.key});

  @override
  State<PortfolioListScreen> createState() => _PortfolioListScreenState();
}

class _PortfolioListScreenState extends State<PortfolioListScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().fetchPortfolios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFetching = context.select<PortfolioProvider, bool>((p) => p.isFetching);
    final portfolios = context.select<PortfolioProvider, List<PortfolioModel>>(
      (p) => p.portfolios,
    );

    return Scaffold(
      appBar: AppBar(title: Text(Strings.instance.portfolioTitle)),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: portfolios.length,
              itemBuilder: (context, index) => PortfolioCard(portfolio: portfolios[index]),
            ),
    );
  }
}
```

### 7. Routes
Add `AppRoute` enum values and `GoRoute` entries. See `/add-route` skill.

---

## Helper Model Template (for API request/response DTOs)

```dart
// lib/features/portfolio/helper_model/portfolio_create_request.dart
class PortfolioCreateRequest {
  final String name;
  final int type;
  final double targetAmount;

  const PortfolioCreateRequest({
    required this.name,
    required this.type,
    required this.targetAmount,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'targetAmount': targetAmount,
  };
}
```

---

## Bottom Sheet / Modal Screen

For screens that open as a bottom sheet:
```dart
// Screen widget — no Scaffold, just a Column/ListView with SafeArea
class PortfolioCreateSheet extends StatelessWidget {
  const PortfolioCreateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // content
            AppButton.primary(
              title: Strings.instance.portfolioCreateButton,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
```

Route registration in `router.dart`:
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

## Checklist

- [ ] `ipf_generator.dart` updated and `make ipf_gen` run (if new DB model)
- [ ] Concrete model in `lib/models/`
- [ ] `DatabaseManager` table list updated (if DB model)
- [ ] Enums created in `lib/features/portfolio/enum/`
- [ ] Service class created in `lib/features/portfolio/service/`
- [ ] Provider created and registered in `providers.dart`
- [ ] L10n keys added to both ARBs and generator run
- [ ] Screens created with `context.select` for minimal rebuilds
- [ ] Routes added to `AppRoute` enum and `router.dart`
- [ ] Feature widgets created in `lib/features/portfolio/widgets/`
