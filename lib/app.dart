import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/habits/presentation/screens/add_edit_habit_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/home_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/settings_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: { //for v1, we use named routes. Later in v2, we will use goRouter or Navigator 2.0
        '/': (_) => const HomeScreen(),
        '/add': (_) => const AddHabitScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
