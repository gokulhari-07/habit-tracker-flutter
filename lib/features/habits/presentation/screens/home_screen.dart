import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_service.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No habits yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first habit',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              return HabitCard(habit: habits[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          ref.invalidate(habitsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
              ref.invalidate(habitsProvider);
            },
          ),
        ),
        onTap: () => Navigator.pushNamed(context, '/habit/${habit.id}'),
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