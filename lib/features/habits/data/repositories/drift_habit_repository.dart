import 'package:drift/drift.dart';
import 'package:onward/core/database/app_database.dart';
import 'package:onward/features/habits/domain/entities/habit_completion_entity.dart';
import 'package:onward/features/habits/domain/entities/habit_entity.dart';
import 'package:onward/features/habits/domain/repositories/habit_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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
            cloudId: habit.cloudId,
            updatedAt: habit.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<int> addHabit(String name) async {
    final now = DateTime.now();
    return await _db.into(_db.habits).insert(
          HabitsCompanion.insert(
            name: name,
            createdAt: now,
            cloudId: Value(_uuid.v4()),
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> updateHabit(int id, String name) async {
    await (_db.update(_db.habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> toggleCompletion(
    int habitId,
    DateTime date,
    bool isCompleted,
  ) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final existing =
        await (_db.select(_db.habitCompletions)
              ..where((t) => t.habitId.equals(habitId))
              ..where((t) => t.date.equals(normalizedDate)))
            .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.habitCompletions).insert(
            HabitCompletionsCompanion.insert(
              habitId: habitId,
              date: normalizedDate,
              isCompleted: Value(isCompleted),
            ),
          );
    } else {
      await (_db.update(_db.habitCompletions)
            ..where((t) => t.id.equals(existing.id)))
          .write(HabitCompletionsCompanion(isCompleted: Value(isCompleted)));
    }
  }

  @override
  Future<List<HabitCompletionEntity>> getCompletionsForHabit(
    int habitId,
  ) async {
    final completions = await (_db.select(_db.habitCompletions)
          ..where((t) => t.habitId.equals(habitId)))
        .get();

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
    final row = await (_db.select(_db.habits)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (row == null) return null;

    return HabitEntity(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      cloudId: row.cloudId,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> insertHabit(HabitEntity habit) async {
    // Look up by cloudId to avoid duplicates when restoring from cloud.
    // If a local row exists, update it only if the cloud version is newer.
    if (habit.cloudId != null) {
      final existing = await (_db.select(_db.habits)
            ..where((t) => t.cloudId.equals(habit.cloudId!)))
          .getSingleOrNull();

      if (existing != null) {
        if (habit.updatedAt.isAfter(existing.updatedAt)) {
          await (_db.update(_db.habits)
                ..where((t) => t.id.equals(existing.id)))
              .write(HabitsCompanion(
                name: Value(habit.name),
                updatedAt: Value(habit.updatedAt),
              ));
        }
        return;
      }
    }

    // No existing local row — insert and let Drift autoassign the int id.
    await _db.into(_db.habits).insert(
          HabitsCompanion.insert(
            name: habit.name,
            createdAt: habit.createdAt,
            cloudId: Value(habit.cloudId),
            updatedAt: habit.updatedAt,
          ),
        );
  }

  @override
  Future<void> clearAllData() async {
    await _db.delete(_db.habitCompletions).go();
    await _db.delete(_db.habits).go();
  }
}
