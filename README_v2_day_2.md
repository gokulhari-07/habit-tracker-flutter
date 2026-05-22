# Onward — Refactor Commit Notes
# AsyncNotifier + Centralized State Architecture Refactor

────────────────────────────────────────────────────────────────────
CONTEXT OF THIS REFACTOR
────────────────────────────────────────────────────────────────────

V1 was already:
- built
- uploaded to Play Store
- running in closed testing

Before starting V2 features like:
- AI
- auth
- cloud sync
- notifications

the architecture needed improvement.

Reason:
V1 architecture was acceptable for MVP,
but not scalable enough for future growth.

Main goal of this refactor:
✅ improve state architecture
✅ reduce UI-business logic coupling
✅ prepare scalable foundation for V2

This refactor was NOT about:
- adding features
- improving UI

It was about:
# fixing architectural direction.

────────────────────────────────────────────────────────────────────
ORIGINAL V1 ARCHITECTURE
────────────────────────────────────────────────────────────────────

Original flow:

UI → Repository → Database

Meaning:
Widgets directly:
- accessed repository
- mutated database
- invalidated providers manually

Example old code:

```dart
final repo = ref.read(habitRepositoryProvider);

await repo.toggleCompletion(...)

ref.invalidate(...)
```

Problems:
❌ UI tightly coupled to data layer
❌ business logic spread across widgets
❌ too many manual refreshes
❌ poor scalability
❌ difficult future sync support
❌ hard to maintain
❌ duplicated state fetching

This architecture works for MVPs,
but becomes messy as app complexity grows.

────────────────────────────────────────────────────────────────────
WHY CONTROLLERS EXIST
────────────────────────────────────────────────────────────────────

Goal:
Move mutation/business logic OUT of widgets.

New architecture target:

UI → Controller → Repository → Database

Meaning:
- UI displays state
- Controller handles actions/business logic
- Repository handles persistence
- Database stores data

Controller acts like:
"middle management"

Widgets should NOT:
- know repository details
- perform business logic
- manually refresh state

Widgets SHOULD:
- display UI
- trigger controller actions

This concept is called:
# Separation of Concerns

────────────────────────────────────────────────────────────────────
WHY ASYNCNOTIFIER WAS INTRODUCED
────────────────────────────────────────────────────────────────────

Previously:

```dart
FutureProvider<List<HabitEntity>>
```

Problem:
FutureProvider is good only for:
✅ fetching data

But poor for:
❌ mutations
❌ centralized updates
❌ business actions
❌ scalable state management

AsyncNotifier supports:
✅ fetching
✅ mutations
✅ state updates
✅ loading/error handling
✅ centralized logic

This makes AsyncNotifier ideal for:
# app-level state management

────────────────────────────────────────────────────────────────────
CREATING HABITCONTROLLER
────────────────────────────────────────────────────────────────────

New file created:

```text
presentation/providers/habit_controller.dart
```

Controller introduced:

```dart
class HabitController
    extends AsyncNotifier<List<HabitUiModel>>
```

Meaning:
- controller manages async state
- state type = List<HabitUiModel>

This controller became:
# single source of truth for HomeScreen state.

────────────────────────────────────────────────────────────────────
UNDERSTANDING ASYNCNOTIFIERPROVIDER
────────────────────────────────────────────────────────────────────

Provider declaration:

```dart
final habitsProvider =
    AsyncNotifierProvider<
      HabitController,
      List<HabitUiModel>
    >(
      HabitController.new,
    );
```

General structure:

```dart
AsyncNotifierProvider<
  ControllerType,
  StateType
>
```

In this app:

ControllerType:
```dart
HabitController
```

StateType:
```dart
List<HabitUiModel>
```

Meaning:
- provider internally uses HabitController
- controller manages list of UI models

────────────────────────────────────────────────────────────────────
WHAT DOES .new MEAN
────────────────────────────────────────────────────────────────────

```dart
HabitController.new
```

Short syntax for:

```dart
() => HabitController()
```

Meaning:
Riverpod should create controller
using constructor.

────────────────────────────────────────────────────────────────────
IMPORTANT CONCEPT:
STATE ACCESS VS CONTROLLER ACCESS
────────────────────────────────────────────────────────────────────

This SAME provider gives TWO things.

