import 'package:drift/drift.dart';
import 'package:onward/features/habits/data/tables/habit_table.dart';

class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}