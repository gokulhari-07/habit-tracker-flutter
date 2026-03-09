# Day 7 – Settings Screen & Dynamic Theme Switching

## What Was Done Today
- Created `theme_provider.dart` — `StateProvider<ThemeMode>` for dynamic theme
- Updated `MyApp` in `app.dart` from `StatelessWidget` to `ConsumerWidget` to watch theme
- Built fully functional `SettingsScreen` with three isolated private sections
- Theme switches instantly across entire app when radio button is selected
- Added V2 placeholder sections for Cloud Sync and AI Coach

---

## File Structure Changes

```
lib/
├── core/
│   └── providers/
│       └── theme_provider.dart              ← NEW
└── features/
    └── habits/
        └── presentation/
            └── screens/
                └── settings_screen.dart     ← FULLY REBUILT

lib/app.dart                                 ← UPDATED (ConsumerWidget, watches theme)
```

---

## CONCEPT 1 — `StateProvider` — When to Use It

You have seen three Riverpod provider types now. Here is when to use each:

| Provider Type | Use When | Example |
|--------------|----------|---------|
| `Provider` | Value never changes | `AppDatabase`, `HabitRepository` |
| `FutureProvider` | Async data, read-only | habits list, isCompletedToday |
| `StateProvider` | Simple value the UI can change | `ThemeMode` |

`StateProvider` is for simple mutable state — a single value that the UI can both read and update. No async work, no complex logic.

```dart
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system; // default value
});
```

---

## CONCEPT 2 — Reading vs Updating `StateProvider`

**Reading** — same as any other provider:

```dart
final themeMode = ref.watch(themeModeProvider);
```

**Updating** — use `.notifier`:

```dart
ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
```

`.notifier` — gives access to the state controller of the provider.
`.state = ...` — sets the new value. Every widget watching this provider rebuilds automatically.

Why `ref.read` and not `ref.watch` when updating?

You use `ref.read` inside `onChanged` — an event handler, not the `build` method. You just need to write a value once. You don't need to subscribe to changes here. Rule: **`ref.watch` to read reactively. `ref.read` to write or read once.**

---

## CONCEPT 3 — How Theme Change Propagates Instantly

```
User taps Dark radio button
        ↓
onChanged fires
        ↓
ref.read(themeModeProvider.notifier).state = ThemeMode.dark
        ↓
themeModeProvider value changes
        ↓
MyApp watches themeModeProvider → rebuilds
        ↓
MaterialApp receives themeMode: ThemeMode.dark
        ↓
Entire app switches to dark theme instantly
```

No page reload. No restart. Riverpod's reactivity propagates the change from inside `_AppearanceSection` all the way up to `MyApp` in one synchronous update. This is the power of having `MyApp` watch the provider.

---

## CONCEPT 4 — Why `MyApp` Changed from `StatelessWidget` to `ConsumerWidget`

Before Day 7:

```dart
class MyApp extends StatelessWidget {
  // themeMode hardcoded
  themeMode: ThemeMode.system,
}
```