1. STATE ACCESS

```dart
ref.watch(habitsProvider)
```

Returns:
```dart
AsyncValue<List<HabitUiModel>>
```

Used for:
- rendering UI
- reading state

2. CONTROLLER ACCESS

```dart
ref.read(habitsProvider.notifier)
```

Returns:
```dart
HabitController
```

Used for:
- actions
- mutations
- business logic

This is one of the most important
Riverpod architecture concepts.

────────────────────────────────────────────────────────────────────
UNDERSTANDING BUILD()
────────────────────────────────────────────────────────────────────

Inside controller:

```dart
@override
Future<List<HabitUiModel>> build() async
```

Purpose:
Initial loading method.

Riverpod automatically calls build()
when provider is first used.

Equivalent to old:

```dart
FutureProvider(...)
```

But now:
controller can ALSO mutate state.

────────────────────────────────────────────────────────────────────
WHY HABITUIMODEL WAS CREATED
────────────────────────────────────────────────────────────────────

Originally:
HomeScreen used:

```dart
HabitEntity
```

But UI ALSO needed:
- streak
- completion status

So widgets separately watched:
- streak provider
- completion provider

Result:
❌ multiple DB reads
❌ fragmented state
❌ inconsistent rebuilds
❌ flickering
❌ stale UI

This led to creation of:

```text
presentation/ui_models/habit_ui_model.dart
```

HabitUiModel:

```dart
class HabitUiModel {
  final int id;
  final String name;
  final DateTime createdAt;

  final bool isCompletedToday;
  final int currentStreak;
}
```

Purpose:
# one UI-ready state object

This is called:
# UI Model / View Model pattern

Common in:
- Flutter
- Android native
- React
- SwiftUI

────────────────────────────────────────────────────────────────────
ENTITY VS UI MODEL
────────────────────────────────────────────────────────────────────

HabitEntity:
- raw domain data
- pure business entity

HabitUiModel:
- screen-ready state
- presentation concerns

UI-only properties:
- streak
- isCompletedToday

should NOT live in domain entities.

This separation is important for:
# clean architecture

────────────────────────────────────────────────────────────────────
HOME SCREEN REFACTOR
────────────────────────────────────────────────────────────────────

Before:
HabitCard watched:
- streak provider
- completion provider

Example old architecture:

```dart
ref.watch(isCompletedTodayProvider(...))
ref.watch(habitStreakProvider(...))
```

Problems:
❌ each card had multiple subscriptions
❌ multiple DB reads
❌ rebuild inconsistencies
❌ flickering

────────────────────────────────────────────────────────────────────
NEW HOME SCREEN ARCHITECTURE
────────────────────────────────────────────────────────────────────

Now:
HabitCard directly receives:

```dart
HabitUiModel
```

Meaning:
ALL required UI state already exists inside ONE object.

This reduced:
✅ provider fragmentation
✅ duplicated DB calls
✅ inconsistent rebuilds

────────────────────────────────────────────────────────────────────
REMOVING DIRECT REPOSITORY MUTATIONS
────────────────────────────────────────────────────────────────────

Old widget logic:

```dart
final repo = ref.read(habitRepositoryProvider);

await repo.toggleCompletion(...)
```

Problem:
UI directly mutated repository.

New architecture:

```dart
await ref
    .read(habitsProvider.notifier)
    .toggleHabitCompletion(...)
```

Meaning:
UI now talks ONLY to controller.

Controller handles:
- mutation
- refresh
- business logic

This is much cleaner architecture.

────────────────────────────────────────────────────────────────────
WHY ref.invalidate() WAS BAD
────────────────────────────────────────────────────────────────────

Old architecture heavily used:

```dart
ref.invalidate(...)
```

Problems:
❌ manual refresh management
❌ unnecessary rebuilds
❌ difficult scalability
❌ hidden dependency chains

Goal of refactor:
reduce invalidate usage and centralize updates.

────────────────────────────────────────────────────────────────────
DETAIL SCREEN PROBLEMS DISCOVERED
────────────────────────────────────────────────────────────────────

After HomeScreen refactor:
HomeScreen worked correctly.

BUT:
DetailScreen became stale.

Reason:
DetailScreen still used:
- old providers
- independent DB fetches

