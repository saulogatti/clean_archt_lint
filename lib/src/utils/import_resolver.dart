/// Utilitários para resolução e análise de imports em projetos Dart/Flutter.
///
/// Este módulo fornece funções auxiliares para analisar diretivas de import,
/// resolver caminhos de arquivos e determinar relacionamentos entre camadas
/// da arquitetura limpa.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

/// Representa um import resolvido com informações sobre sua localização.
///
/// Contém tanto o caminho normalizado do arquivo quanto o URI original,
/// permitindo rastrear a origem do import durante a análise estática.
///
/// ## Exemplo
///
/// ```dart
/// final resolved = ResolvedImport(
///   resolvedPath: '/projeto/lib/core/entities/user.dart',
///   originalUri: 'package:my_app/core/entities/user.dart',
/// );
/// ```
class ResolvedImport {
  /// Caminho normalizado e absoluto do arquivo importado.
  ///
  /// Usa `/` como separador de diretórios independente do sistema operacional.
  final String resolvedPath;

  /// URI original da diretiva de import, sem modificações.
  ///
  /// Pode ser um import de pacote (`package:...`), import relativo (`../...`),
  /// ou import dart (`dart:...`).
  final String originalUri;

  /// Cria uma instância de [ResolvedImport].
  const ResolvedImport({
    required this.resolvedPath,
    required this.originalUri,
  });
}

