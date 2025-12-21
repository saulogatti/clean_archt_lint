// VIOLATION EXAMPLE: presentation_no_data
// This file demonstrates the WARNING that will be reported
// when presentation tries to import data directly.

// ignore_for_file: unused_import

// ⚠️ WARNING: Presentation should not depend directly on Data
// import '../data/repositories/user_repository_impl.dart';

/// This is a commented example to not break the build.
/// Uncomment the import above to see the lint in action.
///
/// The correct solution is:
/// 1. Depend only on the core contract (GetUser)
/// 2. Inject the implementation (UserRepositoryImpl) via DI
class BadExampleData {
  void someMethod() {
    // Attempting to use data directly in presentation
  }
}
