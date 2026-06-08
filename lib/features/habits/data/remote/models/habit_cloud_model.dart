import 'package:onward/features/habits/domain/entities/habit_entity.dart';

class HabitCloudModel {
  final String cloudId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitCloudModel({
    required this.cloudId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitCloudModel.fromEntity(HabitEntity habit) {
    return HabitCloudModel(
      cloudId: habit.cloudId!,
      name: habit.name,
      createdAt: habit.createdAt,
      updatedAt: habit.updatedAt,
    );
  }

  HabitEntity toEntity() {
    return HabitEntity(
      id: 0, // local int id not synced; Drift autoassigns on insert
      name: name,
      createdAt: createdAt,
      cloudId: cloudId,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cloudId': cloudId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HabitCloudModel.fromJson(Map<String, dynamic> json) {
    return HabitCloudModel(
      cloudId: json['cloudId'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
