# Day 4 – Repository Layer & Clean Architecture Boundary

## What Was Done Today
- Created `HabitEntity` — pure Dart domain object
- Created `HabitRepository` — abstract interface (zero Drift, zero Flutter)
- Created `DriftHabitRepository` — Drift implementation of the interface
- Updated `database_provider.dart` — repository injected via Riverpod
- Verified repository returns `HabitEntity` type, not Drift's `Habit` type

---

## Files Created Today

```
lib/
└── features/
    └── habits/
        ├── domain/
        │   ├── entities/
        │   │   └── habit_entity.dart              ← NEW
        │   └── repositories/
        │       └── habit_repository.dart          ← NEW
        └── data/
            └── repositories/
                └── drift_habit_repository.dart    ← NEW

lib/core/database/
    └── database_provider.dart                     ← UPDATED
```

---

## Why This Day Exists — The Problem Without Repository

Before Day 4, the screen talked directly to the database:

```dart
// HomeScreen directly calling Drift — WRONG in clean architecture
db.select(db.habits).get()
db.into(db.habits).insert(...)
```

This means the UI knows Drift exists. If you ever switch to Firebase or a REST API in V2, you have to rewrite every screen. That is not scalable.

**The solution:**

```
Before Day 4:
HomeScreen → AppDatabase (Drift) → SQLite

After Day 4:
HomeScreen → HabitRepository (abstract) → DriftHabitRepository → SQLite
```

The UI now only talks to the abstract interface. It has no idea what is behind it.

---

## CONCEPT 1 — What is an Abstract Class?

### Real World Analogy

Imagine a **job description** for a "Driver":

```
Driver must be able to:
- start the vehicle
- stop the vehicle
- turn left / right
```

This job description does NOT say:
- what vehicle
- how to start it
- petrol or electric

It just defines **what a Driver must be capable of doing.**

Now you can have:
- A Car Driver — starts by turning a key
- A Bus Driver — starts by pressing a button
- An Auto Driver — starts by kick-starting

All three are "Drivers." All three fulfill the same contract. But **how** they do it is completely different.

This is exactly what an `abstract class` is in Dart.

---

### Abstract Class in Dart

```dart
abstract class Driver {
  void start();
  void stop();
}
```

- `abstract class` — this is the **job description**. Defines WHAT must be done.
- `void start()` — no body, no `{}`. Just the method signature. No implementation.
- You **cannot** do `Driver()` — you cannot create an instance of a job description. It is just a contract.

---

### `implements` in Dart

```dart
class CarDriver implements Driver {
  @override
  void start() {
    print('Turn the key');
  }

  @override
  void stop() {
    print('Press brake');
  }
}
```

- `implements Driver` — CarDriver is **promising** to fulfill the Driver contract.
- `@override` — you are providing the actual implementation of the method defined in the abstract class.
- If you forget to implement `stop()`, Dart gives a **compile-time error**. The contract is enforced before the app even runs.

```dart
class BusDriver implements Driver {
  @override
  void start() {
    print('Press the button');  // Completely different implementation
  }

  @override
  void stop() {
    print('Pull the lever');    // Completely different implementation
  }
}
```

Same contract. Completely different implementations. Both are valid Drivers.

---

### The Power — Dependency Inversion

```dart
void pickUpPassenger(Driver driver) {
  driver.start();
  // drive to destination
  driver.stop();
}
```

This function accepts **any** Driver — Car, Bus, Auto. It does not care which one. It just knows it can call `start()` and `stop()`.

```dart
pickUpPassenger(CarDriver());  // Works
pickUpPassenger(BusDriver());  // Works
```

If tomorrow you create `ElectricDriver`, this function still works without any changes. This is the **Dependency Inversion Principle** — depend on the abstract contract, not on the concrete implementation.

---

## CONCEPT 2 — Wiring the Abstract Class to Our Real Code

### Our Abstract Repository (Domain Layer)

```dart
abstract class HabitRepository {
  Future<List<HabitEntity>> getAllHabits();
  Future<int> addHabit(String name);
  Future<void> deleteHabit(int id);
  Future<void> updateHabit(int id, String name);
}
```

This is the **job description** for anything that wants to be a HabitRepository.

It says:
- You must be able to get all habits
- You must be able to add a habit
- You must be able to delete a habit
- You must be able to update a habit

It does NOT say how. No Drift. No SQL. No Firebase. Just the contract. This file has zero imports from Drift or Flutter — pure Dart only.

---

### Our Drift Implementation (Data Layer)

```dart
class DriftHabitRepository implements HabitRepository {
  final AppDatabase _db;

  DriftHabitRepository(this._db);

  @override
  Future<List<HabitEntity>> getAllHabits() async { ... }

  @override
  Future<int> addHabit(String name) async { ... }

  @override
  Future<void> deleteHabit(int id) async { ... }

  @override
  Future<void> updateHabit(int id, String name) async { ... }
}
```

