class HabitEntity {
  final int id;
  final String name;
  final DateTime createdAt;
  final String? cloudId;
  final DateTime updatedAt;

  const HabitEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    this.cloudId,
    required this.updatedAt,
  });
}
