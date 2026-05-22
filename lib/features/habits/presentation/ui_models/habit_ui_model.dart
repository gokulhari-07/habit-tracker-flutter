class HabitUiModel {
  final int id;
  final String name;
  final DateTime createdAt;

  final bool isCompletedToday;
  final int currentStreak;

  const HabitUiModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isCompletedToday,
    required this.currentStreak,
  });
}