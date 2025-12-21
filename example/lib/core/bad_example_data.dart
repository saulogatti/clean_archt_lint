// VIOLATION EXAMPLE: core_no_data_or_presentation
// This file demonstrates the error that will be reported
// when core tries to import data or presentation.

// ignore_for_file: unused_import

// ❌ ERROR: Core cannot depend on Data or Presentation
// import 'package:clean_archt_lint_example/data/models/user_model.dart';
// import 'package:clean_archt_lint_example/presentation/pages/user_page.dart';

/// This is a commented example to not break the build.
/// Uncomment the imports above to see the lint in action.
class BadExampleData {
  void someMethod() {
    // Attempting to use data or presentation in core
  }
}
