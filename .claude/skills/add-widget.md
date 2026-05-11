# Add Widget — Create or Use Shared Widgets

Use this skill to understand the shared widget library and create new shared or feature widgets.

## Arguments
`$ARGUMENTS` — widget name and purpose, e.g. `PortfolioCard: displays a portfolio item with name, value, and status badge`

---

## Existing Shared Widgets (`lib/shared/widgets/`)

Always check these before creating a new widget:

### Buttons — `app_button.dart`
```dart
// Named constructors (preferred):
AppButton.primary(title: 'Submit', onPressed: () {})
AppButton.secondary(title: 'Cancel', onPressed: () {})
AppButton.outline(title: 'Learn More', onPressed: () {})
AppButton.destructive(title: 'Delete', onPressed: () {})
AppButton.text(title: 'Skip', onPressed: () {})
AppButton.glass(title: 'View', onPressed: () {})
AppButton.glassIcon(icon: Icons.add, onPressed: () {})

// With loading state:
AppButton.primary(title: 'Save', onPressed: _save, loading: _isSaving)

// Full constructor:
AppButton(
  title: 'Submit',
  onPressed: () {},
  variant: AppButtonVariant.success,
  loading: false,
  disabled: false,
  width: double.infinity,
)
```

### Input Fields — `input_fields.dart`
```dart
// Standard text:
InputField(
  controller: _controller,
  labelText: 'Full Name',
  hintText: 'Enter your name',
  validator: (val) => val!.isEmpty ? 'Required' : null,
)

// Dropdown:
InputField.dropdown<PortfolioType>(
  items: PortfolioType.values,
  itemLabel: (e) => e.label,
  onChanged: (val) => setState(() => _type = val),
  labelText: 'Portfolio Type',
  value: _type,
)

// Phone:
InputField.phone(
  onChanged: (phone) => _phone = phone.phoneNumber,
  labelText: 'Phone Number',
)

// PIN:
InputField.pin(
  onChanged: (pin) => _pin = pin,
  length: 6,
)
```

### List Tile — `app_tile.dart`
```dart
AppTile(
  title: 'Personal Details',
  subtitle: 'Manage your information',
  leading: const Icon(HugeIcons.user),
  trailing: const Icon(HugeIcons.arrowRight),
  onTap: () => context.push(AppRoute.personalDetails.path),
)
```

### Alerts & Dialogs
```dart
// Toast-style alert:
AppAlert.show('Successfully saved', type: AlertType.success);
AppAlert.show('Something went wrong', type: AlertType.error);

// Bottom sheet:
AppBottomsheet.show(context, child: MySheet());

// Dialog:
AppDialog.show(context, title: 'Confirm', content: 'Are you sure?');

// Bottom sheet alert with action:
BottomsheetAlert.show(context, message: 'Delete this item?', onConfirm: _delete);
```

### Loading & Skeleton
```dart
// Skeleton shimmer (wrap the normal widget):
AppSkeletonizer(
  enabled: isFetching,
  child: PortfolioCard(portfolio: mockPortfolio),
)

// Full-screen loading:
const LoadingIndicator()

// Loading animation (Lottie/custom):
const LoadingAnimation()
```

### Containers
```dart
GlassContainer(child: Text('Content'))
NotchedContainer(child: Text('Content'))
DottedContainer(child: Text('Upload'))
```

### Animations
```dart
ScaleUpAnimation(child: MyWidget())
SlideUpAnimation(child: MyWidget())
```

### Image
```dart
ImageNetwork(url: imageUrl, width: 48, height: 48)
```

### Empty State
```dart
EmptyState(message: Strings.instance.portfolioEmptyState)
EmptyView(
  title: 'No portfolios',
  subtitle: 'Create your first portfolio',
  action: AppButton.primary(title: 'Create', onPressed: () {}),
)
```

### Layout Helpers
```dart
// Three-column row:
TripleRail(
  left: Text('Label'),
  center: Text('Value'),
  right: Text('Action'),
)
```

---

## Creating a New Shared Widget

Only create a shared widget if the widget will be used in **2+ features**. Otherwise, keep it in the feature's `widgets/` folder.

**File:** `lib/shared/widgets/<widget_name>.dart`

```dart
import 'package:flutter/material.dart';
import 'package:solomon/core/theme/app_theme.dart';

class PortfolioStatusBadge extends StatelessWidget {
  const PortfolioStatusBadge({super.key, required this.status});

  final PortfolioStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelSmall?.copyWith(color: status.color),
      ),
    );
  }
}
```

## Creating a Feature Widget

```dart
// lib/features/portfolio/widgets/portfolio_card.dart
import 'package:flutter/material.dart';
import 'package:solomon/models/portfolio_model.dart';
import 'package:solomon/services/strings.dart';
import 'package:solomon/shared/widgets/app_tile.dart';

class PortfolioCard extends StatelessWidget {
  const PortfolioCard({super.key, required this.portfolio});

  final PortfolioModel portfolio;

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: portfolio.name ?? '',
      subtitle: AppFormatter.formatCurrency(portfolio.value),
      trailing: PortfolioStatusBadge(status: portfolio.statusEnum),
      onTap: () => context.push(
        AppRoute.portfolioDetails.path.replaceFirst(':portfolioId', '${portfolio.id}'),
        extra: portfolio,
      ),
    );
  }
}
```

---

## Design Rules

- **Never hardcode colors** — use `context.colorScheme.*` or `context.textTheme.*`.
- **Never hardcode strings** — use `Strings.instance.*` or `Strings.of(context).*`.
- Prefer `HugeIcons` or `SolarIconsPack` over Material icons for consistency.
- All interactive widgets must have an `onTap`/`onPressed` callback — never make them silently non-interactive.
- Use `const` constructors wherever possible to optimize rebuild performance.
- Handle `null` model fields defensively — use `?? ''` or `?? 0` when accessing optional fields.
- Use `AppSkeletonizer` for loading states instead of hiding the widget entirely.