`DriftHabitRepository` is the **Car Driver** version. It fulfills the contract using Drift and SQLite. Drift lives here and **only here**.

In V2, you will create:

```dart
class FirebaseHabitRepository implements HabitRepository {
  @override
  Future<List<HabitEntity>> getAllHabits() async {
    // uses Firebase — completely different engine, same contract
  }
}
```

`FirebaseHabitRepository` is the **Bus Driver** version. Same contract. Different engine. The UI never changes.

---

### Our Riverpod Provider

```dart
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftHabitRepository(db);
});
```

The return type is `Provider<HabitRepository>` — the **abstract interface**, not `DriftHabitRepository`.

So when HomeScreen does:

```dart
final repo = ref.read(habitRepositoryProvider);
repo.getAllHabits();
```

HomeScreen only sees `HabitRepository`. It has no idea `DriftHabitRepository` or Drift even exists.

**Swapping V1 → V2 is just one line:**

```dart
// V1
return DriftHabitRepository(db);

// V2 — one line change, nothing else in the entire app changes
return FirebaseHabitRepository(firestore);
```

---

## CONCEPT 3 — `HabitEntity` — Why It Exists

```dart
class HabitEntity {
  final int id;
  final String name;
  final DateTime createdAt;

  const HabitEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
```

This is a **pure Dart object**. No Drift import. No Flutter import.

Drift generates its own `Habit` data class. But that class belongs to the **data layer** — it has Drift-specific methods and knowledge baked into it.

The domain layer and UI layer should never touch Drift objects. So we create `HabitEntity` — a clean, simple Dart class that represents a habit in the domain world.

The mapping happens inside `DriftHabitRepository`:

```dart
// Drift returns List<Habit> (data layer object)
final habits = await _db.select(_db.habits).get();

// We map each Habit → HabitEntity (domain layer object)
return habits.map((habit) => HabitEntity(
  id: habit.id,
  name: habit.name,
  createdAt: habit.createdAt,
)).toList();
```

```
Drift world (data layer)      Domain world (domain + UI layer)
────────────────────────      ────────────────────────────────
Habit                    →    HabitEntity
habit.id                 →    id: habit.id
habit.name               →    name: habit.name
habit.createdAt          →    createdAt: habit.createdAt
```

After this mapping, the data layer has done its job. Clean `HabitEntity` objects travel upward. The UI never sees Drift.

---

## CONCEPT 4 — Cascade Notation `..`

### Simple Example First

```dart
class Person {
  String name = '';
  int age = 0;

  void setName(String n) { name = n; }
  void setAge(int a) { age = a; }
  void greet() { print('Hi I am $name'); }
}

// Without cascade — repeating the variable name every time
Person p = Person();
p.setName('Gokulhari');
p.setAge(25);
p.greet();

// With cascade — same result, cleaner
Person p = Person()
  ..setName('Gokulhari')
  ..setAge(25)
  ..greet();
```

The `..` means: **"call this method on the same object I was already working with."** You don't repeat the variable name. The object is the same throughout.

---

### Wired to Our Delete Code

```dart
await (_db.delete(_db.habits)
  ..where((t) => t.id.equals(id)))
  .go();
```

Step by step:

- `_db.delete(_db.habits)` — creates a delete statement object targeting the habits table. Just building, no DB touched yet.
- `..where((t) => t.id.equals(id))` — the `..` means: on the **same delete statement object**, call `where()`. Adds the condition "only delete rows where id matches." Still just building, no DB touched.
- `.go()` — executes the DELETE SQL on the database. This is the only async step.

Without cascade — verbose form:

```dart
final deleteStatement = _db.delete(_db.habits);
deleteStatement.where((t) => t.id.equals(id));
await deleteStatement.go();
```

With cascade — clean form:

```dart
await (_db.delete(_db.habits)
  ..where((t) => t.id.equals(id)))
  .go();
```

Same result. Cascade is just cleaner syntax.

**SQL translation:**
```sql
DELETE FROM habits WHERE id = 5;
```

---

### Wired to Our Update Code

```dart
await (_db.update(_db.habits)
  ..where((t) => t.id.equals(id)))
  .write(HabitsCompanion(name: Value(name)));
```

- `_db.update(_db.habits)` — creates an update statement object.
- `..where((t) => t.id.equals(id))` — same cascade, adds the WHERE condition on the same object.
- `.write(HabitsCompanion(name: Value(name)))` — executes the UPDATE with only the `name` field. `createdAt` and `id` are `Value.absent()` by default, so they are NOT included in the SQL.

