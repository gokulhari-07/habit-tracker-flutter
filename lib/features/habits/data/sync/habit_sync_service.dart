import 'package:onward/features/habits/data/remote/datasources/firestore_habit_datasource.dart';
import 'package:onward/features/habits/data/remote/models/habit_cloud_model.dart';
import 'package:onward/features/habits/data/remote/models/habit_completion_cloud_model.dart';
import 'package:onward/features/habits/domain/repositories/habit_repository.dart';

class HabitSyncService {
  final HabitRepository localRepository;
  final FirestoreHabitDataSource firestoreDataSource;

  HabitSyncService({
    required this.localRepository,
    required this.firestoreDataSource,
  });

  Future<void> syncHabitsToCloud({required String uid}) async {
    final habits = await localRepository.getAllHabits();

    for (final habit in habits) {
      if (habit.cloudId == null) continue;

      await firestoreDataSource.uploadHabit(
        uid: uid,
        habit: HabitCloudModel.fromEntity(habit),
      );

      final completions =
          await localRepository.getCompletionsForHabit(habit.id);
      for (final completion in completions) {
        await firestoreDataSource.uploadCompletion(
          uid: uid,
          cloudId: habit.cloudId!,
          completion: HabitCompletionCloudModel.fromEntity(completion),
        );
      }
    }
  }

  Future<void> syncHabitsFromCloud({required String uid}) async {
    final cloudHabits = await firestoreDataSource.downloadHabits(uid: uid);

    for (final cloudHabit in cloudHabits) {
      await localRepository.insertHabit(cloudHabit.toEntity());
    }

    // Build cloudId → local int id map after all habits are inserted
    final localHabits = await localRepository.getAllHabits();
    final cloudIdToLocalId = {
      for (final h in localHabits)
        if (h.cloudId != null) h.cloudId!: h.id,
    };

    for (final cloudHabit in cloudHabits) {
      final localId = cloudIdToLocalId[cloudHabit.cloudId];
      if (localId == null) continue;

      final cloudCompletions = await firestoreDataSource.downloadCompletions(
        uid: uid,
        cloudId: cloudHabit.cloudId,
      );

      for (final completion in cloudCompletions) {
        await localRepository.toggleCompletion(
          localId,
          DateTime.parse(completion.date),
          completion.isCompleted,
        );
      }
    }
  }

  Future<void> clearLocalData() async {
    await localRepository.clearAllData();
  }
}
