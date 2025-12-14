import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/import_resolver.dart';

/// Regra que proíbe a camada core de depender de data ou presentation.
///
/// O core deve ser a camada mais interna, sem dependências externas
/// além de outras partes do próprio core.
class CoreNoDataOrPresentation extends DartLintRule {
  const CoreNoDataOrPresentation() : super(code: _code);

  static const _code = LintCode(
    name: 'core_no_data_or_presentation',
    problemMessage: 'Core não pode depender de Data ou Presentation.',
    correctionMessage:
        'Defina contratos no Core e implemente no Data. A UI consome apenas o Core.',
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

      // Ignora imports dart: e de pacotes externos
      if (uri.startsWith('dart:') || 
          (uri.startsWith('package:') && !uri.contains('/lib/'))) {
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
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
