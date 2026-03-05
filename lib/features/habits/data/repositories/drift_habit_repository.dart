import 'package:drift/drift.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

class DriftHabitRepository implements HabitRepository {
  final AppDatabase _db;

  DriftHabitRepository(this._db);

  @override
  Future<List<HabitEntity>> getAllHabits() async {
    final habits = await _db.select(_db.habits).get();
    return habits.map((habit) => HabitEntity(
      id: habit.id,
      name: habit.name,
      createdAt: habit.createdAt,
    )).toList();
  }

  @override
  Future<int> addHabit(String name) async {
    return await _db.into(_db.habits).insert(
      HabitsCompanion.insert(
        name: name,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habits)
      ..where((t) => t.id.equals(id)))
      .go();
  }

  @override
  Future<void> updateHabit(int id, String name) async {
    await (_db.update(_db.habits)
      ..where((t) => t.id.equals(id)))
      .write(HabitsCompanion(name: Value(name)));
  }
}