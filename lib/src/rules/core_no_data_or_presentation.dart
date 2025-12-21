import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Lint rule that prohibits the core layer from depending on data or presentation.
///
/// The core should be the innermost layer of the architecture, containing only
/// pure business logic and contracts (interfaces). It cannot have dependencies
/// on technical implementations (data) or UI (presentation).
///
/// ## Severity
///
/// ERROR - Violates the Clean Architecture principle (dependency inversion)
///
/// ## Dependency rule
///
/// ```
/// presentation → core ← data
/// ```
///
/// The core defines the contracts, and the outer layers implement them.
///
/// ## Violation example
///
/// ```dart
/// // ❌ Wrong - core/usecases/get_user.dart
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
///
/// class GetUser {
///   final UserRepositoryImpl repository; // Should not know implementation
/// }
/// ```
///
/// ## Solution
///
/// ```dart
/// // ✅ Correct - core/contracts/user_repository.dart
/// abstract class UserRepository {
///   Future<User> getUser(String id);
/// }
///
/// // ✅ Correct - core/usecases/get_user.dart
/// import 'package:my_app/core/contracts/user_repository.dart';
///
/// class GetUser {
///   final UserRepository repository; // Depends only on the contract
/// }
///
/// // ✅ Correct - data/repositories/user_repository_impl.dart
/// import 'package:my_app/core/contracts/user_repository.dart';
///
/// class UserRepositoryImpl implements UserRepository {
///   // Technical implementation in the data layer
/// }
/// ```
class CoreNoDataOrPresentation extends DartLintRule {
  static const _code = LintCode(
    name: 'core_no_data_or_presentation',
    problemMessage: 'Core cannot depend on Data or Presentation.',
    correctionMessage:
        'Define contracts in Core and implement in Data. The UI consumes only Core.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// Creates an instance of the [CoreNoDataOrPresentation] rule.
  const CoreNoDataOrPresentation() : super(code: _code);

  /// Runs the analysis to detect unwanted dependencies from core.
  ///
  /// Traverses all import directives in the current file and, if the file
  /// is in the core layer, resolves each import and checks if it points to
  /// the data or presentation layers. Reports an error if violations are found.
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final filePath = resolver.path;

      // Checks if the file is in the core layer
      if (!isInLayer(filePath, 'core')) {
        return;
      }

      final uri = node.uri.stringValue;
      if (uri == null) return;

      // Ignores dart: imports and packages that are from core itself
      if (uri.startsWith('dart:') ||
          (uri.startsWith('package:') && uri.contains('/core/'))) {
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

      // Checks if it imports from data or presentation
      if (importsFromLayer(resolved.resolvedPath, 'data') ||
          importsFromLayer(resolved.resolvedPath, 'presentation')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
