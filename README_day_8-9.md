# Day 8-9 – Habit Detail Screen

## What Was Done Today
- Added `getHabitById` to `HabitRepository` abstract contract and `DriftHabitRepository`
- Added `habitByIdProvider` and `habitCompletionsProvider` to `habit_providers.dart`
- Built fully functional `HabitDetailScreen` with stats and calendar
- Wired edit button to navigate to `AddEditHabitScreen` with pre-filled habit
- Fixed delete navigation using `Navigator.popUntil` to return to home screen
- Fixed state synchronization — checkbox, calendar, and streak subtitle now all stay in sync

---

## File Structure Changes

```
lib/
└── features/
    └── habits/
        ├── domain/
        │   └── repositories/
        │       └── habit_repository.dart         ← UPDATED (getHabitById added)
        ├── data/
        │   └── repositories/
        │       └── drift_habit_repository.dart   ← UPDATED (getHabitById implemented)
        └── presentation/
            ├── providers/
            │   └── habit_providers.dart          ← UPDATED (2 new providers)
            ├── screens/
            │   └── habit_detail_screen.dart      ← FULLY REBUILT
            └── widgets/
                └── habit_card.dart               ← UPDATED (sync fix)
```

---

## CONCEPT 1 — Two-Layer Screen Architecture

`HabitDetailScreen` is split into two layers:

```
HabitDetailScreen        → handles async loading of habit by id
      ↓ once data ready
_HabitDetailView         → builds the actual UI with non-null HabitEntity
```

Why split?

`HabitDetailScreen` only job is to fetch the habit and handle the three async states — loading, error, data. Once the habit is available it hands off to `_HabitDetailView` which always receives a guaranteed non-null `HabitEntity`.

`_HabitDetailView` never deals with loading states. It always has real data. This keeps each layer focused on one responsibility.

```dart
data: (habit) {
  if (habit == null) return Scaffold(...); // deleted habit edge case
  return _HabitDetailView(habit: habit);   // guaranteed non-null from here
},
```

---

## CONCEPT 2 — `GridView.builder` Inside `ListView`

```dart
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  ...
)
```

When you place a `GridView` inside a `ListView`, two problems arise:

**Problem 1 — Height conflict:**
`GridView` tries to expand infinitely. `ListView` also tries to give it infinite height. Flutter throws a layout error.

`shrinkWrap: true` — makes `GridView` take only as much height as its content needs instead of expanding infinitely. Fixes the layout error.

**Problem 2 — Scroll conflict:**
Both `GridView` and `ListView` want to handle scrolling. They conflict — causing janky, unpredictable scroll behavior.

`NeverScrollableScrollPhysics()` — disables the `GridView`'s own scrolling entirely. The parent `ListView` handles all scrolling. One scroll controller, no conflict.

**Rule: Any scrollable widget placed inside another scrollable widget needs `shrinkWrap: true` and `NeverScrollableScrollPhysics()`.**

---

## CONCEPT 3 — Calendar Offset Logic

Every month starts on a different weekday. The calendar grid must account for this so day 1 lands in the correct column.

```dart
final firstDay = DateTime(now.year, now.month, 1);
final offset = firstDay.weekday - 1;
// Monday = weekday 1 → offset 0 (no empty cells)
// Wednesday = weekday 3 → offset 2 (2 empty cells before day 1)
// Sunday = weekday 7 → offset 6 (6 empty cells before day 1)

itemCount: daysInMonth + offset,

itemBuilder: (context, index) {
  if (index < offset) return const SizedBox.shrink(); // empty placeholder
  final day = index - offset + 1;                     // actual day number
  ...
}
```

`SizedBox.shrink()` — a zero-size invisible widget. Used as an empty placeholder cell. Takes up grid space without rendering anything visible.

`DateTime(now.year, now.month + 1, 0).day` — a Dart trick to get the number of days in a month. Day 0 of the next month = last day of the current month.

---

## CONCEPT 4 — Four Day Cell Visual States