**SQL translation:**
```sql
UPDATE habits SET name = 'New Name' WHERE id = 5;
```

Only `name` is updated. `createdAt` is completely untouched.

---

## CONCEPT 5 — The `await` Doubt Clarified

This was your doubt: in the verbose delete form, why is `await` only on the third line `.go()` and not on `.where()`?

```dart
final deleteStatement = _db.delete(_db.habits);  // No await
deleteStatement.where((t) => t.id.equals(id));   // No await
await deleteStatement.go();                       // await HERE only
```

The reason:

- `_db.delete(_db.habits)` — just creates a query object **in memory**. No database involved. No file I/O. No async work. So no `await`.
- `.where(...)` — just **adds a condition to the query object in memory**. Still no database involved. No file I/O. No async work. So no `await`.
- `.go()` — this is the only line that actually **goes to the SQLite file on disk, executes SQL, and waits for the result**. File I/O is async. So `await` is required here.

Think of it this way:

```
_db.delete(_db.habits)           →  "I want to delete from habits"     — memory only, instant
..where((t) => t.id.equals(id)) →  "only where id matches"            — memory only, instant
.go()                            →  "NOW execute this on the database" — file I/O, async, needs await
```

The same logic applies in the cascade form. The `await` wraps the entire expression but it is effectively waiting for `.go()` — the only thing that is actually async.

```dart
await (_db.delete(_db.habits)   // building — not async
  ..where(...))                 // building — not async
  .go();                        // executing — async, this is what await is for
```

---

## CONCEPT 6 — Drift Execution Methods

These are Drift-specific methods that **execute** the built SQL query. Think of it as a two-step process:

```
Step 1 — Build the query    →   db.select() / db.delete() / db.update()
Step 2 — Execute the query  →   .get()      / .go()       / .write()
```

| Drift Method | Used With | What It Does | Returns |
|-------------|-----------|-------------|---------|
| `.get()` | `select` | Executes SELECT, fetches all matching rows | `List<T>` |
| `.getSingle()` | `select` | Executes SELECT, expects exactly one row | `T` |
| `.go()` | `delete` | Executes DELETE | number of rows deleted |
| `.write()` | `update` | Executes UPDATE with given values | number of rows updated |

None of these are standard Dart. They are all **Drift-specific methods** defined inside the Drift library. They are available through the query builder objects that `db.select()`, `db.delete()`, and `db.update()` return.

**Analogy:** Building a query is like writing a letter. `.go()` / `.get()` / `.write()` is putting the letter in the mailbox. The letter is not sent until you put it in the mailbox.

---

## CONCEPT 7 — Complete Architecture Flow

```
HomeScreen
    ↓  ref.read(habitRepositoryProvider)
    ↓  sees only HabitRepository (abstract)
    ↓
HabitRepository  ← abstract interface, pure Dart, no Drift
    ↓  implemented by
DriftHabitRepository  ← Drift lives here and ONLY here
    ↓  calls
AppDatabase (Drift)
    ↓
LazyDatabase
    ↓
SQLite file (habit_tracker.db)

Data flows back up:
SQLite row → Drift Habit object → mapped to HabitEntity → returned to HomeScreen
```

Every layer only knows about the layer directly below it through the abstract interface. Nothing leaks upward. Drift is completely contained in the data layer.

---

## CONCEPT 8 — Layer Responsibilities After Day 4

| Layer | What It Contains | What It Must NOT Contain |
|-------|-----------------|--------------------------|
| Domain | `HabitEntity`, `HabitRepository` (abstract) | Drift, Flutter, Firebase |
| Data | `DriftHabitRepository`, Drift tables | UI logic, business rules |
| Presentation | Screens, Riverpod providers | `db.select()`, Drift imports |

---

## Day 4 Verification Output

```
I/flutter: Added habit with id: 2
I/flutter: All habits: [Instance of 'HabitEntity', Instance of 'HabitEntity']
I/flutter: First habit name: Test Habit
I/flutter: First habit type: HabitEntity
```

The critical line is `First habit type: HabitEntity` — **not** `Habit`.

This proves:
- The data layer correctly maps Drift `Habit` objects to domain `HabitEntity` objects
- The UI received a clean domain object with zero Drift knowledge
- The architecture boundary is working correctly

✅ Abstract repository contract defined  
✅ Drift implementation fulfills the contract  
✅ Riverpod injects `HabitRepository` type, not `DriftHabitRepository`  
✅ Mapping from `Habit` → `HabitEntity` works correctly  
✅ UI has zero Drift imports or knowledge  

---

## Next — Day 5: Home Screen Functional

The home screen will now use `habitRepositoryProvider` to fetch and display real habits from the database, toggle completion, and show streaks.