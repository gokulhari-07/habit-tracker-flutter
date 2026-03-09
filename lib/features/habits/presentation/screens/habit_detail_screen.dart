import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final int habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Detail'),
        actions: [
          IconButton(
            onPressed: () {
              // Will be properly wired in Day 8-9
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(child: Text('Habit ID: $habitId')),
    );
  }
}
