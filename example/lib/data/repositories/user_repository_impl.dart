import '../../core/entities/user.dart';
import '../../core/usecases/get_user.dart';
import '../models/user_model.dart';

/// User repository implementation.
///
/// Data layer - implements the contract defined in core.
class UserRepositoryImpl implements GetUser {
  @override
  Future<User?> call(String userId) async {
    // Simulating database or API fetch
    await Future.delayed(const Duration(milliseconds: 100));
    
    return const UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
    );
  }
}
