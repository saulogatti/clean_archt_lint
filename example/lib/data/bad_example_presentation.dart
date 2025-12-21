// VIOLATION EXAMPLE: data_no_presentation
// This file demonstrates the error that will be reported
// when data tries to import presentation.

// ignore_for_file: unused_import

// ❌ ERROR: Data cannot depend on Presentation
// import '../presentation/pages/user_page.dart';

/// This is a commented example to not break the build.
/// Uncomment the import above to see the lint in action.
class BadExamplePresentation {
  void someMethod() {
    // Attempting to use presentation in data
  }
}
