import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/import_resolver.dart';

/// Regra que desencoraja a camada presentation de depender de data.
///
/// A presentation deve depender apenas do core (usecases e contratos).
/// As implementações devem ser injetadas via dependency injection.
///
/// Por padrão é WARNING, mas pode ser configurado para ERROR.
class PresentationNoData extends DartLintRule {
  const PresentationNoData() : super(code: _code);

  static const _code = LintCode(
    name: 'presentation_no_data',
    problemMessage: 'Presentation não deve depender diretamente de Data.',
    correctionMessage:
        'Dependa apenas do Core (usecases/contratos) e injete implementações.',
    errorSeverity: ErrorSeverity.WARNING,
  );

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
          (uri.startsWith('package:') && !uri.contains('/lib/'))) {
        return;
      }

      // Tenta resolver o import
      final projectRoot = resolver.source.uri.toFilePath();
      final segments = projectRoot.split('/');
      final libIndex = segments.lastIndexOf('lib');
      final rootPath = libIndex >= 0 
          ? segments.sublist(0, libIndex).join('/')
          : segments.sublist(0, segments.length - 1).join('/');

      // Extrai o nome do pacote do URI ou assume baseado no path
      String? packageName;
      if (uri.startsWith('package:')) {
        packageName = uri.split('/').first.substring('package:'.length);
      }

      final resolved = resolveImport(
        node,
        filePath,
        packageName,
        rootPath,
      );

      if (resolved == null) return;

      // Verifica se importa de data
      if (importsFromLayer(resolved.resolvedPath, 'data')) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
