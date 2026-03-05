import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  _testRepository();
}

Future<void> _testRepository() async {
  final repo = ref.read(habitRepositoryProvider);

  // Add a habit through repository
  final id = await repo.addHabit('Morning Walk');
  debugPrint('Added habit with id: $id');

  // Fetch all habits through repository
  final habits = await repo.getAllHabits();
  print('All habits: $habits');
  print('First habit name: ${habits.first.name}');
  print('First habit type: ${habits.first.runtimeType}');
}
// Run the app. In the console you should see:
// ```
// Added habit with id: 1
// All habits: [Instance of 'HabitEntity']
// First habit name: Morning Walk
// First habit type: HabitEntity
// ```

// The critical thing to verify is `runtimeType: HabitEntity` — **not** `Habit`. This proves the data layer is correctly mapping Drift objects to domain entities before handing them to the UI.

// ---
  
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
