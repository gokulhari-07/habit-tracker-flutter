import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/features/habits/presentation/providers/habit_providers.dart';
import 'package:onward/features/habits/presentation/ui_models/habit_ui_model.dart';

class HabitCard extends ConsumerWidget {
  final HabitUiModel habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          habit.currentStreak > 0
              ? '🔥 ${habit.currentStreak} day streak'
              : 'Start your streak today!',
        ),
        trailing: Checkbox(
          value: habit.isCompletedToday,
          onChanged: (value) async {
            final today = DateTime.now();

            await ref
                .read(habitsProvider.notifier)
                .toggleHabitCompletion(
                  habitId: habit.id,
                  date: today,
                  isCompleted: value ?? false,
                );
          },
        ),
        onTap: () async {
          await Navigator.pushNamed(context, '/habit/${habit.id}');
        },
      ),
    );
  }
}
