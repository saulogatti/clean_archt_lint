import '../../core/entities/user.dart';
import '../../core/usecases/get_user.dart';

/// Página de usuário.
///
/// Camada presentation - UI que depende apenas do core.
/// As implementações são injetadas via dependency injection.
class UserPage {
  final GetUser getUser;

  const UserPage({required this.getUser});

  Future<void> loadUser(String userId) async {
    final user = await getUser(userId);
    if (user != null) {
      _displayUser(user);
    }
  }

  void _displayUser(User user) {
    // Exibir usuário na UI
    print('User: ${user.name} (${user.email})');
  }
}
