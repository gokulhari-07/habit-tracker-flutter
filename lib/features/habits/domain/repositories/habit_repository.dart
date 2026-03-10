import 'package:habit_tracker/features/habits/domain/entities/habit_completion_entity.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';

abstract class HabitRepository {
  // Habit CRUD
  Future<List<HabitEntity>> getAllHabits();
  Future<int> addHabit(String name);
  Future<void> deleteHabit(int id);
  Future<void> updateHabit(int id, String name);
  
  // Completion methods
  Future<void> toggleCompletion(int habitId, DateTime date, bool isCompleted);
  Future<List<HabitCompletionEntity>> getCompletionsForHabit(int habitId);
  Future<bool> isCompletedToday(int habitId);
  Future<HabitEntity?> getHabitById(int id);
}