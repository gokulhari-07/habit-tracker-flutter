import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Theme Section ──────────────────────────────
          const SectionHeader(title: 'Appearance'),
          _AppearanceSection(),
          const Divider(),

          // ── V2 Placeholder Section ─────────────────────
          const SectionHeader(title: 'Coming Soon'),
          _ComingSoonSection(),
          const Divider(),

          // ── App Info Section ───────────────────────────
          const SectionHeader(title: 'About'),
          _AboutSection(),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          trailing: Text('1.0.0'),
        ),
      ],
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: const Text('Cloud Sync'),
          subtitle: const Text('Back up your habits across devices'),
          trailing: const Chip(label: Text('V2')),
          onTap: null,
        ),
        ListTile(
          leading: const Icon(Icons.psychology_outlined),
          title: const Text('AI Coach'),
          subtitle: const Text('Personalized habit insights and predictions'),
          trailing: const Chip(label: Text('V2')),
          onTap: null,
        ),
      ],
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          subtitle: const Text('Follows your device theme'),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).state = value!;
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).state = value!;
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          value: ThemeMode.dark, // this tile's value
          groupValue: themeMode, // currently selected value
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).state = value!;
          },
        ),
      ],
    );
  }
}

// ## Key Concepts in This Screen

// ### `StateProvider` vs `Provider`
// Provider         → value never changes (AppDatabase, HabitRepository)
// FutureProvider   → async value, read-only (habits list, isCompletedToday)
// StateProvider    → simple value that CAN be changed by the UI (ThemeMode)
