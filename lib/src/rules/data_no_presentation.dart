import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Regra de lint que proíbe a camada data de depender de presentation.
///
/// A camada data contém implementações técnicas e infraestrutura (APIs,
/// banco de dados, serviços externos). Não deve ter conhecimento sobre
/// a UI ou componentes de apresentação.
///
/// ## Severidade
///
/// ERROR - Viola a separação de responsabilidades da Clean Architecture
///
/// ## Regra de dependência
///
/// ```
/// presentation → core ← data
/// ```
///
/// Data e presentation são camadas paralelas que dependem do core,
/// mas não devem conhecer uma à outra.
///
/// ## Exemplo de violação
///
/// ```dart
/// // ❌ Errado - data/datasources/api_datasource.dart
/// import 'package:my_app/presentation/controllers/user_controller.dart';
///
/// class ApiDataSource {
///   void notifyUI(UserController controller) {
///     // Camada data não deve conhecer controllers de UI
///   }
/// }
/// ```
///
/// ## Solução
///
/// ```dart
/// // ✅ Correto - data/datasources/api_datasource.dart
/// import 'package:my_app/core/entities/user.dart';
///
/// class ApiDataSource {
///   Future<User> fetchUser(String id) {
///     // Retorna entidades do core, não componentes de UI
///   }
/// }
///
/// // ✅ Correto - presentation/controllers/user_controller.dart
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserController {
///   final GetUser getUser; // Usa usecase do core, não datasource
/// }
/// ```
class DataNoPresentation extends DartLintRule {
  static const _code = LintCode(
    name: 'data_no_presentation',
    problemMessage: 'Data não pode depender de Presentation.',
    correctionMessage: 'Mova contratos para Core e injete dependências.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// Cria uma instância da regra [DataNoPresentation].
  const DataNoPresentation() : super(code: _code);

  /// Executa a análise para detectar dependências de presentation na camada data.
  ///
  /// Percorre todas as diretivas de import no arquivo atual e, se o arquivo
  /// estiver na camada data, resolve cada import e verifica se aponta para
  /// a camada presentation. Reporta um erro se encontrar violações.
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final filePath = resolver.path;

      // Verifica se o arquivo está na camada data
      if (!isInLayer(filePath, 'data')) {
        return;
      }

      final uri = node.uri.stringValue;
      if (uri == null) return;

      // Ignora imports dart: e de pacotes externos
      if (uri.startsWith('dart:') ||
          (uri.startsWith('package:') && uri.contains('/data/'))) {
        return;
      }

      // Resolve o import usando as funções utilitárias
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

      // Verifica se importa de presentation
      if (importsFromLayer(resolved.resolvedPath, 'presentation')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
