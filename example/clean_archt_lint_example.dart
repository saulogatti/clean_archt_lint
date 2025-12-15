import 'lib/core/usecases/get_user.dart';
import 'lib/data/repositories/user_repository_impl.dart';
import 'lib/presentation/pages/user_page.dart';

/// Exemplo de uso do clean_arch_lint.
///
/// Este exemplo demonstra a estrutura correta de Clean Architecture:
/// - core: entidades e usecases (contratos)
/// - data: implementações (repositories, models)
/// - presentation: UI (pages, widgets)
///
/// Para ver os lints em ação, descomente os imports nos arquivos:
/// - lib/core/bad_example_flutter.dart
/// - lib/core/bad_example_data.dart
/// - lib/data/bad_example_presentation.dart
/// - lib/presentation/bad_example_data.dart
void main() async {
  // Dependency Injection - injeta a implementação
  final GetUser getUser = UserRepositoryImpl();

  // Presentation recebe apenas o contrato do core
  final userPage = UserPage(getUser: getUser);

  // Carrega o usuário
  await userPage.loadUser('1');

  print('\n✅ Arquitetura limpa implementada corretamente!');
  print('📦 Core: define contratos');
  print('🔧 Data: implementa contratos');
  print('🎨 Presentation: consome contratos via DI');
}
