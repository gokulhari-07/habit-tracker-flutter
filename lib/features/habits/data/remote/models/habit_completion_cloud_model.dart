import 'package:onward/features/habits/domain/entities/habit_completion_entity.dart';

class HabitCompletionCloudModel {
  final String date; // "yyyy-MM-dd" — also the Firestore doc ID
  final bool isCompleted;

  const HabitCompletionCloudModel({
    required this.date,
    required this.isCompleted,
  });

  factory HabitCompletionCloudModel.fromEntity(HabitCompletionEntity c) {
    return HabitCompletionCloudModel(
      date: _isoDate(c.date),
      isCompleted: c.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'isCompleted': isCompleted};

  factory HabitCompletionCloudModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionCloudModel(
      date: json['date'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
