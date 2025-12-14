import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';

/// Regra que proíbe a camada data de depender de presentation.
///
/// A camada data contém implementações técnicas e infraestrutura,
/// que não devem ter conhecimento sobre a UI.
class DataNoPresentation extends DartLintRule {
  static const _code = LintCode(
    name: 'data_no_presentation',
    problemMessage: 'Data não pode depender de Presentation.',
    correctionMessage: 'Mova contratos para Core e injete dependências.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  const DataNoPresentation() : super(code: _code);

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
