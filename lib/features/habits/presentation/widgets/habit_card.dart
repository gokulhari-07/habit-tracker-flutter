import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart' show HabitEntity;
import 'package:habit_tracker/features/habits/domain/services/streak_service.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';

class HabitCard extends ConsumerWidget {
  final HabitEntity habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompletedAsync = ref.watch(isCompletedTodayProvider(habit.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: FutureBuilder<int>(
          future: _getStreak(ref, habit.id),
          builder: (context, snapshot) {
            final streak = snapshot.data ?? 0;
            return Text(
              streak > 0 ? '🔥 $streak day streak' : 'Start your streak today!',
            );
          },
        ),
        trailing: isCompletedAsync.when(
          loading: () => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (_, __) => const Icon(Icons.error),
          data: (isCompleted) => Checkbox(
            value: isCompleted,
            onChanged: (value) async {
              final repo = ref.read(habitRepositoryProvider);
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              await repo.toggleCompletion(habit.id, todayDate, value ?? false);
              ref.invalidate(isCompletedTodayProvider(habit.id));
              ref.invalidate(habitCompletionsProvider(habit.id));
              ref.invalidate(habitsProvider);
            },
          ),
        ),
        onTap: () async {
          await Navigator.pushNamed(context, '/habit/${habit.id}');
          ref.invalidate(habitsProvider);
        },
      ),
    );
  }

  Future<int> _getStreak(WidgetRef ref, int habitId) async {
    final repo = ref.read(habitRepositoryProvider);
    final completions = await repo.getCompletionsForHabit(habitId);
    final completedDates = completions
        .where((c) => c.isCompleted)
        .map((c) => c.date)
        .toList();
    return StreakService.calculateCurrentStreak(completedDates);
  }
}