After Day 7:

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      themeMode: themeMode, // dynamic — from provider
      ...
    );
  }
}
```

`MyApp` needs to watch `themeModeProvider` so it can pass the current value to `MaterialApp.themeMode`. When the provider changes, `MyApp` rebuilds, `MaterialApp` receives the new `themeMode`, and Flutter switches the entire app's theme.

---

## CONCEPT 5 — Screen Architecture — Pushing Provider Dependencies Down

This is the most important architectural concept of Day 7.

### Wrong Approach — Provider Watched Too High

```dart
class SettingsScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider); // watched at screen level
    return Scaffold(
      body: ListView(children: [
        // ALL of these rebuild when themeMode changes
        _SectionHeader(...),
        RadioListTile(...),
        RadioListTile(...),
        RadioListTile(...),
        _SectionHeader(...),
        ListTile(...),       // doesn't need themeMode — still rebuilds
        ListTile(...),       // doesn't need themeMode — still rebuilds
      ]),
    );
  }
}
```

### Correct Approach — Provider Watched at Exact Right Level

```dart
class SettingsScreen extends StatelessWidget {
  // No provider here — purely a layout coordinator
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: const [
        _SectionHeader(title: 'Appearance'),
        _AppearanceSection(),    // only this rebuilds when theme changes
        _ComingSoonSection(),    // never rebuilds — const, static
        _AboutSection(),         // never rebuilds — const, static
      ]),
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider); // watched here only
    ...
  }
}
```

`SettingsScreen` is now a plain `StatelessWidget`. It has no provider dependency — it is purely a layout coordinator that assembles sections.

`_AppearanceSection` is the only `ConsumerWidget` because it is the only widget that actually needs `themeModeProvider`.

`_ComingSoonSection` and `_AboutSection` are plain `StatelessWidget`s — no provider needed, purely static UI. They never rebuild when the theme changes.

### The Rule

> Push provider dependencies down to the smallest widget that actually needs them.

---

## CONCEPT 6 — `const` on Widget Instantiation — The Real Performance Benefit

```dart
body: ListView(
  children: const [
    _SectionHeader(title: 'Appearance'),
    _AppearanceSection(),     // const
    _ComingSoonSection(),     // const
    _AboutSection(),          // const
  ],
),
```

When `_AppearanceSection` rebuilds (because `themeModeProvider` changed):

- Flutter sees `_ComingSoonSection()` is `const` — it is the exact same object as before
- Flutter skips rebuilding it entirely — does not even call its `build` method
- Same for `_AboutSection()` and `_SectionHeader`

`const` constructor = Flutter can cache and reuse the widget instance. This is only possible because those sections have no dynamic data — they are always identical. This is the actual performance gain from the separated approach.

---

## CONCEPT 7 — `RadioListTile<ThemeMode>`

```dart
RadioListTile<ThemeMode>(
  title: const Text('Dark'),
  value: ThemeMode.dark,      // this tile's own value
  groupValue: themeMode,      // currently selected value across all tiles
  onChanged: (value) {
    ref.read(themeModeProvider.notifier).state = value!;
  },
),
```

- `value` — what this specific radio button represents
- `groupValue` — the currently selected value. When `groupValue == value`, this tile shows as selected
- `onChanged` — called when tapped. The `value!` asserts non-null — `RadioListTile` only calls `onChanged` with a non-null value so this is safe

All three tiles share the same `groupValue: themeMode` from the provider. When one is selected, the provider updates, `themeMode` changes, `_AppearanceSection` rebuilds, and all three tiles reflect the new selection automatically.

---

## CONCEPT 8 — Private Classes in the Same File (`_`)

```dart
class _AppearanceSection extends ConsumerWidget { ... }
class _ComingSoonSection extends StatelessWidget { ... }
class _AboutSection extends StatelessWidget { ... }
class _SectionHeader extends StatelessWidget { ... }
```

The `_` prefix makes these classes **private to this file**. They cannot be imported or used anywhere else. This is intentional.

### Why Private — Not Separate Files

These sections only make sense in the context of `SettingsScreen`. Putting them in separate files would mean:

- A developer opens `widgets/` and sees `appearance_section.dart` — no idea which screen it belongs to
- More files = more navigation = harder to understand codebase
- Context is lost

Keeping them in the same file means:
- Open `settings_screen.dart` → everything related to settings is right there
- Context is preserved
- `_` signals: "this belongs here, don't use it elsewhere"

### The Production Rule for Widget Extraction

```
Used in one place only        → private class in same file (_Widget)
Used in 2+ screens            → shared file in core/widgets/ (Widget)
Complex + own state/providers → own file in widgets/ folder (HabitCard)
```

Over-extracting single-use widgets into separate files is actually a red flag in production — it signals poor judgment about cohesion. The `_` private class pattern exists in Dart specifically for this use case.

---

## CONCEPT 9 — `Theme.of(context)` for Theme-Aware Colors

```dart
color: Theme.of(context).colorScheme.primary,
```

`Theme.of(context)` — reads the current active theme from the widget tree. Returns the `ThemeData` that is currently applied.

`.colorScheme.primary` — the primary color defined in the theme's `ColorScheme`. When the theme switches from light to dark, this automatically returns the correct primary color for that theme.

Never hardcode colors in widgets. Always use `Theme.of(context).colorScheme.*` for theme-aware colors that adapt correctly to both light and dark mode.

---

## CONCEPT 10 — `ListView` vs `Column` for Settings Screens

```dart
body: ListView(
  children: const [...],
),
```

Settings screens use `ListView` even when content fits on screen because:

- Handles different screen sizes — smaller phones may need to scroll
- Scales naturally when more settings are added later
- Consistent scrollable behavior across all devices
- Handles keyboard appearance pushing content up correctly

`Column` would clip content on small screens or when keyboard appears.

---

## Day 7 Verification

✅ Settings screen shows three theme radio buttons
✅ Selecting Light → entire app switches to light theme instantly
✅ Selecting Dark → entire app switches to dark theme instantly
✅ Selecting System → follows device theme
✅ Radio button shows correct selection state
✅ Cloud Sync and AI Coach show V2 chip
✅ Navigating back to home screen keeps selected theme
✅ Only `_AppearanceSection` rebuilds on theme change — other sections untouched

---

## Next — Day 8-9: Habit Detail Screen

The habit detail screen will show current streak, longest streak, a calendar grid of completion history, and wire up the edit button to navigate to the edit screen with the correct habit.