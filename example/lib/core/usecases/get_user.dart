import '../entities/user.dart';

/// Contrato para buscar usuário.
///
/// Camada core - define o contrato que será implementado no data.
abstract class GetUser {
  Future<User?> call(String userId);
}
