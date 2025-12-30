import 'lib/core/usecases/get_user.dart';
import 'lib/data/repositories/user_repository_impl.dart';
import 'lib/presentation/pages/user_page.dart';

/// clean_arch_lint usage example.
///
/// This example demonstrates the correct Clean Architecture structure:
/// - core: entities and usecases (contracts)
/// - data: implementations (repositories, models)
/// - presentation: UI (pages, widgets)
///
/// To see the lints in action, uncomment the imports in the files:
/// - lib/core/bad_example_flutter.dart
/// - lib/core/bad_example_data.dart
/// - lib/data/bad_example_presentation.dart
/// - lib/presentation/bad_example_data.dart
void main() async {
  // Dependency Injection - injects the implementation
  final GetUser getUser = UserRepositoryImpl();

  // Presentation receives only the core contract
  final userPage = UserPage(getUser: getUser);

  // Loads the user
  await userPage.loadUser('1');
}
