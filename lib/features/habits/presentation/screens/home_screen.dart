import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
