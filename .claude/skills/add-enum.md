# Add Enum — Create a Project-Standard Enum

Use this skill to create a new enum following the project's conventions.

## Arguments
`$ARGUMENTS` — enum name, values, label source (hardcoded/localized), and whether it needs an API id, e.g. `PortfolioType: growth(1), income(2), balanced(3), with localized labels and fromId`

---

## Enum Patterns in This Project

There are three standard patterns. Pick the one that fits:

---

### Pattern A — Label + API ID (most common for API-driven enums)

Use when the enum value maps to a backend integer and needs a human-readable label.

```dart
// lib/features/<feature>/enums/<feature>_enums.dart  (or lib/features/auth/enums/ for auth-related)

enum PortfolioType {
  growth('Growth', 1),
  income('Income', 2),
  balanced('Balanced', 3);

  final String label;
  final int id;
  const PortfolioType(this.label, this.id);

  static PortfolioType fromId(int id) => PortfolioType.values.firstWhere(
        (e) => e.id == id,
        orElse: () => throw ArgumentError('Unknown PortfolioType id: $id'),
      );

  static PortfolioType? fromIdOrNull(int? id) {
    if (id == null) return null;
    return PortfolioType.values.firstWhereOrNull((e) => e.id == id);
  }
}
```

**Usage:**
```dart
// Serialize to int for API:
final body = {'type': portfolioType.id};

// Deserialize from API response:
final type = PortfolioType.fromId(json['type'] as int);

// Display in UI:
Text(portfolioType.label)
```

---

### Pattern B — Localized Labels

Use when the label must change with the app's language.

```dart
import 'package:solomon/services/strings.dart';

enum PortfolioType {
  growth,
  income,
  balanced;

  String get label => switch (this) {
    PortfolioType.growth   => Strings.instance.portfolioTypeGrowth,
    PortfolioType.income   => Strings.instance.portfolioTypeIncome,
    PortfolioType.balanced => Strings.instance.portfolioTypeBalanced,
  };
}
```

**Remember:** Add the localization keys to both `lib/l10n/intl_en.arb` and `lib/l10n/intl_sw.arb`, then run:
```bash
flutter pub global run intl_utils:generate
```

---

### Pattern C — Enum with Computed Properties (color, icon, image)

Use when the enum drives UI appearance.

```dart
import 'package:flutter/material.dart';
import 'package:solomon/core/resources/resources.dart';

enum PortfolioStatus {
  active,
  suspended,
  closed;

  Color get color => switch (this) {
    PortfolioStatus.active    => Colors.green,
    PortfolioStatus.suspended => Colors.orange,
    PortfolioStatus.closed    => Colors.red,
  };

  String get imagePath => switch (this) {
    PortfolioStatus.active    => AppImages.portfolioActive,
    PortfolioStatus.suspended => AppImages.portfolioSuspended,
    PortfolioStatus.closed    => AppImages.portfolioClosed,
  };

  bool get isActive => this == PortfolioStatus.active;
}
```

---

### Combining Patterns (API ID + Localized Label + UI properties)

```dart
enum PortfolioType {
  growth(1),
  income(2),
  balanced(3);

  final int id;
  const PortfolioType(this.id);

  String get label => switch (this) {
    PortfolioType.growth   => Strings.instance.portfolioTypeGrowth,
    PortfolioType.income   => Strings.instance.portfolioTypeIncome,
    PortfolioType.balanced => Strings.instance.portfolioTypeBalanced,
  };

  Color get color => switch (this) {
    PortfolioType.growth   => const Color(0xFF4CAF50),
    PortfolioType.income   => const Color(0xFF2196F3),
    PortfolioType.balanced => const Color(0xFF9C27B0),
  };

  static PortfolioType fromId(int id) => PortfolioType.values.firstWhere(
        (e) => e.id == id,
        orElse: () => throw ArgumentError('Unknown PortfolioType id: $id'),
      );
}
```

---

## File Location Rules

| Enum scope | File location |
|---|---|
| Auth / onboarding | `lib/features/auth/enums/<name>_enum.dart` |
| Feature-specific | `lib/features/<feature>/enum/<name>_enum.dart` |
| App-wide / shared | `lib/shared/enums/<name>_enum.dart` |
| Market / trading | `lib/features/markets/enum/<name>_enum.dart` |

---

## Using Enums in Models

In the IPF generator, store the enum as `int`. In the concrete model, expose it as the enum type:

```dart
// In ipf_generator.dart:
'portfolioType': int,

// In lib/models/portfolio_model.dart:
PortfolioType get portfolioTypeEnum => PortfolioType.fromId(portfolioType ?? 0);
```

---

## Rules

- Always use `switch` expressions (not `if/else`) for `label`, `color`, and other computed properties — the compiler enforces exhaustiveness.
- Always provide `fromId` for enums that map to API integers.
- Prefer `fromIdOrNull(int?)` over `fromId` in contexts where the value might be absent.
- Do not add a generic `unknown` / `none` fallback value to enums unless the API actually sends it — it hides bugs.