/// Normaliza um caminho de arquivo para usar `/` como separador.
///
/// Resolve segmentos de caminho (como `.` e `..`) e garante compatibilidade
/// entre Windows, macOS e Linux, convertendo barras invertidas (`\`) em
/// barras normais (`/`).
///
/// ## Exemplo
///
/// ```dart
/// normalizePath('lib\\core\\user.dart'); // Retorna: 'lib/core/user.dart'
/// normalizePath('lib/core/user.dart');   // Retorna: 'lib/core/user.dart'
/// normalizePath('lib/core/../data/user.dart'); // Retorna: 'lib/data/user.dart'
/// ```
String normalizePath(String path) {
  return p.normalize(path).replaceAll(r'\', '/');
}

/// Verifica se um arquivo está dentro de uma camada específica.
///
/// Analisa o caminho do arquivo para determinar se ele pertence à camada
/// indicada por [layerName]. A detecção é baseada na estrutura de diretórios
/// padrão do Clean Architecture: `/lib/{camada}/` ou `/lib/src/{camada}/`.
///
/// O [filePath] deve ser um caminho absoluto ou relativo que contenha a
/// estrutura `/lib/{camada}/` ou `/lib/src/{camada}/`. O [layerName] deve ser
/// uma das camadas válidas: 'core', 'data' ou 'presentation'.
///
/// Retorna `true` se o arquivo estiver na camada especificada, `false` caso contrário.
///
/// ## Exemplos
///
/// ```dart
/// isInLayer('/projeto/lib/core/entities/user.dart', 'core');            // true
/// isInLayer('/projeto/lib/src/core/entities/user.dart', 'core');        // true
/// isInLayer('/projeto/lib/data/models/user_model.dart', 'core');        // false
/// isInLayer('/projeto/lib/presentation/pages/home.dart', 'data');       // false
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

/// Resolve um import para seu caminho absoluto normalizado.
///
/// Esta função analisa uma [importDirective] do AST e converte o URI do import
/// em um caminho de arquivo absoluto, quando aplicável. Suporta diferentes
/// formatos de import:
///
/// - **Imports de pacote**: `package:my_app/core/user.dart`
/// - **Imports relativos**: `../data/models.dart`, `./utils.dart`
/// - **Imports dart**: `dart:core` (retorna null, pois não são arquivos locais)
///
/// ## Parâmetros
///
/// - [importDirective]: A diretiva de import extraída do AST pelo analyzer
/// - [currentFilePath]: Caminho absoluto do arquivo que contém o import
/// - [packageName]: Nome do pacote do projeto atual (ex: 'my_app')
/// - [projectRoot]: Caminho absoluto da raiz do projeto (diretório que contém `lib/`)
///
/// Retorna um [ResolvedImport] com o caminho resolvido, ou `null` se o import
/// não puder ser resolvido (ex: imports dart, interpolação de string no URI).
///
/// ## Exemplos
///
/// ```dart
/// // Import de pacote do próprio projeto
/// resolveImport(
///   node,
///   '/projeto/lib/presentation/pages/home.dart',
///   'my_app',
///   '/projeto',
/// );
/// // Retorna: ResolvedImport(
/// //   resolvedPath: '/projeto/lib/core/entities/user.dart',
/// //   originalUri: 'package:my_app/core/entities/user.dart'
/// // )
///
/// // Import relativo
/// resolveImport(
///   node,
///   '/projeto/lib/data/repositories/user_repo.dart',
///   'my_app',
///   '/projeto',
/// );
/// // Retorna: ResolvedImport(
/// //   resolvedPath: '/projeto/lib/data/models/user_model.dart',
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
/// Analisa o caminho resolvido de um import para determinar se ele referencia
/// um arquivo dentro da camada especificada por [layerName].
///
/// O [resolvedPath] deve ser um caminho normalizado (obtido de [resolveImport]),
/// e [layerName] deve ser uma das camadas válidas: 'core', 'data' ou 'presentation'.
///
/// Retorna `true` se o import aponta para a camada especificada, `false` caso contrário.
///
/// ## Exemplos
///
/// ```dart
/// importsFromLayer('/projeto/lib/core/entities/user.dart', 'core');         // true
/// importsFromLayer('/projeto/lib/src/core/entities/user.dart', 'core');     // true
/// importsFromLayer('/projeto/lib/data/models/user.dart', 'data');           // true
/// importsFromLayer('/projeto/lib/core/entities/user.dart', 'data');         // false
/// ```
bool importsFromLayer(String resolvedPath, String layerName) {
  return resolvedPath.contains('/lib/$layerName/') ||
      resolvedPath.contains('/lib/src/$layerName/');
}

/// Verifica se um import é de um pacote Flutter ou relacionado.
///
/// Detecta imports de bibliotecas Flutter e de UI que não devem ser
/// usados na camada core. Inclui:
///
/// - Pacotes Flutter: `package:flutter/...`
/// - Pacotes de teste Flutter: `package:flutter_test/...`
/// - Biblioteca dart:ui (usada internamente pelo Flutter)
///
/// Retorna `true` se o [uri] for de Flutter/UI, `false` caso contrário.
///
/// ## Exemplos
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

/// Extrai o caminho raiz do projeto a partir do caminho de um arquivo.
///
/// Analisa o [filePath] e retorna o caminho até o diretório que contém `lib/`.
/// Este é tipicamente o diretório raiz do projeto Dart/Flutter.
///
/// Se o diretório `lib/` não for encontrado no caminho, retorna o diretório
/// pai do arquivo como fallback.
///
/// ## Exemplos
///
/// ```dart
/// extractProjectRoot('/home/user/projeto/lib/core/user.dart');
/// // Retorna: '/home/user/projeto'
///
/// extractProjectRoot('/projeto/lib/data/models/user_model.dart');
/// // Retorna: '/projeto'
///
/// extractProjectRoot('/projeto/test/widget_test.dart');
/// // Retorna: '/projeto/test' (fallback - diretório que contém o arquivo)
/// ```
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
/// Analisa o [uri] e retorna o nome do pacote se for um import de pacote
/// (formato `package:nome_pacote/...`).
///
/// Retorna `null` se o URI não for um import de pacote válido ou se estiver
/// malformado.
///
/// ## Exemplos
///
/// ```dart
/// extractPackageName('package:flutter/material.dart');      // Retorna: 'flutter'
/// extractPackageName('package:my_app/core/user.dart');      // Retorna: 'my_app'
/// extractPackageName('dart:core');                          // Retorna: null
/// extractPackageName('../relative/path.dart');              // Retorna: null
/// extractPackageName('./local/file.dart');                  // Retorna: null
/// ```
String? extractPackageName(String uri) {
  if (!uri.startsWith('package:')) {
    return null;
  }
  
  final parts = uri.split('/');
  if (parts.isEmpty) return null;
  
  return parts.first.substring('package:'.length);
}
