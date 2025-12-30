// import 'package:analyzer/error/error.dart' hide LintCode;
// import 'package:analyzer/error/listener.dart';
// import 'package:custom_lint_builder/custom_lint_builder.dart';

// import '../utils/import_resolver.dart';

// /// Lint rule that prohibits Flutter imports in the core layer.
// ///
// /// The core layer should be completely independent of UI and frameworks,
// /// containing only pure business logic. This rule ensures that no
// /// code in the core layer imports Flutter or UI-related libraries.
// ///
// /// ## Severity
// ///
// /// ERROR - Violates the fundamental principle of Clean Architecture
// ///
// /// ## Blocked imports
// ///
// /// - `package:flutter/...` (all Flutter imports)
// /// - `package:flutter_test/...` (Flutter test library)
// /// - `dart:ui` (Dart UI library used by Flutter)
// ///
// /// ## Violation example
// ///
// /// ```dart
// /// // ❌ Wrong - core/usecases/get_user.dart
// /// import 'package:flutter/material.dart';
// ///
// /// class GetUser {
// ///   Widget buildWidget() => Container(); // Should not have UI in core
// /// }
// /// ```
// ///
// /// ## Solution
// ///
// /// ```dart
// /// // ✅ Correct - core/usecases/get_user.dart
// /// class GetUser {
// ///   User call(String id) {
// ///     // Only pure business logic
// ///   }
// /// }
// ///
// /// // ✅ Correct - presentation/widgets/user_widget.dart
// /// import 'package:flutter/material.dart';
// /// import 'package:my_app/core/usecases/get_user.dart';
// ///
// /// class UserWidget extends StatelessWidget {
// ///   // UI in the correct layer
// /// }
// /// ```
// class CoreNoFlutter extends DartLintRule {
//   static const _code = LintCode(
//     name: 'core_no_flutter',
//     problemMessage: 'Core cannot depend on Flutter/UI.',
//     correctionMessage: 'Move this code to presentation or abstract it.',
//     errorSeverity: ErrorSeverity.WARNING,
//   );

//   /// Creates an instance of the [CoreNoFlutter] rule.
//   const CoreNoFlutter() : super(code: _code);

//   /// Runs the analysis to detect Flutter imports in the core layer.
//   ///
//   /// Traverses all import directives in the current file and, if the file
//   /// is in the core layer, checks for Flutter imports. Reports an
//   /// error if violations are found.
//   @override
//   void run(
//     CustomLintResolver resolver,
//     ErrorReporter reporter,
//     CustomLintContext context,
//   ) {
//     context.registry.addImportDirective((node) {
//       final filePath = resolver.path;

//       // Checks if the file is in the core layer
//       if (!isInLayer(filePath, 'core')) {
//         return;
//       }

//       final uri = node.uri.stringValue;
//       if (uri == null) return;

//       // Checks if it's a Flutter import
//       if (isFlutterImport(uri)) {
//         reporter.atNode(node, _code);
//       }
//     });
//   }
// }
