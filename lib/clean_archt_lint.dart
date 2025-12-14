/// Plugin de lint customizado para enforçar regras de Flutter Clean Architecture.
///
/// Este plugin garante o isolamento correto entre as camadas através de
/// análise estática (AST), impedindo dependências indevidas entre:
/// 
/// - **core**: lógica de negócio pura, sem dependências de UI ou infraestrutura
/// - **data**: implementações técnicas e infraestrutura (APIs, banco de dados)
/// - **presentation**: interface do usuário e componentes visuais
///
/// ## Regras implementadas
///
/// - [CoreNoFlutter]: Impede que a camada core importe Flutter/UI
/// - [CoreNoDataOrPresentation]: Impede que core dependa de data ou presentation
/// - [DataNoPresentation]: Impede que data dependa de presentation
/// - [PresentationNoData]: Alerta quando presentation depende diretamente de data
///
/// ## Exemplo de uso
///
/// Adicione ao `analysis_options.yaml`:
/// 
/// ```yaml
/// analyzer:
///   plugins:
///     - custom_lint
/// 
/// custom_lint:
///   rules:
///     - core_no_flutter
///     - core_no_data_or_presentation
///     - data_no_presentation
///     - presentation_no_data
/// ```
library;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/core_no_flutter.dart';
import 'src/rules/core_no_data_or_presentation.dart';
import 'src/rules/data_no_presentation.dart';
import 'src/rules/presentation_no_data.dart';

/// Cria e retorna a instância do plugin de lint para Clean Architecture.
///
/// Esta função é chamada automaticamente pelo framework `custom_lint_builder`
/// durante a inicialização do analisador. Não deve ser chamada manualmente.
///
/// Retorna um [PluginBase] que registra todas as regras de lint implementadas.
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
