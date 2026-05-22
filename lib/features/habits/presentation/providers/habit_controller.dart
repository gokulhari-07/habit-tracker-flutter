import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/core/database/database_provider.dart';
import 'package:onward/features/habits/domain/entities/habit_completion_entity.dart';
import 'package:onward/features/habits/domain/services/streak_service.dart';
import 'package:onward/features/habits/presentation/ui_models/habit_ui_model.dart';

class HabitController extends AsyncNotifier<List<HabitUiModel>> {
  @override
  Future<List<HabitUiModel>> build() async {
    final repo = ref.watch(habitRepositoryProvider);

    final habits = await repo.getAllHabits();

    final List<HabitUiModel> uiModels = [];

    for (final habit in habits) {
      final completions = await repo.getCompletionsForHabit(habit.id);

      final completedDates = completions
          .where((c) => c.isCompleted)
          .map((c) => c.date)
          .toList();

      final streak = StreakService.calculateCurrentStreak(completedDates);

      final isCompletedToday = await repo.isCompletedToday(habit.id);

      uiModels.add(
        HabitUiModel(
          id: habit.id,
          name: habit.name,
          createdAt: habit.createdAt,
          isCompletedToday: isCompletedToday,
          currentStreak: streak,
        ),
      );
    }

    return uiModels;
  }

  Future<void> toggleHabitCompletion({
    required int habitId,
    required DateTime date,
    required bool isCompleted,
  }) async {
    final repo = ref.read(habitRepositoryProvider);

    await repo.toggleCompletion(habitId, date, isCompleted);

    final updatedHabits = await build();
    state = AsyncData(updatedHabits);
  }
}

final habitsProvider =
    AsyncNotifierProvider<HabitController, List<HabitUiModel>>(
      HabitController.new,
    );
