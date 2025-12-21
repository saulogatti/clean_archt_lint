import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Lint rule that prohibits the data layer from depending on presentation.
///
/// The data layer contains technical implementations and infrastructure (APIs,
/// database, external services). It should not have knowledge about
/// the UI or presentation components.
///
/// ## Severity
///
/// ERROR - Violates the separation of concerns of Clean Architecture
///
/// ## Dependency rule
///
/// ```
/// presentation → core ← data
/// ```
///
/// Data and presentation are parallel layers that depend on core,
/// but should not know about each other.
///
/// ## Violation example
///
/// ```dart
/// // ❌ Wrong - data/datasources/api_datasource.dart
/// import 'package:my_app/presentation/controllers/user_controller.dart';
///
/// class ApiDataSource {
///   void notifyUI(UserController controller) {
///     // Data layer should not know UI controllers
///   }
/// }
/// ```
///
/// ## Solution
///
/// ```dart
/// // ✅ Correct - data/datasources/api_datasource.dart
/// import 'package:my_app/core/entities/user.dart';
///
/// class ApiDataSource {
///   Future<User> fetchUser(String id) {
///     // Returns core entities, not UI components
///   }
/// }
///
/// // ✅ Correct - presentation/controllers/user_controller.dart
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserController {
///   final GetUser getUser; // Uses core usecase, not datasource
/// }
/// ```
class DataNoPresentation extends DartLintRule {
  static const _code = LintCode(
    name: 'data_no_presentation',
    problemMessage: 'Data cannot depend on Presentation.',
    correctionMessage: 'Move contracts to Core and inject dependencies.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// Creates an instance of the [DataNoPresentation] rule.
  const DataNoPresentation() : super(code: _code);

  /// Runs the analysis to detect presentation dependencies in the data layer.
  ///
  /// Traverses all import directives in the current file and, if the file
  /// is in the data layer, resolves each import and checks if it points to
  /// the presentation layer. Reports an error if violations are found.
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final filePath = resolver.path;

      // Checks if the file is in the data layer
      if (!isInLayer(filePath, 'data')) {
        return;
      }

      final uri = node.uri.stringValue;
      if (uri == null) return;

      // Ignores dart: imports and external packages
      if (uri.startsWith('dart:') ||
          (uri.startsWith('package:') && uri.contains('/data/'))) {
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

      // Checks if it imports from presentation
      if (importsFromLayer(resolved.resolvedPath, 'presentation')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
