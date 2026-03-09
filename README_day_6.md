# Day 6 – Add / Edit Habit Screen Functional

## What Was Done Today
- Made `AddEditHabitScreen` fully functional for both add and edit modes
- Form validation — empty and too-short names rejected
- Save button calls repository — insert in add mode, update in edit mode
- Delete habit with confirmation dialog in edit mode
- `_isSaving` state disables button and shows spinner during DB operation
- Updated `app.dart` with `/edit` route using `onGenerateRoute` and `arguments`
- Updated `HabitCard` `onTap` to invalidate `habitsProvider` on return
- Updated `HabitDetailScreen` placeholder with edit icon in AppBar

---

## File Structure Changes

```
lib/
└── features/
    └── habits/
        └── presentation/
            └── screens/
                ├── add_edit_habit_screen.dart   ← FULLY REBUILT
                └── habit_detail_screen.dart     ← UPDATED (edit icon added)

lib/app.dart                                     ← UPDATED (/edit route added)
lib/features/habits/presentation/
    └── widgets/
        └── habit_card.dart                      ← UPDATED (onTap invalidates provider)
```

---

## CONCEPT 1 — One Screen for Both Add and Edit

Add and Edit are 95% identical — same form, same validation, same save logic. Having two separate screens duplicates all that code. Instead one screen handles both modes based on whether a `HabitEntity` is passed to it:

```dart
AddEditHabitScreen(habit: null)    → ADD mode   (no habit passed)
AddEditHabitScreen(habit: entity)  → EDIT mode  (existing habit passed)
```

```dart
bool get _isEditMode => widget.habit != null;
```

`widget.habit` — accesses the widget's property from inside the State class. `widget` refers to the `ConsumerStatefulWidget` this state belongs to. If `habit` is not null, edit mode. If null, add mode. One boolean getter controls everything — AppBar title, button label, delete icon visibility.

---

## CONCEPT 2 — `ConsumerStatefulWidget` — Why Here

`HomeScreen` and `HabitCard` used `ConsumerWidget` because they had no local state. This screen needs local state:

- `TextEditingController` — holds and controls the text field value
- `_isSaving` — tracks whether a DB operation is in progress
- `_formKey` — manages form validation state

Whenever a widget needs local state AND Riverpod access, use `ConsumerStatefulWidget`.

```
No local state + Riverpod  →  ConsumerWidget
Local state + Riverpod     →  ConsumerStatefulWidget
Local state, no Riverpod   →  StatefulWidget
No local state, no Riverpod → StatelessWidget
```

---

## CONCEPT 3 — `TextEditingController`

Controls a text field programmatically. Initialized in `initState`:

```dart
@override
void initState() {
  super.initState();
  _nameController = TextEditingController(
    text: _isEditMode ? widget.habit!.name : '',
  );
}
```

In edit mode — pre-fills the field with the existing habit name so the user can see and modify it.
In add mode — starts empty.

Must be **disposed** in `dispose()` because controllers hold resources (memory, listeners). Not disposing causes memory leaks:

```dart
@override
void dispose() {
  _nameController.dispose();  // your cleanup first
  super.dispose();             // framework teardown last
}
```

### Why `super.initState()` First and `super.dispose()` Last

**`initState` — super first:**
`super.initState()` sets up Flutter framework internals — binding, lifecycle, element attachment. Your code depends on that infrastructure being ready. Framework boots up first, then you use it.

**`dispose` — super last:**
`super.dispose()` tears down the framework and detaches the widget from the tree. If called first, the framework is already gone when you try to clean up your own resources — can cause errors. You clean up your things first, then hand back control to the framework.

```
Moving into a house (initState):
1. Building installs electricity first  →  super.initState()
2. Then you bring your furniture in     →  your setup code

Moving out of a house (dispose):
1. You take your furniture out first    →  your cleanup code
2. Building shuts off electricity       →  super.dispose()
```

---

## CONCEPT 4 — `GlobalKey<FormState>` and Form Validation

```dart
final _formKey = GlobalKey<FormState>();
```

A `GlobalKey` gives you direct programmatic access to a widget's state from anywhere in the code. `FormState` is the internal state of the `Form` widget.

```dart
if (!_formKey.currentState!.validate()) return;
```

`.validate()` triggers every `validator` function inside the `Form`. If any validator returns a non-null string, that string is shown as an error below the field and `.validate()` returns `false`. If all validators return `null`, the form is valid and `.validate()` returns `true`.

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a habit name';  // shown as error
  }
  if (value.trim().length < 2) {
    return 'Habit name must be at least 2 characters';
  }
  return null;  // null means valid — no error shown
},
```

---

## CONCEPT 5 — `.trim()`

```dart
_nameController.text.trim()
```

Removes leading and trailing whitespace. Without this, a user could type spaces only — passes the `isEmpty` check but saves a blank habit name. `.trim()` ensures whitespace-only input is treated as empty.

Always `.trim()` user text input before saving to the database.

---

## CONCEPT 6 — `_isSaving` — Disable Button During Async Operation

```dart
bool _isSaving = false;

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);   // disable button, show spinner
  // ... DB operation
  setState(() => _isSaving = false);  // re-enable button
}
```

```dart
onPressed: _isSaving ? null : _save,
```

Passing `null` to `onPressed` **disables** the button completely. This prevents the user from tapping Save multiple times while the DB operation is in progress — which would insert duplicate habits.

The button label also changes during saving:

```dart
child: _isSaving
    ? CircularProgressIndicator(strokeWidth: 2)  // spinner while saving
    : Text(_isEditMode ? 'Save Changes' : 'Add Habit'),  // normal label
