import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Regra de lint que proíbe imports de Flutter na camada core.
///
/// A camada core deve ser totalmente independente de UI e frameworks,
/// contendo apenas lógica de negócio pura. Esta regra garante que nenhum
/// código da camada core importe bibliotecas Flutter ou relacionadas a UI.
///
/// ## Severidade
///
/// ERROR - Viola o princípio fundamental da Clean Architecture
///
/// ## Imports bloqueados
///
/// - `package:flutter/...` (todos os imports do Flutter)
/// - `package:flutter_test/...` (biblioteca de testes do Flutter)
/// - `dart:ui` (biblioteca de UI do Dart usada pelo Flutter)
///
/// ## Exemplo de violação
///
/// ```dart
/// // ❌ Errado - core/usecases/get_user.dart
/// import 'package:flutter/material.dart';
///
/// class GetUser {
///   Widget buildWidget() => Container(); // Não deve ter UI no core
/// }
/// ```
///
/// ## Solução
///
/// ```dart
/// // ✅ Correto - core/usecases/get_user.dart
/// class GetUser {
///   User call(String id) {
///     // Apenas lógica de negócio pura
///   }
/// }
///
/// // ✅ Correto - presentation/widgets/user_widget.dart
/// import 'package:flutter/material.dart';
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserWidget extends StatelessWidget {
///   // UI na camada correta
/// }
/// ```
class CoreNoFlutter extends DartLintRule {
  static const _code = LintCode(
    name: 'core_no_flutter',
    problemMessage: 'Core não pode depender de Flutter/UI.',
    correctionMessage: 'Mova esse código para presentation ou abstraia.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// Cria uma instância da regra [CoreNoFlutter].
  const CoreNoFlutter() : super(code: _code);

  /// Executa a análise para detectar imports de Flutter na camada core.
  ///
  /// Percorre todas as diretivas de import no arquivo atual e, se o arquivo
  /// estiver na camada core, verifica se há imports de Flutter. Reporta um
  /// erro se encontrar violações.
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

      // Verifica se é um import de Flutter
      if (isFlutterImport(uri)) {
         reporter.atNode(node, _code);
      }
    });
  }
}
