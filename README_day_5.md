# Day 5 – Home Screen Functional

## What Was Done Today
- Added `HabitCompletionEntity` — pure Dart domain object for completions
- Extended `HabitRepository` with three completion methods
- Implemented completion methods in `DriftHabitRepository`
- Created `StreakService` — pure Dart streak calculation logic
- Created `habit_providers.dart` — Riverpod providers for the UI
- Built functional `HomeScreen` with list, empty state, checkbox, streak
- Extracted `HabitCard` into its own file under `widgets/`
- Updated `app.dart` with dynamic route for habit detail

---

## File Structure After Day 5

```
lib/
└── features/
    └── habits/
        ├── domain/
        │   ├── entities/
        │   │   ├── habit_entity.dart
        │   │   └── habit_completion_entity.dart       ← NEW
        │   ├── repositories/
        │   │   └── habit_repository.dart              ← UPDATED
        │   └── services/
        │       └── streak_service.dart                ← NEW
        ├── data/
        │   └── repositories/
        │       └── drift_habit_repository.dart        ← UPDATED
        └── presentation/
            ├── screens/
            │   └── home_screen.dart                   ← UPDATED
            ├── widgets/
            │   └── habit_card.dart                    ← NEW
            └── providers/
                └── habit_providers.dart               ← NEW
```

---

## Big Picture — Data Flow

```
SQLite file
    ↓
DriftHabitRepository  (fetches, maps to entities)
    ↓
Riverpod Providers    (holds data, notifies UI when changed)
    ↓
HomeScreen            (reads providers, renders UI)
    ↓
User taps checkbox
    ↓
Repository writes to SQLite
    ↓
Provider invalidated → refetches → UI rebuilds
```

Keep this diagram in mind when reading any file in Day 5.

---

## CONCEPT 1 — Why `HabitCompletionEntity` Exists

Same reason as `HabitEntity` in Day 4. The domain and UI layers must never see Drift's generated `HabitCompletion` class. `HabitCompletionEntity` is a clean pure Dart mirror of that class with zero Drift dependency.

```dart
class HabitCompletionEntity {
  final int id;
  final int habitId;
  final DateTime date;
  final bool isCompleted;

  const HabitCompletionEntity({...});
}
```

`final` on every field — immutable. `const` constructor — compile-time constant, slightly more performant.

---

## CONCEPT 2 — Three New Repository Methods

Added to `HabitRepository` abstract contract and implemented in `DriftHabitRepository`.

| Method | Purpose |
|--------|---------|
| `toggleCompletion(habitId, date, isCompleted)` | Insert or update a completion record when user taps checkbox |
| `getCompletionsForHabit(habitId)` | Return all completion records for one habit — used for streak calculation |
| `isCompletedToday(habitId)` | Return true/false — is this habit done today? Used by checkbox state |

---

## CONCEPT 3 — The Upsert Pattern in `toggleCompletion`

When user taps the checkbox, two scenarios exist:

```
Scenario A — First tap today:
No record exists for this habit on today's date → INSERT a new row

Scenario B — Already tapped before today:
A record exists → UPDATE that row's isCompleted value
```

This is called an **upsert** — update if exists, insert if not.

```dart
final existing = await (_db.select(_db.habitCompletions)
  ..where((t) => t.habitId.equals(habitId))
  ..where((t) => t.date.equals(date)))
  .getSingleOrNull();

if (existing == null) {
  // INSERT
} else {
  // UPDATE
}
```

`getSingleOrNull()` — returns the one matching row, or `null` if none found. Only one row can ever exist for a specific habit on a specific date by design — so single is always correct here.

---

## CONCEPT 4 — `existing?.isCompleted ?? false`

From `isCompletedToday`:

```dart
return existing?.isCompleted ?? false;
```

Two operators working together:

`?.` — **null-safe access**. If `existing` is null, the whole expression returns null instead of crashing.

`??` — **null coalescing operator**. If the left side is null, use the right side value instead.

Full logic:
```
Record exists, isCompleted = true  → returns true
Record exists, isCompleted = false → returns false
No record exists at all            → returns false
```

---

## CONCEPT 5 — Why Filter `isCompleted` in `_getStreak`

`getCompletionsForHabit` returns **all** completion records for a habit — both `isCompleted = true` and `isCompleted = false`. It only filters by `habitId`, not by `isCompleted`.

Why do `false` records exist? Because of the upsert pattern. When a user checks then unchecks a habit, the record is updated to `false` — not deleted.

