import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Regra de lint que proíbe a camada core de depender de data ou presentation.
///
/// O core deve ser a camada mais interna da arquitetura, contendo apenas
/// lógica de negócio pura e contratos (interfaces). Não pode ter dependências
/// de implementações técnicas (data) ou de UI (presentation).
///
/// ## Severidade
///
/// ERROR - Viola o princípio da Clean Architecture (inversão de dependência)
///
/// ## Regra de dependência
///
/// ```
/// presentation → core ← data
/// ```
///
/// O core define os contratos, e as camadas externas implementam.
///
/// ## Exemplo de violação
///
/// ```dart
/// // ❌ Errado - core/usecases/get_user.dart
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
///
/// class GetUser {
///   final UserRepositoryImpl repository; // Não deve conhecer implementação
/// }
/// ```
///
/// ## Solução
///
/// ```dart
/// // ✅ Correto - core/contracts/user_repository.dart
/// abstract class UserRepository {
///   Future<User> getUser(String id);
/// }
///
/// // ✅ Correto - core/usecases/get_user.dart
/// import 'package:my_app/core/contracts/user_repository.dart';
///
/// class GetUser {
///   final UserRepository repository; // Depende apenas do contrato
/// }
///
/// // ✅ Correto - data/repositories/user_repository_impl.dart
/// import 'package:my_app/core/contracts/user_repository.dart';
///
/// class UserRepositoryImpl implements UserRepository {
///   // Implementação técnica na camada data
/// }
/// ```
class CoreNoDataOrPresentation extends DartLintRule {
  static const _code = LintCode(
    name: 'core_no_data_or_presentation',
    problemMessage: 'Core não pode depender de Data ou Presentation.',
    correctionMessage:
        'Defina contratos no Core e implemente no Data. A UI consome apenas o Core.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// Cria uma instância da regra [CoreNoDataOrPresentation].
  const CoreNoDataOrPresentation() : super(code: _code);

  /// Executa a análise para detectar dependências indevidas do core.
  ///
  /// Percorre todas as diretivas de import no arquivo atual e, se o arquivo
  /// estiver na camada core, resolve cada import e verifica se aponta para
  /// as camadas data ou presentation. Reporta um erro se encontrar violações.
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final filePath = resolver.path;

      // Verifica se o arquivo está na camada core
      if (!isInLayer(filePath, 'core')) {
        return;
      }

      final uri = node.uri.stringValue;
      if (uri == null) return;

      // Ignora imports dart: e de pacotes que sejam do próprio core
      if (uri.startsWith('dart:') ||
          (uri.startsWith('package:') && uri.contains('/core/'))) {
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

      // Verifica se importa de data ou presentation
      if (importsFromLayer(resolved.resolvedPath, 'data') ||
          importsFromLayer(resolved.resolvedPath, 'presentation')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
