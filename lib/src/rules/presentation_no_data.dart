import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Regra de lint que desencoraja a camada presentation de depender de data.
///
/// A camada presentation deve depender apenas do core (usecases e contratos).
/// As implementações concretas devem ser injetadas via dependency injection,
/// respeitando o princípio da inversão de dependência.
///
/// ## Severidade
///
/// WARNING (padrão) - Pode ser configurado para ERROR via `analysis_options.yaml`
///
/// ## Regra de dependência
///
/// ```
/// presentation → core ← data
/// ```
///
/// Presentation não deve conhecer implementações concretas da camada data.
///
/// ## Configuração
///
/// Para transformar em ERROR, adicione em `analysis_options.yaml`:
///
/// ```yaml
/// analyzer:
///   errors:
///     presentation_no_data: error
/// ```
///
/// ## Exemplo de violação
///
/// ```dart
/// // ⚠️ Alerta - presentation/controllers/user_controller.dart
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
///
/// class UserController {
///   final UserRepositoryImpl repository; // Conhece implementação concreta
///   
///   UserController() : repository = UserRepositoryImpl(); // Acoplamento direto
/// }
/// ```
///
/// ## Solução
///
/// ```dart
/// // ✅ Correto - presentation/controllers/user_controller.dart
/// import 'package:my_app/core/contracts/user_repository.dart';
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserController {
///   final GetUser getUser; // Depende do usecase do core
///   
///   UserController(this.getUser); // Implementação injetada
/// }
///
/// // ✅ Correto - main.dart (ou DI container)
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
///
/// void main() {
///   final repository = UserRepositoryImpl();
///   final getUser = GetUser(repository);
///   final controller = UserController(getUser); // Injeção de dependência
/// }
/// ```
class PresentationNoData extends DartLintRule {
  static const _code = LintCode(
    name: 'presentation_no_data',
    problemMessage: 'Presentation não deve depender diretamente de Data.',
    correctionMessage:
        'Dependa apenas do Core (usecases/contratos) e injete implementações.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// Cria uma instância da regra [PresentationNoData].
  const PresentationNoData() : super(code: _code);

  /// Executa a análise para detectar dependências diretas de data na presentation.
  ///
  /// Percorre todas as diretivas de import no arquivo atual e, se o arquivo
  /// estiver na camada presentation, resolve cada import e verifica se aponta
  /// para a camada data. Reporta um warning (ou error, se configurado) se
  /// encontrar violações.
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final filePath = resolver.path;

      // Verifica se o arquivo está na camada presentation
      if (!isInLayer(filePath, 'presentation')) {
        return;
      }

      final uri = node.uri.stringValue;
      if (uri == null) return;

      // Ignora imports dart: e de pacotes externos
      if (uri.startsWith('dart:') ||
          (uri.startsWith('package:') && uri.contains('/presentation/'))) {
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

      // Verifica se importa de data
      if (importsFromLayer(resolved.resolvedPath, 'data')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
