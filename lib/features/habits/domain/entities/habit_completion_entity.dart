class HabitCompletionEntity {
  final int id;
  final int habitId;
  final DateTime date;
  final bool isCompleted;

  const HabitCompletionEntity({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
  });
}