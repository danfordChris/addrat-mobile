# Add L10n — Add Localized Strings

Use this skill to add new localized strings to the app (English + Swahili).

## Arguments
`$ARGUMENTS` — feature prefix and key/value pairs to add, e.g. `portfolio: title=My Portfolio, emptyState=No portfolios yet, createButton=Create Portfolio`

---

## Overview

The app uses `flutter_intl` (intl_utils). Source-of-truth ARB files live in `lib/l10n/`. Generated code lives in `lib/generated/`.

| File | Purpose |
|---|---|
| `lib/l10n/intl_en.arb` | English strings (edit this first) |
| `lib/l10n/intl_sw.arb` | Swahili strings (edit in parallel) |
| `lib/generated/l10n.dart` | Auto-generated `S` class (do not edit) |
| `lib/generated/intl/messages_en.dart` | Auto-generated (do not edit) |

---

## Step 1 — Add Keys to `intl_en.arb`

Open `lib/l10n/intl_en.arb`. Keys are **camelCase** prefixed with the feature name.

```json
{
  "@@locale": "en",

  "portfolioTitle": "My Portfolio",
  "@portfolioTitle": {},

  "portfolioEmptyState": "No portfolios yet",
  "@portfolioEmptyState": {},

  "portfolioCreateButton": "Create Portfolio",
  "@portfolioCreateButton": {},

  "portfolioDeleteConfirm": "Delete {name}?",
  "@portfolioDeleteConfirm": {
    "placeholders": {
      "name": { "type": "String" }
    }
  }
}
```

**Key naming rules:**
- Prefix by feature: `auth`, `profile`, `market`, `order`, `portfolio`, `home`, `common`
- camelCase throughout
- `common` prefix for app-wide strings (e.g., `commonNext`, `commonCancel`, `commonError`)

---

## Step 2 — Add Keys to `intl_sw.arb`

Open `lib/l10n/intl_sw.arb` and add the same keys with Swahili translations:

```json
{
  "@@locale": "sw",

  "portfolioTitle": "Mkoba Wangu",
  "@portfolioTitle": {},

  "portfolioEmptyState": "Hakuna mikoba bado",
  "@portfolioEmptyState": {},

  "portfolioCreateButton": "Unda Mkoba",
  "@portfolioCreateButton": {},

  "portfolioDeleteConfirm": "Futa {name}?",
  "@portfolioDeleteConfirm": {
    "placeholders": {
      "name": { "type": "String" }
    }
  }
}
```

---

## Step 3 — Run the Generator

```bash
flutter pub global run intl_utils:generate
```

This updates `lib/generated/l10n.dart` and `lib/generated/intl/messages_*.dart`.

---

## Step 4 — Use the Strings

**In widgets (no context needed):**
```dart
import 'package:solomon/services/strings.dart';

Text(Strings.instance.portfolioTitle)
Text(Strings.instance.portfolioDeleteConfirm(portfolio.name))
```

**In widgets (with context, for locale-sensitive render):**
```dart
Text(Strings.of(context).portfolioTitle)
```

**In providers / services (no context available):**
```dart
import 'package:solomon/services/strings.dart';

logInfo(Strings.instance.portfolioEmptyState);
```

---

## Parameterized Strings

ARB supports placeholders for dynamic values:

```json
"portfolioValue": "Value: {amount} TZS",
"@portfolioValue": {
  "placeholders": {
    "amount": { "type": "String" }
  }
}
```

Usage:
```dart
Strings.instance.portfolioValue(AppFormatter.formatCurrency(portfolio.value))
```

For plural forms:
```json
"portfolioCount": "{count, plural, =0{No portfolios} =1{1 portfolio} other{{count} portfolios}}",
"@portfolioCount": {
  "placeholders": {
    "count": { "type": "int" }
  }
}
```

---

## Do's and Don'ts

- **Do** always add both `en` and `sw` translations — an untranslated string will fall back to the key name at runtime.
- **Do** use the feature prefix on all keys to avoid collisions.
- **Do not** hardcode user-facing strings anywhere in Dart code — always go through `Strings.instance`.
- **Do not** edit files under `lib/generated/` manually — they are regenerated on every run.
- **Do** keep the `@keyName` metadata entry (even if empty `{}`) directly after each string key — the generator requires it.
