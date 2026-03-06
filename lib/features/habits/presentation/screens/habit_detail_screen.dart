import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final int habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Habit Detail')),
      body: Center(child: Text('Habit ID: $habitId')),
    );
  }
}