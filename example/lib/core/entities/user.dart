/// Entidade de usuário.
///
/// Camada core - pura lógica de negócio.
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}