```
HABIT_COMPLETIONS for habitId = 1
┌────┬────────────┬─────────────┐
│ id │ date       │ isCompleted │
├────┼────────────┼─────────────┤
│ 1  │ 2026-03-01 │ true        │ ← counted
│ 2  │ 2026-03-02 │ false       │ ← checked then unchecked — NOT counted
│ 3  │ 2026-03-03 │ true        │ ← counted
│ 4  │ 2026-03-04 │ true        │ ← counted
└────┴────────────┴─────────────┘
```

If you pass all 4 dates to `StreakService` without filtering, March 2 would be wrongly counted as a completed day. So you filter first:

```dart
final completedDates = completions
    .where((c) => c.isCompleted)  // only true records
    .map((c) => c.date)
    .toList();
```

Only March 1, 3, 4 go to `StreakService`. Streak = 2. Correct.

---

## CONCEPT 6 — `async` Without `await` Inside a Provider

```dart
final habitsProvider = FutureProvider<List<HabitEntity>>((ref) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getAllHabits(); // no await
});
```

**`async` does two things:**
1. Enables `await` inside the function
2. **Makes the function automatically return a `Future`** — even if no `await` is used inside

`FutureProvider` expects a function that returns a `Future<T>`. The `async` keyword satisfies this requirement automatically.

Both of these are identical in behavior:

```dart
// With async
(ref) async {
  return repo.getAllHabits();
}

// Without async — explicitly returning Future
(ref) {
  return repo.getAllHabits(); // getAllHabits() already returns Future
}
```

The `async` version is preferred for consistency — if you add more async calls later, the function signature is already ready.

---

## CONCEPT 7 — Watching a Provider Inside Another Provider

You already know `ref.watch` inside `build`. The same concept applies inside providers — it creates a **dependency chain**.

```dart
// Provider A
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider B — depends on A
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider); // dependency on A
  return DriftHabitRepository(db);
});

// Provider C — depends on B
final habitsProvider = FutureProvider<List<HabitEntity>>((ref) async {
  final repo = ref.watch(habitRepositoryProvider); // dependency on B
  return repo.getAllHabits();
});
```

The dependency chain:

```
databaseProvider
      ↓ watched by
habitRepositoryProvider
      ↓ watched by
habitsProvider
      ↓ watched by
HomeScreen (build method)
```

If any provider in the chain changes, everything below it rebuilds automatically.

### `ref.watch` vs `ref.read` inside providers

- `ref.watch` — creates a live dependency. Used inside providers and `build`. If the watched provider changes, this one rebuilds too.
- `ref.read` — one-time read, no dependency. Used inside event handlers and callbacks where you just need the value once and don't need to rebuild.

---

## CONCEPT 8 — `FutureProvider` and `AsyncValue`

`FutureProvider` is a Riverpod provider for **async data**. It wraps the result in `AsyncValue<T>` which has three states:

```
AsyncValue.loading() → still fetching
AsyncValue.data(...) → fetch complete, data available
AsyncValue.error(...) → something went wrong
```

The UI handles all three states with `.when()`:

```dart
habitsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (habits) => ListView(...),
)
```

No manual `isLoading` booleans. No `if` chains. Riverpod handles all three states cleanly in one place.

---

## CONCEPT 9 — `FutureProvider.family`

A regular `FutureProvider` has no parameters. But each habit card needs completion status for **its specific habitId**. `.family` solves this.

`.family` is a **parameterized provider factory** — you pass a parameter and get back a provider instance specific to that parameter.

```dart
final isCompletedTodayProvider = FutureProvider.family<bool, int>((ref, habitId) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.isCompletedToday(habitId);
});
```

`FutureProvider.family<bool, int>` — `bool` is the return type, `int` is the parameter type.

Each habitId gets its own independent provider instance:

```dart
isCompletedTodayProvider(1)  // provider for habit id 1 — independent
isCompletedTodayProvider(2)  // provider for habit id 2 — independent
isCompletedTodayProvider(3)  // provider for habit id 3 — independent
```

Invalidating one does not affect others:

```dart
ref.invalidate(isCompletedTodayProvider(habit.id)); // only this card refetches
```

---

## CONCEPT 10 — `ConsumerWidget` vs `ConsumerStatefulWidget`

- `ConsumerStatefulWidget` — needed when the widget has local state (`setState`, text controllers, animation controllers etc.)
- `ConsumerWidget` — simpler. Used when the widget has no local state at all. Only reads/watches providers.

