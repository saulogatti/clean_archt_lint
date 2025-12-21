import '../entities/user.dart';

/// Contract to fetch user.
///
/// Core layer - defines the contract that will be implemented in data.
abstract class GetUser {
  Future<User?> call(String userId);
}
