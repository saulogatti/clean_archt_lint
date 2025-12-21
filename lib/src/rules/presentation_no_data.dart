import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Lint rule that discourages the presentation layer from depending on data.
///
/// The presentation layer should depend only on core (usecases and contracts).
/// Concrete implementations should be injected via dependency injection,
/// respecting the dependency inversion principle.
///
/// ## Severity
///
/// WARNING (default) - Can be configured to ERROR via `analysis_options.yaml`
///
/// ## Dependency rule
///
/// ```
/// presentation → core ← data
/// ```
///
/// Presentation should not know concrete implementations from the data layer.
///
/// ## Configuration
///
/// To transform into ERROR, add to `analysis_options.yaml`:
///
/// ```yaml
/// analyzer:
///   errors:
///     presentation_no_data: error
/// ```
///
/// ## Violation example
///
/// ```dart
/// // ⚠️ Warning - presentation/controllers/user_controller.dart
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
///
/// class UserController {
///   final UserRepositoryImpl repository; // Knows concrete implementation
///   
///   UserController() : repository = UserRepositoryImpl(); // Direct coupling
/// }
/// ```
///
/// ## Solution
///
/// ```dart
/// // ✅ Correct - presentation/controllers/user_controller.dart
/// import 'package:my_app/core/contracts/user_repository.dart';
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserController {
///   final GetUser getUser; // Depends on core usecase
///   
///   UserController(this.getUser); // Implementation injected
/// }
///
/// // ✅ Correct - main.dart (or DI container)
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
///
/// void main() {
///   final repository = UserRepositoryImpl();
///   final getUser = GetUser(repository);
///   final controller = UserController(getUser); // Dependency injection
/// }
/// ```
class PresentationNoData extends DartLintRule {
  static const _code = LintCode(
    name: 'presentation_no_data',
    problemMessage: 'Presentation should not depend directly on Data.',
    correctionMessage:
        'Depend only on Core (usecases/contracts) and inject implementations.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// Creates an instance of the [PresentationNoData] rule.
  const PresentationNoData() : super(code: _code);

  /// Runs the analysis to detect direct data dependencies in presentation.
  ///
  /// Traverses all import directives in the current file and, if the file
  /// is in the presentation layer, resolves each import and checks if it points
  /// to the data layer. Reports a warning (or error, if configured) if
  /// violations are found.
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final filePath = resolver.path;

      // Checks if the file is in the presentation layer
      if (!isInLayer(filePath, 'presentation')) {
        return;
      }

      final uri = node.uri.stringValue;
      if (uri == null) return;

      // Ignores dart: imports and external packages
      if (uri.startsWith('dart:') ||
          (uri.startsWith('package:') && uri.contains('/presentation/'))) {
        return;
      }

      // Resolves the import using utility functions
      final sourceFilePath = resolver.source.uri.toFilePath();
      final projectRoot = extractProjectRoot(sourceFilePath);
      final packageName = extractPackageName(uri);

      final resolved = resolveImport(
        node,
        filePath,
        packageName,
        projectRoot,
      );

      if (resolved == null) return;

      // Checks if it imports from data
      if (importsFromLayer(resolved.resolvedPath, 'data')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