Each day cell has one of four visual states:

```
Completed  → primary color background, light text
Today      → primaryContainer background + primary color border
Future     → transparent background, dimmed text, non-tappable
Past       → surfaceVariant background, normal text, tappable
```

```dart
if (isCompleted) {
  backgroundColor = colorScheme.primary;
  textColor = colorScheme.onPrimary;
} else if (isToday) {
  backgroundColor = colorScheme.primaryContainer;
  textColor = colorScheme.onPrimaryContainer;
} else if (isFuture) {
  backgroundColor = Colors.transparent;
  textColor = colorScheme.onSurface.withOpacity(0.3);
} else {
  backgroundColor = colorScheme.surfaceVariant;
  textColor = colorScheme.onSurfaceVariant;
}
```

All colors come from `colorScheme` — they adapt automatically to light and dark mode. No hardcoded colors anywhere.

`isFuture` days have `onTap: null` — `GestureDetector` ignores taps when `onTap` is null. Users cannot mark future days as complete.

---

## CONCEPT 5 — `AnimatedContainer` for Smooth Toggling

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  decoration: BoxDecoration(color: backgroundColor, ...),
  child: ...,
)
```

When a day is toggled, `backgroundColor` changes. `AnimatedContainer` automatically animates between the old and new color over 200ms. No `AnimationController`, no `Tween`, no `AnimatedBuilder` needed — Flutter handles the interpolation entirely.

`Container` vs `AnimatedContainer`:
- `Container` — changes instantly, no animation
- `AnimatedContainer` — animates between old and new values automatically whenever a property changes

Use `AnimatedContainer` any time you want a simple property change (color, size, border radius, padding) to animate smoothly without writing animation code.

---

## CONCEPT 6 — State Synchronization — The Core Problem

This was the most important bug fixed in Day 8-9.

Three UI elements display data derived from the same underlying completion records:

```
Checkbox in HomeScreen    → watches isCompletedTodayProvider(habitId)
Calendar in DetailScreen  → watches habitCompletionsProvider(habitId)
Streak subtitle           → watches habitsProvider (triggers FutureBuilder)
```

These are three separate providers. Invalidating one does NOT automatically invalidate the others. If any toggle only invalidates one provider, the other two show stale data.

### The Wrong Approach (before fix)

```
Checkbox toggled:
→ invalidated isCompletedTodayProvider  ✅
→ invalidated habitsProvider            ✅
→ habitCompletionsProvider NOT touched  ❌ calendar stale

Calendar toggled:
→ invalidated habitCompletionsProvider  ✅
→ invalidated habitsProvider            ✅
→ isCompletedTodayProvider NOT touched  ❌ checkbox stale
```

### The Correct Approach (after fix)

Every toggle — whether from checkbox or calendar — invalidates ALL THREE providers:

```dart
// In HabitCard checkbox onChanged
ref.invalidate(isCompletedTodayProvider(habit.id));
ref.invalidate(habitCompletionsProvider(habit.id));
ref.invalidate(habitsProvider);

// In _CalendarSection day onTap
ref.invalidate(habitCompletionsProvider(habit.id));
ref.invalidate(isCompletedTodayProvider(habit.id));
ref.invalidate(habitsProvider);
```

### The Mental Model

```
One source of truth: SQLite database
Three views of that truth: checkbox, calendar, streak

