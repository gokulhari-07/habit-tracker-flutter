import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/data/repositories/drift_habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftHabitRepository(db);
});