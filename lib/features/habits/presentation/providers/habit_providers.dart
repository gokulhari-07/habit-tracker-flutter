import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_completion_entity.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';

// Fetches all habits
final habitsProvider = FutureProvider<List<HabitEntity>>((ref) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getAllHabits();
});

// Fetches today's completion status for a specific habit
final isCompletedTodayProvider = FutureProvider.family<bool, int>((ref, habitId) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.isCompletedToday(habitId);
});

final habitByIdProvider = FutureProvider.family<HabitEntity?, int>((ref, id) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getHabitById(id);
});

final habitCompletionsProvider = FutureProvider.family<List<HabitCompletionEntity>, int>((ref, id) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getCompletionsForHabit(id);
});