import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';

abstract class HabitRepository {
  Future<List<HabitEntity>> getAllHabits();
  Future<int> addHabit(String name);
  Future<void> deleteHabit(int id);
  Future<void> updateHabit(int id, String name);
}