/// Utilities for resolving and analyzing imports in Dart/Flutter projects.
///
/// This module provides helper functions to analyze import directives,
/// resolve file paths, and determine relationships between layers
/// of clean architecture.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

/// Represents a resolved import with information about its location.
///
/// Contains both the normalized file path and the original URI,
/// allowing tracking of the import's origin during static analysis.
///
/// ## Example
///
/// ```dart
/// final resolved = ResolvedImport(
///   resolvedPath: '/project/lib/core/entities/user.dart',
///   originalUri: 'package:my_app/core/entities/user.dart',
/// );
/// ```
class ResolvedImport {
  /// Normalized and absolute path of the imported file.
  ///
  /// Uses `/` as directory separator regardless of operating system.
  final String resolvedPath;

  /// Original URI from the import directive, without modifications.
  ///
  /// Can be a package import (`package:...`), relative import (`../...`),
  /// or dart import (`dart:...`).
  final String originalUri;

  /// Creates an instance of [ResolvedImport].
  const ResolvedImport({
    required this.resolvedPath,
    required this.originalUri,
  });
}

/// Normalizes a file path to use `/` as separator.
///
/// Resolves path segments (like `.` and `..`) and ensures compatibility
/// between Windows, macOS, and Linux, converting backslashes (`\`) to
/// forward slashes (`/`).
///
/// ## Example
///
/// ```dart
/// normalizePath('lib\\core\\user.dart'); // Returns: 'lib/core/user.dart'
/// normalizePath('lib/core/user.dart');   // Returns: 'lib/core/user.dart'
/// normalizePath('lib/core/../data/user.dart'); // Returns: 'lib/data/user.dart'
/// ```
String normalizePath(String path) {
  return p.normalize(path).replaceAll(r'\', '/');
}

/// Checks if a file is within a specific layer.
///
/// Analyzes the file path to determine if it belongs to the layer
/// indicated by [layerName]. Detection is based on the standard
/// Clean Architecture directory structure: `/lib/{layer}/` or `/lib/src/{layer}/`.
///
/// The [filePath] should be an absolute or relative path that contains the
/// structure `/lib/{layer}/` or `/lib/src/{layer}/`. The [layerName] should be
/// one of the valid layers: 'core', 'data', or 'presentation'.
///
/// Returns `true` if the file is in the specified layer, `false` otherwise.
///
/// ## Examples
///
/// ```dart
/// isInLayer('/project/lib/core/entities/user.dart', 'core');            // true
/// isInLayer('/project/lib/src/core/entities/user.dart', 'core');        // true
/// isInLayer('/project/lib/data/models/user_model.dart', 'core');        // false
/// isInLayer('/project/lib/presentation/pages/home.dart', 'data');       // false
/// isInLayer('lib/core', 'core');                                         // true
/// isInLayer('lib/src/core', 'core');                                     // true
/// ```
bool isInLayer(String filePath, String layerName) {
  final normalized = normalizePath(filePath);
  return normalized.contains('/lib/$layerName/') ||
      normalized.endsWith('/lib/$layerName') ||
      normalized.contains('/lib/src/$layerName/') ||
      normalized.endsWith('/lib/src/$layerName');
}

/// Resolves an import to its normalized absolute path.
///
/// This function analyzes an [importDirective] from the AST and converts the import URI
/// to an absolute file path, when applicable. Supports different
/// import formats:
///
/// - **Package imports**: `package:my_app/core/user.dart`
/// - **Relative imports**: `../data/models.dart`, `./utils.dart`
/// - **Dart imports**: `dart:core` (returns null, as they are not local files)
///
/// ## Parameters
///
/// - [importDirective]: The import directive extracted from the AST by the analyzer
/// - [currentFilePath]: Absolute path of the file that contains the import
/// - [packageName]: Name of the current project's package (e.g., 'my_app')
/// - [projectRoot]: Absolute path of the project root (directory containing `lib/`)
///
/// Returns a [ResolvedImport] with the resolved path, or `null` if the import
/// cannot be resolved (e.g., dart imports, string interpolation in the URI).
///
/// ## Examples
///
/// ```dart
/// // Package import from the project itself
/// resolveImport(
///   node,
///   '/project/lib/presentation/pages/home.dart',
///   'my_app',
///   '/project',
/// );
/// // Returns: ResolvedImport(
/// //   resolvedPath: '/project/lib/core/entities/user.dart',
/// //   originalUri: 'package:my_app/core/entities/user.dart'
/// // )
///
/// // Relative import
/// resolveImport(
///   node,
///   '/project/lib/data/repositories/user_repo.dart',
///   'my_app',
///   '/project',
/// );
/// // Returns: ResolvedImport(
/// //   resolvedPath: '/project/lib/data/models/user_model.dart',
/// //   originalUri: '../models/user_model.dart'
/// // )
/// ```
ResolvedImport? resolveImport(
  ImportDirective importDirective,
  String currentFilePath,
  String? packageName,
  String projectRoot,
) {
  final uri = importDirective.uri.stringValue;
  // Returns null if the URI cannot be extracted (e.g., string interpolation)
  if (uri == null) return null;

  // Ignores dart: imports and package: imports from third parties that are not from the current package
  if (uri.startsWith('dart:')) {
    return null;
  }

  // If it's a package import from the project itself
  if (packageName != null && uri.startsWith('package:$packageName/')) {
    final relativePath = uri.substring('package:$packageName/'.length);
    final resolvedPath = normalizePath(p.join(projectRoot, 'lib', relativePath));
    return ResolvedImport(
      resolvedPath: resolvedPath,
      originalUri: uri,
    );
  }

  // If it's a relative import
  if (uri.startsWith('./') || uri.startsWith('../')) {
    final currentDir = p.dirname(currentFilePath);
    final resolvedPath = normalizePath(p.normalize(p.join(currentDir, uri)));
    return ResolvedImport(
      resolvedPath: resolvedPath,
      originalUri: uri,
    );
  }

  // Third-party imports (e.g., package:flutter/material.dart)
  // Returns the import as is for validation
  if (uri.startsWith('package:')) {
    return ResolvedImport(
      resolvedPath: uri,
      originalUri: uri,
    );
  }

  return null;
}

/// Checks if an import points to a specific layer.
///
/// Analyzes the resolved path of an import to determine if it references
/// a file within the layer specified by [layerName].
///
/// The [resolvedPath] should be a normalized path (obtained from [resolveImport]),
/// and [layerName] should be one of the valid layers: 'core', 'data', or 'presentation'.
///
/// Returns `true` if the import points to the specified layer, `false` otherwise.
///
/// ## Examples
///
/// ```dart
/// importsFromLayer('/project/lib/core/entities/user.dart', 'core');         // true
/// importsFromLayer('/project/lib/src/core/entities/user.dart', 'core');     // true
/// importsFromLayer('/project/lib/data/models/user.dart', 'data');           // true
/// importsFromLayer('/project/lib/core/entities/user.dart', 'data');         // false
/// ```
bool importsFromLayer(String resolvedPath, String layerName) {
  return resolvedPath.contains('/lib/$layerName/') ||
      resolvedPath.contains('/lib/src/$layerName/');
}

/// Checks if an import is from a Flutter package or related.
///
/// Detects imports from Flutter and UI libraries that should not be
/// used in the core layer. Includes:
///
/// - Flutter packages: `package:flutter/...`
/// - Flutter test packages: `package:flutter_test/...`
/// - dart:ui library (used internally by Flutter)
///
/// Returns `true` if the [uri] is from Flutter/UI, `false` otherwise.
///
/// ## Examples
///
/// ```dart
/// isFlutterImport('package:flutter/material.dart');      // true
/// isFlutterImport('package:flutter/widgets.dart');       // true
/// isFlutterImport('package:flutter_test/flutter_test.dart'); // true
/// isFlutterImport('dart:ui');                            // true
/// isFlutterImport('dart:core');                          // false
/// isFlutterImport('package:my_app/core/user.dart');     // false
/// ```
bool isFlutterImport(String uri) {
  return uri.startsWith('package:flutter/') ||
      uri.startsWith('package:flutter_test/') ||
      uri == 'dart:ui';
}

/// Extracts the project root path from a file path.
///
/// Analyzes the [filePath] and returns the path to the directory containing `lib/`.
/// This is typically the Dart/Flutter project root directory.
///
/// If the `lib/` directory is not found in the path, returns the parent
/// directory of the file as a fallback.
///
/// ## Examples
///
/// ```dart
/// extractProjectRoot('/home/user/project/lib/core/user.dart');
/// // Returns: '/home/user/project'
///
/// extractProjectRoot('/project/lib/data/models/user_model.dart');
/// // Returns: '/project'
///
/// extractProjectRoot('/project/test/widget_test.dart');
/// // Returns: '/project/test' (fallback - directory containing the file)
/// ```
String extractProjectRoot(String filePath) {
  final segments = filePath.split('/');
  final libIndex = segments.lastIndexOf('lib');
  
  if (libIndex >= 0) {
    return segments.sublist(0, libIndex).join('/');
  }
  
  // Fallback: returns parent directory
  return segments.sublist(0, segments.length - 1).join('/');
}

/// Extracts the package name from an import URI.
///
/// Analyzes the [uri] and returns the package name if it's a package import
/// (format `package:package_name/...`).
///
/// Returns `null` if the URI is not a valid package import or if it's
/// malformed.
///
/// ## Examples
///
/// ```dart
/// extractPackageName('package:flutter/material.dart');      // Returns: 'flutter'
/// extractPackageName('package:my_app/core/user.dart');      // Returns: 'my_app'
/// extractPackageName('dart:core');                          // Returns: null
/// extractPackageName('../relative/path.dart');              // Returns: null
/// extractPackageName('./local/file.dart');                  // Returns: null
/// ```
String? extractPackageName(String uri) {
  if (!uri.startsWith('package:')) {
    return null;
  }
  
  final parts = uri.split('/');
  if (parts.isEmpty) return null;
  
  return parts.first.substring('package:'.length);
}
