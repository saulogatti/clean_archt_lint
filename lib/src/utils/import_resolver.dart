import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

/// Representa um import resolvido com informações sobre sua localização.
class ResolvedImport {
  /// Caminho normalizado do arquivo importado.
  final String resolvedPath;

  /// URI original do import.
  final String originalUri;

  const ResolvedImport({
    required this.resolvedPath,
    required this.originalUri,
  });
}

/// Normaliza um caminho de arquivo para usar `/` como separador.
///
/// Garante compatibilidade entre Windows, macOS e Linux.
String normalizePath(String path) {
  return p.normalize(path).replaceAll(r'\', '/');
}

/// Verifica se um arquivo está dentro de uma camada específica.
///
/// Exemplo:
/// ```dart
/// isInLayer('/lib/core/entities/user.dart', 'core') // true
/// isInLayer('/lib/data/models/user_model.dart', 'core') // false
/// ```
bool isInLayer(String filePath, String layerName) {
  final normalized = normalizePath(filePath);
  return normalized.contains('/lib/$layerName/') ||
      normalized.endsWith('/lib/$layerName');
}

/// Resolve um import para seu caminho absoluto.
///
/// Suporta:
/// - Imports de pacote: `package:my_app/core/user.dart`
/// - Imports relativos: `../data/models.dart`, `./utils.dart`
/// - Imports dart: `dart:core` (retorna null, pois não são arquivos locais)
///
/// [importDirective] é a diretiva de import do AST.
/// [currentFilePath] é o caminho absoluto do arquivo atual.
/// [packageName] é o nome do pacote do projeto (extraído do pubspec.yaml).
/// [projectRoot] é o caminho raiz do projeto.
ResolvedImport? resolveImport(
  ImportDirective importDirective,
  String currentFilePath,
  String? packageName,
  String projectRoot,
) {
  final uri = importDirective.uri.stringValue;
  // Retorna null se o URI não puder ser extraído (ex: interpolação de string)
  if (uri == null) return null;

  // Ignora imports dart: e package: de terceiros que não são do pacote atual
  if (uri.startsWith('dart:')) {
    return null;
  }

  // Se é um import de package do próprio projeto
  if (packageName != null && uri.startsWith('package:$packageName/')) {
    final relativePath = uri.substring('package:$packageName/'.length);
    final resolvedPath = normalizePath(p.join(projectRoot, 'lib', relativePath));
    return ResolvedImport(
      resolvedPath: resolvedPath,
      originalUri: uri,
    );
  }

  // Se é um import relativo
  if (uri.startsWith('./') || uri.startsWith('../')) {
    final currentDir = p.dirname(currentFilePath);
    final resolvedPath = normalizePath(p.normalize(p.join(currentDir, uri)));
    return ResolvedImport(
      resolvedPath: resolvedPath,
      originalUri: uri,
    );
  }

  // Imports de terceiros (ex: package:flutter/material.dart)
  // Retorna o import como está para validação
  if (uri.startsWith('package:')) {
    return ResolvedImport(
      resolvedPath: uri,
      originalUri: uri,
    );
  }

  return null;
}

/// Verifica se um import aponta para uma camada específica.
///
/// [resolvedPath] é o caminho resolvido do import.
/// [layerName] é o nome da camada (ex: 'core', 'data', 'presentation').
bool importsFromLayer(String resolvedPath, String layerName) {
  return resolvedPath.contains('/lib/$layerName/');
}

/// Verifica se um import é de um pacote Flutter.
bool isFlutterImport(String uri) {
  return uri.startsWith('package:flutter/') ||
      uri.startsWith('package:flutter_test/') ||
      uri == 'dart:ui';
}

/// Extrai o caminho raiz do projeto a partir do caminho do arquivo.
///
/// Retorna o caminho até o diretório que contém `lib/`.
String extractProjectRoot(String filePath) {
  final segments = filePath.split('/');
  final libIndex = segments.lastIndexOf('lib');
  
  if (libIndex >= 0) {
    return segments.sublist(0, libIndex).join('/');
  }
  
  // Fallback: retorna o diretório pai
  return segments.sublist(0, segments.length - 1).join('/');
}

/// Extrai o nome do pacote a partir de um URI de import.
///
/// Retorna null se o URI não for um import de pacote.
String? extractPackageName(String uri) {
  if (!uri.startsWith('package:')) {
    return null;
  }
  
  final parts = uri.split('/');
  if (parts.isEmpty) return null;
  
  return parts.first.substring('package:'.length);
}
