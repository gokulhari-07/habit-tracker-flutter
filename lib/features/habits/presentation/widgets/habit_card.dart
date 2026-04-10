import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/core/database/database_provider.dart';
import 'package:onward/features/habits/domain/entities/habit_entity.dart';
import 'package:onward/features/habits/presentation/providers/habit_providers.dart';

class HabitCard extends ConsumerWidget {
  final HabitEntity habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompletedAsync = ref.watch(isCompletedTodayProvider(habit.id));
    final streakAsync = ref.watch(habitStreakProvider(habit.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: streakAsync.when(
          loading: () => const Text(''),
          error: (_, __) => const Text(''),
          data: (streak) => Text(
            streak > 0 ? '🔥 $streak day streak' : 'Start your streak today!',
          ),
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
          ref.invalidate(habitCompletionsProvider(habit.id));
        },
      ),
    );
  }
}