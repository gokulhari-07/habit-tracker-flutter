import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:onward/features/habits/data/tables/habit_table.dart';
import 'package:onward/features/habits/data/tables/habit_completion_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits, HabitCompletions])  // ← Updated
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'habit_tracker.db'));
    return NativeDatabase(file);
  });
}