# Contributing to clean_arch_lint

Thank you for considering contributing to clean_arch_lint! 🎉

## How to Contribute

### Reporting Bugs

1. Check if the bug hasn't already been reported in [Issues](https://github.com/saulogatti/clean_arch_lint/issues)
2. Open a new issue including:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs. actual behavior
   - Dart/Flutter version
   - Code example that causes the problem

### Suggesting Improvements

1. Open an issue with the `enhancement` tag
2. Describe clearly:
   - The problem the improvement solves
   - The proposed solution
   - Usage examples

### Contributing Code

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/your-username/clean_arch_lint.git
   cd clean_arch_lint
   ```

3. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/my-feature
   ```

4. **Install dependencies**:
   ```bash
   dart pub get
   ```

5. **Make your changes** following the standards:
   - Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
   - Use descriptive names for variables and functions
   - Add comments when necessary
   - Keep lines up to 80 characters when possible

6. **Add tests** for your changes:
   ```bash
   dart test
   ```

7. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new feature X"
   ```
   
   Use [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for adding/modifying tests
   - `refactor:` for refactorings

8. **Push to your fork**:
   ```bash
   git push origin feature/my-feature
   ```

9. **Open a Pull Request** explaining:
   - What was changed
   - Why it was changed
   - How to test the changes

## Project Structure

```
clean_arch_lint/
├── lib/
│   ├── clean_arch_lint.dart       # Plugin entry point
│   └── src/
│       ├── rules/                   # Lint rules
│       │   ├── core_no_flutter.dart
│       │   ├── core_no_data_or_presentation.dart
│       │   ├── data_no_presentation.dart
│       │   └── presentation_no_data.dart
│       └── utils/
│           └── import_resolver.dart # Import resolution utilities
├── example/                         # Usage example
├── test/                           # Tests
└── docs/                           # Additional documentation
```

## Adding a New Lint Rule

1. **Create the rule file** in `lib/src/rules/`:
   ```dart
   // lib/src/rules/my_rule.dart
   import 'package:analyzer/error/error.dart';
   import 'package:analyzer/error/listener.dart';
   import 'package:custom_lint_builder/custom_lint_builder.dart';
   
   class MyRule extends DartLintRule {
     const MyRule() : super(code: _code);
     
     static const _code = LintCode(
       name: 'my_rule',
       problemMessage: 'Problem description',
       correctionMessage: 'How to fix',
       errorSeverity: ErrorSeverity.WARNING,
     );
     
     @override
     void run(
       CustomLintResolver resolver,
       ErrorReporter reporter,
       CustomLintContext context,
     ) {
       // Rule implementation
     }
   }
   ```

2. **Register the rule** in `lib/clean_arch_lint.dart`:
   ```dart
   import 'src/rules/my_rule.dart';
   
   class _CleanArchitectureLintPlugin extends PluginBase {
     @override
     List<LintRule> getLintRules(CustomLintConfigs configs) => [
           // ... other rules
           const MyRule(),
         ];
   }
   ```

3. **Add tests** in `test/`:
   ```dart
   test('my_rule detects violations correctly', () {
     // Test here
   });
   ```

4. **Document** in README.md and USAGE.md

5. **Add example** in `example/`

## Testing Locally

### Test the main package:
```bash
dart test
```

### Test with the example:
```bash
cd example
dart pub get
dart run custom_lint
```

### Test with a real project:
```bash
# In your test project
dart pub get
dart run custom_lint
```

## Code Standards

### Documentation

- Use `///` for doc comments
- Document all public APIs
- Include examples when appropriate

### Naming

- Classes: `UpperCamelCase`
- Functions/variables: `lowerCamelCase`
- Constants: `lowerCamelCase` (preferred) or `SCREAMING_CAPS`
- Files: `snake_case.dart`

### Imports

1. Imports `dart:`
2. Imports `package:`
3. Relative imports
4. Alphabetical ordering in each group

Example:
```dart
import 'dart:async';

import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';
```

## Code of Conduct

- Be respectful and professional
- Accept constructive feedback
- Focus on what's best for the project
- Be patient with new contributors

## Questions?

Open an issue with the `question` tag or contact us through the repository.

Thank you for contributing! 🚀
