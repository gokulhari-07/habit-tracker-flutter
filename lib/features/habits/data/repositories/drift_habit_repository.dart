import 'package:drift/drift.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_completion_entity.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

class DriftHabitRepository implements HabitRepository {
  final AppDatabase _db;

  DriftHabitRepository(this._db);

  @override
  Future<List<HabitEntity>> getAllHabits() async {
    final habits = await _db.select(_db.habits).get();
    return habits
        .map(
          (habit) => HabitEntity(
            id: habit.id,
            name: habit.name,
            createdAt: habit.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<int> addHabit(String name) async {
    return await _db
        .into(_db.habits)
        .insert(HabitsCompanion.insert(name: name, createdAt: DateTime.now()));
  }

  @override
  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> updateHabit(int id, String name) async {
    await (_db.update(
      _db.habits,
    )..where((t) => t.id.equals(id))).write(HabitsCompanion(name: Value(name)));
  }

  @override
  Future<void> toggleCompletion(
    int habitId,
    DateTime date,
    bool isCompleted,
  ) async {
    // Check if a record already exists for this habit on this date
    final existing =
        await (_db.select(_db.habitCompletions)
              ..where((t) => t.habitId.equals(habitId))
              ..where((t) => t.date.equals(date)))
            .getSingleOrNull();

    if (existing == null) {
      // No record yet — insert one
      await _db
          .into(_db.habitCompletions)
          .insert(
            HabitCompletionsCompanion.insert(
              habitId: habitId,
              date: date,
              isCompleted: Value(isCompleted),
            ),
          );
    } else {
      // Record exists — update it
      await (_db.update(_db.habitCompletions)
            ..where((t) => t.id.equals(existing.id)))
          .write(HabitCompletionsCompanion(isCompleted: Value(isCompleted)));
    }
  }

  @override
  Future<List<HabitCompletionEntity>> getCompletionsForHabit(
    int habitId,
  ) async {
    final completions = await (_db.select(
      _db.habitCompletions,
    )..where((t) => t.habitId.equals(habitId))).get();

    return completions
        .map(
          (c) => HabitCompletionEntity(
            id: c.id,
            habitId: c.habitId,
            date: c.date,
            isCompleted: c.isCompleted,
          ),
        )
        .toList();
  }

  @override
  Future<bool> isCompletedToday(int habitId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final existing =
        await (_db.select(_db.habitCompletions)
              ..where((t) => t.habitId.equals(habitId))
              ..where((t) => t.date.equals(todayDate)))
            .getSingleOrNull();

    return existing?.isCompleted ?? false;
  }

  @override
  Future<HabitEntity?> getHabitById(int id) async {
    final row = await (_db.select(
      _db.habits,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (row == null) return null;

    return HabitEntity(id: row.id, name: row.name, createdAt: row.createdAt);
  }
}
