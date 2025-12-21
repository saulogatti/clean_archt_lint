// VIOLATION EXAMPLE: core_no_flutter
// This file demonstrates the error that will be reported
// when core tries to import Flutter.

// ignore_for_file: unused_import

// ❌ ERROR: Core cannot depend on Flutter/UI
// import 'package:flutter/material.dart';

/// This is a commented example to not break the build.
/// Uncomment the import above to see the lint in action.
class BadExampleFlutter {
  void someMethod() {
    // Attempting to use Flutter in core
  }
}
