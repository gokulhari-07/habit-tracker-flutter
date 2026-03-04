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
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider); //to test whether db opens successfully
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
