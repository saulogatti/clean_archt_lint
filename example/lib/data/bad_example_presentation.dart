// EXEMPLO DE VIOLAÇÃO: data_no_presentation
// Este arquivo demonstra o erro que será reportado
// quando data tentar importar presentation.

// ignore_for_file: unused_import

// ❌ ERRO: Data não pode depender de Presentation
// import '../presentation/pages/user_page.dart';

/// Este é um exemplo comentado para não quebrar a build.
/// Descomente o import acima para ver o lint em ação.
class BadExamplePresentation {
  void someMethod() {
    // Tentativa de usar presentation no data
  }
}
