import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/habits/presentation/screens/add_edit_habit_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_detail_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/home_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/settings_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        //for v1, we use named routes. Later in v2, we will use goRouter or Navigator 2.0
        '/': (_) => const HomeScreen(),
        '/add': (_) => const AddEditHabitScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/habit/') == true) {
          final id = int.parse(settings.name!.split('/').last);
          return MaterialPageRoute(
            builder: (_) => HabitDetailScreen(habitId: id),
          );
        }
        if (settings.name == "/edit") {
          final habit = settings.arguments as HabitEntity;
          return MaterialPageRoute(
            builder: (_) => AddEditHabitScreen(habit: habit),
          );
        }
        return null;
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
