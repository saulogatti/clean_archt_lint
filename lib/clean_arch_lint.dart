/// Custom lint plugin for enforcing Flutter Clean Architecture rules.
///
/// This plugin ensures proper isolation between layers through
/// static analysis (AST), preventing unwanted dependencies between:
///
/// - **core**: pure business logic, without UI or infrastructure dependencies
/// - **data**: technical implementations and infrastructure (APIs, database)
/// - **presentation**: user interface and visual components
///
/// ## Implemented rules
///
/// - [CoreNoFlutter]: Prevents core layer from importing Flutter/UI
/// - [CoreNoDataOrPresentation]: Prevents core from depending on data or presentation
/// - [DataNoPresentation]: Prevents data from depending on presentation
/// - [PresentationNoData]: Warns when presentation directly depends on data
///
/// ## Usage example
///
/// Add to `analysis_options.yaml`:
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
///
/// To customize a rule's severity:
///
/// ```yaml
/// analyzer:
///   errors:
///     presentation_no_data: error  # Transforms WARNING into ERROR
/// ```
library;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/core_no_data_or_presentation.dart'
    show CoreNoDataOrPresentation;
import 'src/rules/core_no_flutter.dart' show CoreNoFlutter;
import 'src/rules/data_no_presentation.dart' show DataNoPresentation;
import 'src/rules/presentation_no_data.dart' show PresentationNoData;

export 'src/rules/core_no_data_or_presentation.dart'
    show CoreNoDataOrPresentation;
export 'src/rules/core_no_flutter.dart' show CoreNoFlutter;
export 'src/rules/data_no_presentation.dart' show DataNoPresentation;
export 'src/rules/presentation_no_data.dart' show PresentationNoData;

/// Creates and returns the lint plugin instance for Clean Architecture.
///
/// This function is automatically called by the `custom_lint_builder`
/// framework during analyzer initialization. Should not be called manually.
///
/// Returns a [PluginBase] that registers all implemented lint rules.
/// /// ## Implemented rules
///
/// - [CoreNoFlutter]: Prevents core layer from importing Flutter/UI
/// - [CoreNoDataOrPresentation]: Prevents core from depending on data or presentation
/// - [DataNoPresentation]: Prevents data from depending on presentation
/// - [PresentationNoData]: Warns when presentation directly depends on data
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
