import '../../core/entities/user.dart';
import '../../core/usecases/get_user.dart';
import '../models/user_model.dart';

/// Implementação do repositório de usuário.
///
/// Camada data - implementa o contrato definido no core.
class UserRepositoryImpl implements GetUser {
  @override
  Future<User?> call(String userId) async {
    // Simulação de busca no banco de dados ou API
    await Future.delayed(const Duration(milliseconds: 100));
    
    return const UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
    );
  }
}