```

This gives the user visual feedback that something is happening.

---

## CONCEPT 7 — `mounted` Check After `await`

```dart
if (mounted) Navigator.pop(context);
```

After any `await`, the widget might have been disposed — the user could have navigated away while the save was in progress. Calling `Navigator.pop` on a disposed widget crashes the app.

`mounted` is a Flutter property that returns `true` if the widget is still in the widget tree, `false` if it has been disposed.

**Rule: Always check `mounted` before any UI operation after an `await`.**

```dart
Future<void> _save() async {
  // ...
  await repo.addHabit(...);  // async gap — widget could be disposed here
  // ...
  if (mounted) Navigator.pop(context);  // safe
}
```

---

## CONCEPT 8 — `showDialog` and Confirmation Pattern

```dart
final confirm = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Delete Habit'),
    content: const Text('This will permanently delete...'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx, false),  // Cancel → false
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(ctx, true),   // Delete → true
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
      ),
    ],
  ),
);

if (confirm != true) return;
```

`showDialog<bool>` returns a `Future<bool?>`. The value returned is whatever is passed to `Navigator.pop(ctx, value)` inside the dialog.

Three possible outcomes:
```
User taps Cancel    → confirm = false
User taps Delete    → confirm = true
User taps outside   → confirm = null (dialog dismissed)
```

`confirm != true` handles all three safely — only proceeds with deletion if the user explicitly tapped Delete. Cancel and outside-tap both result in no action.

---

## CONCEPT 9 — Passing Objects Between Routes with `arguments`

Named routes can only pass strings in the route name itself (like `/habit/3`). To pass a full object like `HabitEntity`, use `arguments`:

```dart
// Navigating with an object
Navigator.pushNamed(
  context,
  '/edit',
  arguments: habit,  // passes HabitEntity object
);
```

```dart
// Receiving in onGenerateRoute
if (settings.name == '/edit') {
  final habit = settings.arguments as HabitEntity;  // cast to expected type
  return MaterialPageRoute(
    builder: (_) => AddEditHabitScreen(habit: habit),
  );
}
```

`settings.arguments as HabitEntity` — casts the received object to `HabitEntity`. The `as` keyword forces a type cast. If the wrong type is passed, this throws a runtime error — so always ensure the correct type is passed at the call site.

---

## CONCEPT 10 — Why `onGenerateRoute` for Edit but Named Route for Add

```dart
routes: {
  '/add': (_) => const AddEditHabitScreen(),  // no arguments needed
},
onGenerateRoute: (settings) {
  if (settings.name == '/edit') {
    final habit = settings.arguments as HabitEntity;  // argument needed
    return MaterialPageRoute(builder: (_) => AddEditHabitScreen(habit: habit));
  }
},
```

`routes` map — for static routes where no data needs to be passed.

`onGenerateRoute` — for dynamic routes where data (arguments) needs to be received and processed before building the screen.

Add needs no data — uses named route.
Edit needs a `HabitEntity` — uses `onGenerateRoute` with `arguments`.

---

## CONCEPT 11 — `ref.invalidate` After Navigation

```dart
// In HabitCard onTap
onTap: () async {
  await Navigator.pushNamed(context, '/habit/${habit.id}');
  ref.invalidate(habitsProvider);  // refresh list when returning
},
```

After the user returns from the detail screen (which may have triggered an edit or delete), the habits list needs to refresh. `ref.invalidate` forces `habitsProvider` to refetch from the repository, rebuilding the list with the latest data.

---

## CONCEPT 12 — Delete is Only Accessible in Edit Mode

The delete icon only appears in the AppBar when in edit mode:

```dart
actions: [
  if (_isEditMode)
    IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: _delete,
    ),
],
```

`if (_isEditMode)` inside a list — a Dart collection `if`. Only includes the `IconButton` in the list when `_isEditMode` is true. Clean way to conditionally include widgets in a list without a ternary.

Delete is intentionally not accessible from the Add screen — you can only delete something that already exists.

---

## What Cannot Be Verified Yet in Day 6

The delete button and confirmation dialog exist in the code but **cannot be tested yet** because:

- Delete is only reachable via edit mode
- Edit mode is reached by navigating to `/edit` with a `HabitEntity`
- The edit button in `HabitDetailScreen` currently has an empty `onPressed`
- Full wiring of edit navigation happens in Day 8-9 when `HabitDetailScreen` is built

**What CAN be verified in Day 6:**

✅ Tapping `+` opens Add Habit screen with empty field
✅ Saving empty field shows validation error
✅ Saving whitespace-only input shows validation error
✅ Valid name saves, navigates back, new habit appears in list
✅ Tapping a habit card goes to detail screen
✅ Edit icon visible in detail screen AppBar (tapping does nothing yet)

---

## Next — Day 7: Settings Screen

The settings screen will have a theme toggle (System / Light / Dark) and placeholder sections for future Cloud Sync and AI Coach features.