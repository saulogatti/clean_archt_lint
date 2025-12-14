// EXEMPLO DE VIOLAÇÃO: core_no_data_or_presentation
// Este arquivo demonstra o erro que será reportado
// quando o core tentar importar data ou presentation.

// ignore_for_file: unused_import

// ❌ ERRO: Core não pode depender de Data ou Presentation
// import '../data/models/user_model.dart';
// import '../presentation/pages/user_page.dart';

/// Este é um exemplo comentado para não quebrar a build.
/// Descomente os imports acima para ver o lint em ação.
class BadExampleData {
  void someMethod() {
    // Tentativa de usar data ou presentation no core
  }
}