Any change to the database must invalidate
ALL providers that read from it — not just one.
```

This is a fundamental rule in state management. When multiple providers derive data from the same source, a mutation must propagate to all of them.

---

## CONCEPT 7 — `Navigator.popUntil` vs `pushNamedAndRemoveUntil`

After deleting a habit from `AddEditHabitScreen`, the navigation stack is:

```
HomeScreen → HabitDetailScreen → AddEditHabitScreen
```

After delete, the user must return to `HomeScreen`. Two options exist:

**`Navigator.popUntil(context, ModalRoute.withName('/'))`**
Pops screens off the stack until it reaches `/`. `HomeScreen` stays in the stack — it is just revealed. Not rebuilt from scratch.

**`Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false)`**
Removes everything from the stack and pushes a brand new `/` screen. `HomeScreen` is completely recreated.

```
popUntil              → reveals existing HomeScreen ✅ correct
pushNamedAndRemoveUntil → destroys and recreates HomeScreen ❌ unnecessary
```

`popUntil` is correct here because `HomeScreen` already exists — no need to recreate it. Riverpod's `ref.invalidate(habitsProvider)` handles the data refresh.

`pushNamedAndRemoveUntil` is appropriate when you want to **prevent going back** — after logout, after onboarding, or after a one-time setup flow. Not for normal delete operations.

---

## CONCEPT 8 — `colorScheme.onPrimary` — The `on` Color Convention

Material 3 uses paired colors for foreground/background:

```
primary         → background color
onPrimary       → text/icon color ON TOP of primary background

primaryContainer    → softer background
onPrimaryContainer  → text/icon color on top of primaryContainer

surface         → card/sheet background
onSurface       → text/icon color on top of surface

surfaceVariant  → slightly different surface
onSurfaceVariant → text/icon on top of surfaceVariant
```

The `on` prefix means "what color to use when rendering content ON TOP of this background." Always pair them correctly — using `primary` background with `onPrimary` text guarantees correct contrast in both light and dark mode automatically.

Never hardcode text colors. Always use the correct `on` pairing from `colorScheme`.

---

## CONCEPT 9 — `Theme.of(context).textTheme`

```dart
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  fontWeight: FontWeight.bold,
),
```

`textTheme` — a set of predefined text styles from the current theme. Material 3 text scale:

```
displayLarge / displayMedium / displaySmall   → very large hero text
headlineLarge / headlineMedium / headlineSmall → section headings
titleLarge / titleMedium / titleSmall          → titles, AppBar
bodyLarge / bodyMedium / bodySmall             → regular text
labelLarge / labelMedium / labelSmall          → buttons, captions
```

`.copyWith(fontWeight: FontWeight.bold)` — takes the theme's predefined style and overrides just one property. The rest (font size, color, letter spacing) stays as defined by the theme. Never hardcode font sizes — always start from `textTheme` and override only what you need.

`?.copyWith` — the `?` handles the case where `textTheme.headlineMedium` could theoretically be null.

---

## CONCEPT 10 — `toSet()` for O(1) Lookup in Calendar

```dart
final completedDates = completions
    .where((c) => c.isCompleted)
    .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
    .toSet();  // ← Set instead of List
```

The calendar has up to 31 cells. For each cell, we check if that date is completed:

```dart
final isCompleted = completedDates.contains(date);
```

If `completedDates` were a `List`:
- `.contains()` scans the entire list linearly — O(n)
- 31 cells × n completions = potentially slow for large histories

If `completedDates` is a `Set`:
- `.contains()` uses a hash lookup — O(1)
- 31 cells × O(1) = always fast regardless of history size

Also, dates are normalized to midnight (`DateTime(year, month, day)`) before adding to the Set. This ensures two `DateTime` objects representing the same day but different times are treated as equal in the Set.

---

## Day 8-9 Verification

✅ Habit name shown in AppBar
✅ Current streak and longest streak correct
✅ Calendar shows correct month with correct day alignment
✅ Completed days show filled primary color
✅ Today highlighted with border
✅ Future days dimmed and non-tappable
✅ Tapping past day toggles with smooth color animation
✅ Edit button opens edit screen with pre-filled name
✅ Saving edit updates name in detail screen and home screen
✅ Delete navigates directly to home screen with updated list
✅ Checkbox on home screen syncs with calendar toggle
✅ Calendar syncs with checkbox toggle on home screen
✅ Streak subtitle syncs with both checkbox and calendar toggle

---

## Next — Day 10: Refactor & Polish

Code review pass, removing any remaining test code, improving UI consistency, handling edge cases, and preparing the codebase for release.