// EXEMPLO DE VIOLAÇÃO: presentation_no_data
// Este arquivo demonstra o WARNING que será reportado
// quando presentation tentar importar data diretamente.

// ignore_for_file: unused_import

// ⚠️ WARNING: Presentation não deve depender diretamente de Data
// import '../data/repositories/user_repository_impl.dart';

/// Este é um exemplo comentado para não quebrar a build.
/// Descomente o import acima para ver o lint em ação.
///
/// A solução correta é:
/// 1. Depender apenas do contrato do core (GetUser)
/// 2. Injetar a implementação (UserRepositoryImpl) via DI
class BadExampleData {
  void someMethod() {
    // Tentativa de usar data diretamente no presentation
  }
}
