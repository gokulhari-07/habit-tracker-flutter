import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/database/database_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  
  @override
void initState() {
  super.initState();
  _testDatabase();
}

  
  Future<void> _testDatabase() async {
  final db = ref.read(databaseProvider);

  // Insert a test habit
  final id = await db.into(db.habits).insert(
    HabitsCompanion.insert(
      name: 'Test Habit',
      createdAt: DateTime.now(),
    ),
  );
  print('Inserted habit with id: $id');

  // Fetch all habits
  final habits = await db.select(db.habits).get();
  print('All habits: $habits');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HomeScreen")),
      body: Column(
        children: [
          Text("Home Screen"),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Go to Settings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
            child: const Text('Go to add '),
          ),
          
        ],
      ),
    );
  }
}
