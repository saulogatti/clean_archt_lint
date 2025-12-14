/// Lint customizado para Flutter Clean Architecture.
///
/// Garante o isolamento correto entre as camadas:
/// - core: lógica de negócio pura
/// - data: implementações técnicas
/// - presentation: interface do usuário
library;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/core_no_flutter.dart';
import 'src/rules/core_no_data_or_presentation.dart';
import 'src/rules/data_no_presentation.dart';
import 'src/rules/presentation_no_data.dart';

/// Cria o plugin de lint para Clean Architecture.
PluginBase createPlugin() => _CleanArchitectureLintPlugin();

class _CleanArchitectureLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const CoreNoFlutter(),
        const CoreNoDataOrPresentation(),
        const DataNoPresentation(),
        const PresentationNoData(),
      ];
}
