import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/import_resolver.dart';

/// Regra que proíbe imports de Flutter na camada core.
///
/// A camada core deve ser totalmente independente de UI e frameworks,
/// contendo apenas lógica de negócio pura.
class CoreNoFlutter extends DartLintRule {
  const CoreNoFlutter() : super(code: _code);

  static const _code = LintCode(
    name: 'core_no_flutter',
    problemMessage: 'Core não pode depender de Flutter/UI.',
    correctionMessage: 'Mova esse código para presentation ou abstraia.',
    errorSeverity: ErrorSeverity.ERROR,
  );

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
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
