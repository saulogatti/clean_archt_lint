import '../../core/entities/user.dart';
import '../../core/usecases/get_user.dart';

/// User page.
///
/// Presentation layer - UI that depends only on core.
/// Implementations are injected via dependency injection.
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
    // Display user in UI
    print('User: ${user.name} (${user.email})');
  }
}