HomeScreen and HabitCard have no local state — they only watch providers. So `ConsumerWidget` is the right choice. Simpler code, same capability.

---

## CONCEPT 11 — `ref.invalidate` — Why and When

`ref.invalidate(provider)` tells Riverpod: **"throw away the cached value of this provider and fetch it fresh."**

When user taps checkbox:

```dart
await repo.toggleCompletion(...);                      // write to DB
ref.invalidate(isCompletedTodayProvider(habit.id));    // checkbox refreshes
ref.invalidate(habitsProvider);                        // streak refreshes
```

Why does `ref.invalidate(habitsProvider)` refresh the streak subtitle?

The streak `FutureBuilder` runs `_getStreak()` when the `HabitCard` **builds**. Card only rebuilds when `HomeScreen` rebuilds. `HomeScreen` rebuilds when `habitsProvider` changes. So:

```
ref.invalidate(habitsProvider)
        ↓
habitsProvider refetches
        ↓
HomeScreen rebuilds
        ↓
HabitCard rebuilds
        ↓
FutureBuilder re-runs _getStreak()
        ↓
New streak shown
```

---

## CONCEPT 12 — Dynamic Routes with `onGenerateRoute`

Named routes in Flutter only support static strings like `/settings`. For dynamic routes like `/habit/3` where the id changes, you need `onGenerateRoute`.

```dart
onGenerateRoute: (settings) {
  if (settings.name?.startsWith('/habit/') == true) {
    final id = int.parse(settings.name!.split('/').last);
    return MaterialPageRoute(
      builder: (_) => HabitDetailScreen(habitId: id),
    );
  }
  return null;
},
```

`settings.name` — the route string pushed, e.g. `/habit/3`.

`settings.name!.split('/').last` — splits `/habit/3` into `['', 'habit', '3']`. `.last` gives `'3'`. `int.parse` converts to integer `3`.

`?.startsWith(...)` — the `?.` handles the case where `name` could be null safely.

---

## CONCEPT 13 — Why `HabitCard` is in a Separate File

In production Flutter apps, every widget with meaningful complexity lives in its own file.

```
lib/features/habits/presentation/
    ├── screens/
    │   └── home_screen.dart    ← full screens navigated to
    └── widgets/
        └── habit_card.dart     ← complex reusable widgets
```

`HabitCard` qualifies for its own file because it has:
- Its own provider watch (`isCompletedTodayProvider`)
- Its own event handler (checkbox `onChanged`)
- Its own helper method (`_getStreak`)

Rule: if a widget has its own state, providers, or helper methods — it deserves its own file.

---

## CONCEPT 14 — `ListView.builder` vs `ListView`

```dart
ListView.builder(
  itemCount: habits.length,
  itemBuilder: (context, index) => HabitCard(habit: habits[index]),
)
```

`ListView.builder` builds items **lazily** — only the visible cards are constructed. If you have 100 habits, only the 8-10 visible ones are built at a time. Efficient for any size list.

`ListView` (without builder) builds **all items at once** regardless of visibility. Fine for very small lists (2-3 items), not suitable for dynamic data.

Always use `ListView.builder` for data-driven lists.

---

## CONCEPT 15 — `FutureBuilder` in HabitCard

```dart
subtitle: FutureBuilder<int>(
  future: _getStreak(ref, habit.id),
  builder: (context, snapshot) {
    final streak = snapshot.data ?? 0;
    return Text(streak > 0 ? '🔥 $streak day streak' : 'Start your streak today!');
  },
),
```

`FutureBuilder` — Flutter widget that builds UI based on a Future's result. Standard Flutter way to show async data inside a widget without a Riverpod provider.

`snapshot.data ?? 0` — `snapshot.data` is null while loading. `?? 0` shows 0 as default until streak loads.

`streak > 0 ? '🔥 $streak day streak' : 'Start your streak today!'` — ternary operator. If streak > 0 show count with emoji, otherwise show motivational message.

---

## Day 5 Verification

✅ Empty state shows when no habits exist
✅ Habits appear in list after adding via FAB
✅ Checkbox toggles completion for today
✅ Streak subtitle updates after toggling
✅ `runtimeType` of list items is `HabitEntity` — not Drift's `Habit`
✅ Settings icon navigates to settings screen
✅ Tapping a habit card navigates to detail screen with correct habitId

---

## Next — Day 6: Add / Edit Habit Screen

The `AddHabitScreen` will be made functional — form validation, saving to DB via repository, and automatic list refresh on return to HomeScreen.