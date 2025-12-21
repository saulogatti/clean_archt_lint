# clean_arch_lint Usage Example

This example demonstrates how to use `clean_arch_lint` to ensure clean architecture in Flutter/Dart projects.

## Structure

```
lib/
 ├─ core/
 │   ├─ entities/
 │   │   └─ user.dart
 │   └─ usecases/
 │       └─ get_user.dart
 ├─ data/
 │   ├─ models/
 │   │   └─ user_model.dart
 │   └─ repositories/
 │       └─ user_repository_impl.dart
 └─ presentation/
     └─ pages/
         └─ user_page.dart
```

## How to Test the Lints

1. Run the example to see the correct structure:
   ```bash
   dart run clean_archt_lint_example.dart
   ```

2. To see the lints in action, uncomment the imports in the files:
   - `lib/core/bad_example_flutter.dart` - Demonstrates `core_no_flutter`
   - `lib/core/bad_example_data.dart` - Demonstrates `core_no_data_or_presentation`
   - `lib/data/bad_example_presentation.dart` - Demonstrates `data_no_presentation`
   - `lib/presentation/bad_example_data.dart` - Demonstrates `presentation_no_data`

3. Run custom_lint:
   ```bash
   dart run custom_lint
   ```

## Rules Demonstrated

### ✅ Allowed imports

- **core** → core
- **data** → core, data
- **presentation** → core, presentation

### ❌ Prohibited imports

- **core** → Flutter/UI (ERROR)
- **core** → data, presentation (ERROR)
- **data** → presentation (ERROR)
- **presentation** → data (WARNING configurable to ERROR)

## Correct Architecture

```dart
// Dependency Injection
final GetUser getUser = UserRepositoryImpl();

// Presentation receives only the contract from core
final userPage = UserPage(getUser: getUser);

// Uses the usecase
await userPage.loadUser('1');
```

Presentation depends only on the abstraction (GetUser from core), and the implementation (UserRepositoryImpl from data) is injected via DI.
