import 'package:onward/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  Future<UserEntity?> signInWithGoogle();

  Future<void> signOut();
}