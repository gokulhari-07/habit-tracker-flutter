import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/core/database/database_provider.dart';
import 'package:onward/features/habits/domain/entities/habit_completion_entity.dart';
import 'package:onward/features/habits/domain/entities/habit_entity.dart';
import 'package:onward/features/habits/domain/services/streak_service.dart';
import 'package:onward/features/habits/presentation/providers/habit_controller.dart';
import 'package:onward/features/habits/presentation/ui_models/habit_ui_model.dart';
export 'package:onward/features/habits/presentation/providers/habit_controller.dart';
// // Fetches all habits
// final habitsProvider = FutureProvider<List<HabitEntity>>((ref) async {
//   final repo = ref.watch(habitRepositoryProvider);
//   return repo.getAllHabits();
// });

// Fetches today's completion status for a specific habit
final isCompletedTodayProvider = FutureProvider.family<bool, int>((ref, habitId) async {
  ref.watch(habitsProvider);
  final repo = ref.watch(habitRepositoryProvider);
  return repo.isCompletedToday(habitId);
});

final habitByIdProvider = FutureProvider.family<HabitEntity?, int>((ref, id) async {
  
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getHabitById(id);
});

final habitCompletionsProvider = FutureProvider.family<List<HabitCompletionEntity>, int>((ref, id) async {
  ref.watch(habitsProvider);
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getCompletionsForHabit(id);
});

final habitStreakProvider = FutureProvider.family<int, int>((ref, habitId) async {
  final completions = await ref.watch(habitCompletionsProvider(habitId).future);
  final completedDates = completions
      .where((c) => c.isCompleted)
      .map((c) => c.date)
      .toList();
  return StreakService.calculateCurrentStreak(completedDates);
});

final selectedHabitProvider =
    Provider.family<HabitUiModel?, int>((ref, habitId) {
  final habitsAsync = ref.watch(habitsProvider);

  return habitsAsync.when(
    data: (habits) {
      try {
        return habits.firstWhere((h) => h.id == habitId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});