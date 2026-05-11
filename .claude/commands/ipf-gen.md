# IPF Generator — Add or Update a Model

Use this skill to add a new model to the IPF generator or update an existing one. After running generation the model gets a 3-layer architecture: generator spec → auto-generated base (`.g.dart`) → concrete model.

## Arguments
`$ARGUMENTS` — model name and field definitions, e.g. `Portfolio: id:int, name:String, value:double, status:int`

---

## How the IPF Generator Works

**File:** `ipf_generator.dart` (project root)
**Run command:** `make ipf_gen`  (expands to `flutter test ipf_generator.dart`)

The generator produces, for each model:
- `lib/starter_models/<model>_model.g.dart` — `<Model>ModelGen extends BaseDatabaseModel`
  - `fromJson(Map)` — camelCase JSON keys, uses `BaseModel.castTo*` helpers
  - `fromDatabase(Map)` — snake_case DB column keys
  - `toMap` — snake_case for SQLite insertion
  - `toJson` — camelCase for API serialization
  - `toSchema` — SQLite column type map (`"INTEGER PRIMARY KEY"`, `"TEXT"`, `"REAL"`, `"INTEGER"`)
  - `merge`, `mergeWith`, `copy`, `copyWith`
- `lib/repositories/<model>_repository.dart` — `<Model>Repository extends BaseRepository<<Model>Model>`
- `lib/dao/<model>_model_dao.dart` — static `const String` column name constants

## Step-by-step Instructions

### 1. Decide: DB-backed model or JSON-only model?

| Use `super.database(...)` | Use `super(...)` |
|---|---|
| Needs SQLite persistence (most models) | API-response only, not stored locally (e.g. `_Trends`, `_Wallet`) |

### 2. Add the generator class to `ipf_generator.dart`

**DB-backed model:**
```dart
class _Portfolio extends BaseModelGenerator {
  _Portfolio()
    : super.database('portfolio', {
        'id': int,
        'name': String,
        'value': double,
        'status': int,
        'createdAt': String,
      });
}
```

**JSON-only model:**
```dart
class _Portfolio extends BaseModelGenerator {
  _Portfolio()
    : super({
        'id': int,
        'name': String,
        'value': double,
      });
}
```

### 3. Register the class in the generator list

In the `main()` function inside `ipf_generator.dart`, add `_Portfolio()` to the list:

```dart
List<BaseModelGenerator> generator = [
  // ... existing models ...
  _Portfolio(),  // ADD HERE
];
```

### 4. Register the table in `DatabaseManager` (DB-backed only)

**File:** `lib/services/database_manager.dart`

Add a `PortfolioModel()` instance to the list of tables in `DatabaseManager`:
```dart
// Find the tables list and add:
PortfolioModel(),
```

### 5. Run code generation

```bash
make ipf_gen
```

This writes `lib/starter_models/portfolio_model.g.dart`, `lib/repositories/portfolio_repository.dart`, and `lib/dao/portfolio_model_dao.dart`.

### 6. Create the concrete model

**File:** `lib/models/portfolio_model.dart`

```dart
import 'package:solomon/starter_models/portfolio_model.g.dart';

class PortfolioModel extends PortfolioModelGen {
  factory PortfolioModel.fromDatabase(Map<String, dynamic> map) =>
      PortfolioModelGen.fromDatabase(map);

  factory PortfolioModel.fromJson(Map<String, dynamic> map) =>
      PortfolioModelGen.fromJson(map);
}
```

Add any custom serialization methods, computed getters, or business logic in this class — **never edit the `.g.dart` file directly**.

## Type Mapping Rules

| Dart type in generator | SQLite column type | JSON cast helper |
|---|---|---|
| `int` | `INTEGER` (first `int` field = `INTEGER PRIMARY KEY`) | `BaseModel.castToInt` |
| `String` | `TEXT` | `BaseModel.castToString` |
| `double` | `REAL` | `BaseModel.castToDouble` |
| `bool` | `INTEGER` (0/1) | `BaseModel.castToBool` |

## Do's and Don'ts

- **Do** always include `'id': int` as the first field for DB-backed models (becomes `INTEGER PRIMARY KEY`).
- **Do** always include `'createdAt': String` for DB-backed models.
- **Do not** edit `*.g.dart` files — they are fully regenerated on every `make ipf_gen` run.
- **Do not** use complex types (List, Map) as field types — store as serialized `String` and deserialize in the concrete model.
- **Do** add enum-typed fields as `int` in the generator and cast to the enum in the concrete model's getters.
