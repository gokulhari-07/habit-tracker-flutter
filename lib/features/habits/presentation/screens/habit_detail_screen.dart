import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_service.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/core/database/database_provider.dart';

class HabitDetailScreen extends ConsumerWidget {
  final int habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    return habitAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (habit) {
        if (habit == null) {
          return const Scaffold(
            body: Center(child: Text('Habit not found')),
          );
        }
        return _HabitDetailView(habit: habit);
      },
    );
  }
}

// ── Main Detail View ───────────────────────────────────────────
class _HabitDetailView extends ConsumerWidget {
  final HabitEntity habit;
  const _HabitDetailView({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionsAsync = ref.watch(habitCompletionsProvider(habit.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/edit',
                arguments: habit,
              );
              ref.invalidate(habitByIdProvider(habit.id));
              ref.invalidate(habitCompletionsProvider(habit.id));
            },
          ),
        ],
      ),
      body: completionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (completions) {
          final completedDates = completions
              .where((c) => c.isCompleted)
              .map((c) => c.date)
              .toList();

          final currentStreak =
              StreakService.calculateCurrentStreak(completedDates);
          final longestStreak =
              StreakService.calculateLongestStreak(completedDates);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatsRow(
                currentStreak: currentStreak,
                longestStreak: longestStreak,
              ),
              const SizedBox(height: 24),
              _CalendarSection(
                habit: habit,
                completions: completions,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  const _StatsRow({required this.currentStreak, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Current Streak',
            value: '$currentStreak',
            unit: 'days',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Longest Streak',
            value: '$longestStreak',
            unit: 'days',
            icon: Icons.emoji_events_outlined,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calendar Section ───────────────────────────────────────────
class _CalendarSection extends ConsumerWidget {
  final HabitEntity habit;
  final List completions;

  const _CalendarSection({
    required this.habit,
    required this.completions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final completedDates = completions
        .where((c) => c.isCompleted)
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _monthName(now.month),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        d,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: daysInMonth + (firstDay.weekday - 1),
          itemBuilder: (context, index) {
            final offset = firstDay.weekday - 1;
            if (index < offset) return const SizedBox.shrink();

            final day = index - offset + 1;
            final date = DateTime(now.year, now.month, day);
            final isCompleted = completedDates.contains(date);
            final isToday = day == now.day;
            final isFuture = date.isAfter(now);

            return _DayCell(
              day: day,
              isCompleted: isCompleted,
              isToday: isToday,
              isFuture: isFuture,
              onTap: isFuture
                  ? null
                  : () async {
                      final repo = ref.read(habitRepositoryProvider);
                      await repo.toggleCompletion(
                        habit.id,
                        date,
                        !isCompleted,
                      );
                      ref.invalidate(habitCompletionsProvider(habit.id));
                      ref.invalidate(isCompletedTodayProvider(habit.id));
                      ref.invalidate(habitsProvider);
                    },
            );
          },
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// ── Day Cell ───────────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;

    if (isCompleted) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else if (isFuture) {
      backgroundColor = Colors.transparent;
      textColor = colorScheme.onSurface.withOpacity(0.3);
    } else {
      backgroundColor = colorScheme.surfaceVariant;
      textColor = colorScheme.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}