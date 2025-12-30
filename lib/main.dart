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

import 'dart:async';

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:clean_arch_lint/src/rules/always_use_package_imports.dart';

import 'src/rules/presentation_no_data.dart' show PresentationNoData;

export 'src/rules/always_use_package_imports.dart' show AlwaysUsePackageImports;
// export 'src/rules/core_no_data_or_presentation.dart' show CoreNoDataOrPresentation;
// export 'src/rules/core_no_flutter.dart' show CoreNoFlutter;
// export 'src/rules/data_no_presentation.dart' show DataNoPresentation;
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
final plugin = CleanArchitectureLintPlugin();

class CleanArchitectureLintPlugin extends Plugin {
  // @override
  // List<LintRule> getLintRules(CustomLintConfigs configs) => [
  //       const CoreNoFlutter(),
  //       const CoreNoDataOrPresentation(),
  //       const DataNoPresentation(),
  //       const PresentationNoData(),
  //     ];

  @override
  String get name => "Flutter Clean Architecture Lint Plugin";

  @override
  FutureOr<void> register(PluginRegistry registry) {
    registry.registerLintRule(PresentationNoData());
    registry.registerLintRule(AlwaysUsePackageImports());
    registry.registerWarningRule(AlwaysUsePackageImports());
    registry.registerWarningRule(PresentationNoData());
  }
}
