import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:onward/features/auth/domain/entities/user_entity.dart';
import 'package:onward/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

class AuthController extends StreamNotifier<UserEntity?> {
  @override
  Stream<UserEntity?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.authStateChanges();
  }

  Future<void> signInWithGoogle() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signInWithGoogle();
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
  }
}

final authControllerProvider =
    StreamNotifierProvider<AuthController, UserEntity?>(
  AuthController.new,
);