This created:
# hybrid architecture state

Meaning:
- HomeScreen = centralized
- DetailScreen = old architecture

This caused:
❌ unsynchronized UI
❌ stale updates

────────────────────────────────────────────────────────────────────
SELECTEDHABITPROVIDER
────────────────────────────────────────────────────────────────────

To reduce independent DB reads:

```dart
final selectedHabitProvider =
    Provider.family<HabitUiModel?, int>((ref, habitId) {
```

Purpose:
derive selected habit from centralized state.

Instead of:
```text
DB query → DetailScreen
```

New flow:
```text
Controller state → derived selected habit
```

This is called:
# derived state architecture

────────────────────────────────────────────────────────────────────
WHY DETAIL SCREEN STILL FLICKERED
────────────────────────────────────────────────────────────────────

DetailScreen still used:

```dart
habitCompletionsProvider
```

which was:
```dart
FutureProvider
```

Every toggle caused:
- provider refetch
- loading state
- full screen rebuild

This caused:
❌ flickering
❌ loading indicators

Important realization:
# multiple async providers cause UI instability.

────────────────────────────────────────────────────────────────────
WHY FULL OPTIMISTIC ARCHITECTURE
WAS NOT IMPLEMENTED NOW
────────────────────────────────────────────────────────────────────

True ideal solution would require:
- normalized state store
- optimistic updates
- partial state updates
- cached completions state
- advanced derived state

This was intentionally postponed because:
❌ too large for current app stage
❌ unnecessary complexity for MVP scale

Current architecture is:
# good enough foundation for V2.

Very important engineering lesson:
# not every imperfection must be solved immediately.

────────────────────────────────────────────────────────────────────
PRODUCT DECISION:
DISABLING CALENDAR EDITING
────────────────────────────────────────────────────────────────────

During refactor,
important product realization happened:

Allowing users to freely edit historical habit completions:
❌ weakens streak integrity
❌ weakens analytics accuracy
❌ weakens future AI insights

Decision:
Calendar should become:
# visualization/history UI

NOT mutation UI.

This is actually better product design
for serious habit tracking.

────────────────────────────────────────────────────────────────────
V2 CALENDAR DIRECTION
────────────────────────────────────────────────────────────────────

Planned improvements:

✅ previous month navigation
✅ swipeable month history
✅ historical visualization
✅ read-only calendar history

Removed idea:
❌ arbitrary historical toggling

Better completion flow:
- HomeScreen daily actions
- notifications
- widgets
- quick actions

────────────────────────────────────────────────────────────────────
IMPORTANT ENGINEERING CONCEPTS LEARNED
────────────────────────────────────────────────────────────────────

This refactor introduced:

- AsyncNotifier
- centralized state management
- controller architecture
- UI models
- single source of truth
- derived state
- separation of concerns
- state-driven UI
- provider dependency chains
- rebuild debugging
- scalable Riverpod architecture
- production tradeoffs
- architecture migration strategy

────────────────────────────────────────────────────────────────────
MOST IMPORTANT LESSONS
────────────────────────────────────────────────────────────────────

1.
Centralized state is critical
for UI consistency.

2.
Widgets should display state,
NOT own business logic.

3.
FutureProviders everywhere
lead to fragmented state.

4.
UI Models reduce provider fragmentation.

5.
Not every architecture problem
must be solved immediately.

6.
Good architecture is about:
- scalability
- maintainability
- clarity
NOT complexity.

────────────────────────────────────────────────────────────────────
CURRENT ARCHITECTURE STATUS
────────────────────────────────────────────────────────────────────

Current state after refactor:

✅ HabitController introduced
✅ AsyncNotifier architecture added
✅ HomeScreen centralized
✅ direct repo mutations removed from Home UI
✅ reduced invalidate usage
✅ HabitUiModel introduced
✅ centralized HomeScreen state
✅ DetailScreen partially centralized
✅ state synchronization improved
✅ architecture prepared for V2 scaling

────────────────────────────────────────────────────────────────────
NEXT MAJOR PHASE
────────────────────────────────────────────────────────────────────

V2 planning and implementation:
- auth
- cloud sync
- notifications
- AI insights
- onboarding
- advanced analytics
- scalable data flow

Current architecture is now
MUCH better prepared for future scaling.