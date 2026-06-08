import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:onward/features/auth/domain/entities/user_entity.dart';
import 'package:onward/features/auth/domain/repositories/auth_repository.dart';
import 'package:onward/features/habits/data/sync/sync_providers.dart';
import 'package:onward/features/habits/presentation/providers/habit_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

class AuthController extends StreamNotifier<UserEntity?> {
  @override
  Stream<UserEntity?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.authStateChanges();
  }

  Future<UserEntity?> signInWithGoogle() async {
    final repo = ref.read(authRepositoryProvider);

    final user = await repo.signInWithGoogle();

    if (user != null) {
      final syncService = ref.read(habitSyncServiceProvider);
      await syncService.syncHabitsFromCloud(uid: user.uid);
      ref.invalidate(habitsProvider);
    }

    return user;
  }

  Future<void> signOut() async {
    final user = state.valueOrNull;
    if (user != null) {
      final syncService = ref.read(habitSyncServiceProvider);
      await syncService.syncHabitsToCloud(uid: user.uid);
      await syncService.clearLocalData();
    }

    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
  }
}

final authControllerProvider =
    StreamNotifierProvider<AuthController, UserEntity?>(AuthController.new);
