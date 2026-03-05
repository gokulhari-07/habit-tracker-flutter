# Day 3 – Drift Data Models & Code Generation

## What Was Done Today
- Defined two Drift tables: `Habits` and `HabitCompletions`
- Registered both tables in `AppDatabase`
- Ran `build_runner` to generate Drift boilerplate
- Verified with a test insert and fetch

---

## Files Created Today

```
lib/
└── features/
    └── habits/
        └── data/
            └── tables/
                ├── habit_table.dart
                └── habit_completion_table.dart
```

`app_database.dart` was updated to register both tables.

---

## CONCEPT 1 — What is a Database Table?

A database table is exactly like a spreadsheet. Each row is one record. Each column is one piece of data about that record.

```
HABITS TABLE
┌────┬─────────────────┬─────────────────────┐
│ id │ name            │ createdAt           │
├────┼─────────────────┼─────────────────────┤
│ 1  │ Morning Walk    │ 2026-03-04 08:00:00 │
│ 2  │ Read 30 mins    │ 2026-03-04 09:00:00 │
│ 3  │ Drink Water     │ 2026-03-04 10:00:00 │
└────┴─────────────────┴─────────────────────┘

HABIT_COMPLETIONS TABLE
┌────┬─────────┬─────────────────────┬─────────────┐
│ id │ habitId │ date                │ isCompleted │
├────┼─────────┼─────────────────────┼─────────────┤
│ 1  │ 1       │ 2026-03-04 00:00:00 │ true        │
│ 2  │ 1       │ 2026-03-05 00:00:00 │ false       │
│ 3  │ 2       │ 2026-03-04 00:00:00 │ true        │
└────┴─────────┴─────────────────────┴─────────────┘
```

`habitId = 1` in the `HabitCompletions` table means that completion record **belongs to** the habit with `id = 1` (Morning Walk). This is how two tables talk to each other — one table references a row in another table using its `id`.

---

## CONCEPT 2 — What is Drift?

Without Drift, you write raw SQL manually to create tables:

```sql
CREATE TABLE habits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
```

This is error-prone. Typos cause crashes at runtime. No type safety in Dart. You have to manually map SQL results back to Dart objects.

**Drift solves all of this.** You write Dart classes instead:

```dart
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}
```

Drift reads this Dart class and **generates all the SQL for you** via `build_runner`. Everything is type-safe Dart. You never write SQL manually. Query results come back as proper Dart objects automatically.

---

## CONCEPT 3 — Drift Column Syntax Pattern

Every column definition in Drift follows this exact pattern:

```
ColumnType   get columnName   =>   type() . modifiers() ();
    ↑               ↑                 ↑          ↑       ↑
Return type    Column name      Start      Optional    Final ()
of the column  in the DB        building   constraints  REQUIRED.
                                the column             Builds and
                                                       returns the
                                                       column object.
                                                       Think of it
                                                       as .build()
```

The final `()` at the very end is **always required** on every single column. It is what actually builds and returns the finished column. Without it, the column is not created.

---

## CONCEPT 4 — Column Types

| Drift Type | Dart Type | Use For |
|------------|-----------|---------|
| `IntColumn` | `int` | Numbers, IDs, foreign keys |
| `TextColumn` | `String` | Names, labels, any text |
| `DateTimeColumn` | `DateTime` | Dates and times |
| `BoolColumn` | `bool` | True / false flags |

---

## CONCEPT 5 — `habit_table.dart` Line by Line

```dart
import 'package:drift/drift.dart';
```

Brings in the entire Drift library. Without this single import, nothing works — `Table`, `IntColumn`, `TextColumn`, `DateTimeColumn`, `autoIncrement`, `withLength` — none of these exist. This one line gives you everything needed to define a table.

---

```dart
class Habits extends Table {
```

You are creating a Dart class called `Habits`. By extending `Table`, you are telling Drift: **"This class is not a regular Dart class. It represents a database table."**

`Habits` is plural with a capital H — this is a Drift convention. Drift will automatically create a SQL table named `habits` (lowercase) from this class. You don't name the SQL table yourself.

---

```dart
IntColumn get id => integer().autoIncrement()();
```

Breaking this down piece by piece:

- `IntColumn` — the return type. You are declaring that this column stores integers.
- `get id` — the column name. In the database, this column will be called `id`.
- `=>` — Dart arrow function. Means "return what is on the right side."
- `integer()` — starts building an integer column.
- `.autoIncrement()` — this single modifier does **two things at once**:
  - Makes `id` the **Primary Key** — every row has a unique id, no two rows can have the same id
  - Makes it **auto-increment** — SQLite automatically assigns the next number (1, 2, 3...) every time you insert a row. You never set `id` manually.
- Final `()` — builds and returns the column.

**Full meaning:** Create an integer column called `id` that is the primary key and auto-increments.

---

```dart
TextColumn get name => text().withLength(min: 1, max: 200)();
```

- `TextColumn` — this column stores text (String in Dart).
- `get name` — column will be called `name` in the database.
- `text()` — starts building a text column.
- `.withLength(min: 1, max: 200)` — adds a validation constraint. The habit name must be at least 1 character long (cannot be empty) and at most 200 characters long. Drift enforces this at the database level.
- Final `()` — builds the column.

**Full meaning:** Create a text column called `name`, minimum 1 character, maximum 200 characters.

---

```dart
DateTimeColumn get createdAt => dateTime()();
```

- `DateTimeColumn` — this column stores a date and time.
- `get createdAt` — column name. Drift automatically converts `createdAt` (camelCase) to `created_at` (snake_case) in SQL. You don't do this manually.
- `dateTime()` — starts building a DateTime column. Important: Drift stores DateTime as a **Unix timestamp integer** internally in SQLite, but it always gives it back to you as a proper Dart `DateTime` object. You never deal with the raw number.
- Final `()` — builds the column.

**Full meaning:** Create a DateTime column called `createdAt`.

---

## CONCEPT 6 — `habit_completion_table.dart` Line by Line

```dart
import 'package:drift/drift.dart';
import 'habit_table.dart';
```

Two imports here. The second one — `habit_table.dart` — is needed because `HabitCompletions` needs to reference the `Habits` table for the foreign key. Without this import, Dart does not know what `Habits` is and the code will not compile.

---

```dart
class HabitCompletions extends Table {
```

Same pattern as before. Extends `Table` to tell Drift this is a database table. SQL table name will be `habit_completions`.

---

```dart
IntColumn get id => integer().autoIncrement()();
```

Every table needs its own primary key. This is `HabitCompletions`'s own unique id. Identical pattern to the `Habits` table. Same two things: primary key + auto-increment.

---

```dart
IntColumn get habitId => integer().references(Habits, #id)();
```

This is the **foreign key** — the most important line in this file.

- `IntColumn get habitId` — integer column called `habitId`.
- `integer()` — starts building an integer column.
- `.references(Habits, #id)` — this is the foreign key declaration. Breaking it further:
  - `Habits` — the table this column points to. This is why the import at the top was needed.
  - `#id` — this is a Dart **Symbol**. The `#` prefix means "I am referring to the name `id` as a symbol, not as a variable." It tells Drift: the specific column inside `Habits` that this links to is the `id` column.

What this foreign key enforces in the database:
- You **cannot** insert a completion record with a `habitId` that does not exist in the `Habits` table
- The database knows these two tables are related
- Protects data integrity — no orphan completion records

**Visual of the relationship:**
```
Habits table          HabitCompletions table
─────────────         ──────────────────────
id: 1          ←───── habitId: 1
id: 2          ←───── habitId: 2
```

---

```dart
DateTimeColumn get date => dateTime()();
```

Stores which **date** this completion record is for. Exact same pattern as `createdAt` in the Habits table.

---

```dart
BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
```

- `BoolColumn` — stores true or false.
- `boolean()` — starts building a boolean column.
- `.withDefault(const Constant(false))` — if you insert a row without specifying `isCompleted`, the database automatically sets it to `false`. You do not have to pass it every time.
- `const Constant(false)` — this is Drift's specific way of expressing a SQL default value. You wrap the Dart value inside `Constant()`. The `const` keyword makes it a compile-time constant, which Drift requires here.
- Final `()` — builds the column.

**Full meaning:** Create a boolean column called `isCompleted`, defaults to `false` if not provided on insert.

---

## CONCEPT 7 — Registering Tables in AppDatabase

```dart
// Day 2 — empty, no tables yet
@DriftDatabase(tables: [])

// Day 3 — both tables registered
@DriftDatabase(tables: [Habits, HabitCompletions])
```

`@DriftDatabase` is an **annotation**. In Dart, annotations starting with `@` give instructions to tools — not to the running app itself.

This annotation tells `build_runner`: **"When you generate code, include these two tables: `Habits` and `HabitCompletions`."**

The `AppDatabase` class itself does not change. What changes is that `build_runner` regenerates `_$AppDatabase` (the generated parent class) to now know about your two tables and generate all the query boilerplate for them.

---

## CONCEPT 8 — What Does `build_runner` Generate?

### Command to run
```bash
dart run build_runner build --delete-conflicting-outputs
```

`--delete-conflicting-outputs` safely overwrites the old generated file without errors.

### What Gets Generated inside `app_database.g.dart`

You never write any of these yourself. Drift creates them all from your table definitions:

| Generated Class | Purpose |
|----------------|---------|
| `HabitsTable` | Internal table class with SQL column definitions compiled |
| `HabitCompletionsTable` | Same for completions |
| `Habit` | Plain Dart object representing **one complete row** from the habits table. Used when reading data. |
| `HabitCompletion` | Plain Dart object representing **one complete row** from completions. Used when reading. |
| `HabitsCompanion` | Used for **inserts and updates** of habits. Partial row — no `id` needed. |
| `HabitCompletionsCompanion` | Used for **inserts and updates** of completions. |

### Why Two Classes? `Habit` vs `HabitsCompanion`

This is an important distinction:

`Habit` represents a **complete row** — all fields are present and required. This is what the database returns when you read data.

`HabitsCompanion` represents a **partial row** — used when writing data. You do not provide `id` because SQLite generates it automatically on insert.

```dart
// Habit — complete row. Returned when reading from DB. All fields present.
Habit(id: 1, name: 'Morning Walk', createdAt: DateTime(...))

// HabitsCompanion — partial row. Used for inserts. No id — SQLite sets it.
HabitsCompanion.insert(
  name: 'Morning Walk',
  createdAt: DateTime.now(),
)
```

---

## CONCEPT 9 — Insert Syntax Explained

```dart
final id = await db.into(db.habits).insert(
  HabitsCompanion.insert(
    name: 'Test Habit',
    createdAt: DateTime.now(),
  ),
);
```

Breaking every part down:

- `db.into(db.habits)` — "I want to insert INTO the habits table." `db.habits` is the generated table accessor that Drift created for you inside the generated file. You access every table through `db.tableName`.
- `.insert(...)` — performs the INSERT operation. Returns the `id` of the newly inserted row as an integer.
- `await` — you must await database operations because they are async. The database involves file I/O — reading and writing to the SQLite file on disk — which takes time.
- `HabitsCompanion.insert(...)` — the generated companion class used for inserts. You provide only the values you want to set. You do NOT provide `id` because SQLite auto-generates it.
- `name: 'Test Habit'` — sets the name column value.
- `createdAt: DateTime.now()` — sets the createdAt column to the current date and time.
- `final id` — stores the auto-generated id that SQLite assigned to this new row. In the test output this was `1`.

---

## CONCEPT 10 — Select Syntax Explained

```dart
final habits = await db.select(db.habits).get();
```

- `db.select(db.habits)` — "I want to SELECT from the habits table." This builds a SELECT query.
- `.get()` — executes the query and returns a `List<Habit>`. Every row in the table comes back as a `Habit` object — the generated data class.
- `await` — waits for the query to complete.
- `final habits` — stores the list of all habit rows returned.

---

## CONCEPT 11 — `initState` and Fire-and-Forget Pattern

```dart
@override
void initState() {
  super.initState();
  _testDatabase(); // No await here — intentional
}
```

- `initState()` is a Flutter lifecycle method. It runs **once**, right after the widget is first inserted into the widget tree — before the screen even renders. It is the correct place for one-time initialization logic.
- `super.initState()` — always call this first on the very first line. It runs the parent class's `initState` logic. Skipping this can break Flutter internals.
- `_testDatabase()` is called **without `await`** — this is intentional. This is called "fire and forget." The screen does not wait for the database test to finish before rendering. The UI shows up immediately. The database result prints to the console whenever it finishes in the background.

Why no await? Because `initState` is not async and cannot be made async in Flutter. If you need to wait, you use a `FutureBuilder` or a Riverpod async provider instead.

---

## CONCEPT 12 — `ref.read` vs `ref.watch`

In the test code:
```dart
final db = ref.read(databaseProvider);
```

- `ref.read` — one-time read. Gets the current value of the provider once. Does not subscribe to changes. Used inside functions, event handlers, and `initState`.
- `ref.watch` — subscribes to the provider. Widget rebuilds whenever the provider value changes. Used inside the `build` method only.

Rule of thumb: **`ref.watch` in `build`. `ref.read` everywhere else.**

---

## CONCEPT 13 — `print` and String Interpolation

```dart
print('Inserted habit with id: $id');
print('All habits: $habits');
```

- `print()` — outputs to the Flutter debug console. Only used for development/testing. Never left in production code.
- `$id` — Dart **string interpolation**. The `$` prefix inserts the runtime value of a variable directly into a string.
- When printing `$habits` (a `List<Habit>`), Dart automatically calls `.toString()` on every `Habit` object in the list. The generated `Habit` class has a `toString()` method that formats it readably for debugging.

---

## CONCEPT 14 — Complete Mental Model

```
Your Dart Table Classes  (Habits, HabitCompletions)
            ↓
    build_runner reads @DriftDatabase annotation
            ↓
    Generates SQL + Dart boilerplate  →  app_database.g.dart
            ↓
    AppDatabase registers the tables via @DriftDatabase
            ↓
    Riverpod provides AppDatabase to UI via databaseProvider
            ↓
    Screen calls  db.into().insert()  /  db.select().get()
            ↓
    Drift translates your Dart method calls → raw SQL
            ↓
    SQLite executes SQL on the habit_tracker.db file
            ↓
    Results returned as type-safe Dart objects (Habit, HabitCompletion)
```

You write clean Dart. Drift handles all the SQL translation. That is the entire value of the library.

---

## Day 3 Verification Output

```
I/flutter: Inserted habit with id: 1
I/flutter: All habits: [Habit(id: 1, name: Test Habit, createdAt: 2026-03-04 20:21:36.000)]
```

✅ Tables defined correctly  
✅ build_runner generated valid code  
✅ HabitsCompanion insert worked  
✅ Select returned a properly typed Dart object  
✅ Riverpod → AppDatabase → LazyDatabase → SQLite full chain verified  

---

## Next — Day 4: Repository Layer

The UI will **never call `db.select()` directly again** after Day 4. All database access moves behind a repository interface. This is the clean architecture boundary.

```
domain/ → habit_repository.dart       (abstract interface, pure Dart, no Drift)
data/   → drift_habit_repository.dart (Drift implementation of that interface)
```

---

---

# Understanding `app_database.g.dart` — The Generated Boilerplate

## First, the Most Important Thing to Understand

This file is **never written by you and never read by you during development**. It is 100% auto-generated by `build_runner` every time you run it. The only reason to open it is curiosity or debugging.

In an interview, you say:

> "This is generated code. I don't write or maintain it. I define the table structure in Dart, run `build_runner`, and Drift generates all the boilerplate automatically."

That alone is impressive. But understanding what's inside helps you answer follow-up questions confidently.

---

## What This File Contains — Big Picture

When you wrote your table class with 3 columns, Drift generated **5 things** for each table. Understanding these 5 things is all you need for any interview.

---

## The 5 Things Generated Per Table

### 1. `$HabitsTable` — The Internal SQL Table Class

This is the low-level class that holds the actual SQL column definitions. It is what Drift uses internally to talk to SQLite. You never call this yourself — Drift calls it internally.

Key things it does:

- Holds each column as a `GeneratedColumn` with its SQL type, constraints, and whether it is required on insert
- Has a `validateIntegrity()` method — before any insert or update, Drift calls this to check all constraints are satisfied. If `name` is missing on insert, it fails here before even touching the database
- Has a `map()` method — this converts a raw SQL result (which is just a `Map<String, dynamic>`) into a proper typed `Habit` Dart object. This is where `created_at` (SQL snake_case) becomes `createdAt` (Dart camelCase)

---

### 2. `Habit` — The Data Class (Read Model)

```dart
class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final DateTime createdAt;
}
```

This is a plain immutable Dart object representing **one complete row** from the habits table. This is what you get back when you read from the database.

It comes with several auto-generated methods that are important to know:

**`toString()`**
Formats the object readably. This is why your test printed `Habit(id: 1, name: Test Habit, ...)` so nicely in the console. You didn't write that format — Drift generated it.

**`copyWith()`**
Creates a modified copy without mutating the original. Since all fields in `Habit` are `final` (immutable), you cannot change them directly. `copyWith` lets you create a new `Habit` with specific fields changed while keeping the rest the same.

```dart
// Original
Habit(id: 1, name: 'Morning Walk', createdAt: ...)

// Modified copy — only name changed, everything else stays the same
habit.copyWith(name: 'Evening Walk')
```

This is used heavily in Riverpod state management where immutability is required.

**`==` and `hashCode`**
Two `Habit` objects with identical field values are considered equal. This is critical for Riverpod — it uses equality checks to decide whether state has actually changed and whether the UI needs to rebuild. Without this override, two objects with the same data would be treated as different because they are different instances in memory, causing unnecessary UI rebuilds.

**`toJson()` / `fromJson()`**
Serialization support. Not used in V1, but critical for V2 when you add cloud sync and need to send habit data over an API.

---

### 3. `HabitsCompanion` — The Write Model (Insert / Update)

```dart
HabitsCompanion.insert({
  this.id = const Value.absent(),  // Optional — SQLite generates it
  required String name,            // Required
  required DateTime createdAt,     // Required
})
```

This is used for **writing** to the database — inserts and updates.

The key concept here is `Value<T>` vs `Value.absent()`:

- `Value.absent()` means "do not include this field in the SQL query." For `id` on insert, this tells SQLite to generate the id automatically.
- `Value(someValue)` means "include this field with this specific value."

This distinction is what makes partial UPDATE queries possible. You can update just the `name` of a habit without touching `createdAt` — by passing `Value('New Name')` for name and `Value.absent()` for everything else. Drift builds a precise SQL query that only touches the columns you actually specified.

---

### 4. `_$AppDatabase` — The Generated Parent Class

```dart
abstract class _$AppDatabase extends GeneratedDatabase {
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(this);
}
```

This is the generated parent that your `AppDatabase` extends. It wires up the table accessors. This is where `db.habits` and `db.habitCompletions` come from — they are `late final` properties defined here.

`late final` means they are created only when first accessed, not at app startup. This is lazy initialization — the table accessor is only built when you actually use it for the first time.

---

### 5. `$AppDatabaseManager` and Table Managers — The Modern Query API

This is the newest part of the generated code. Drift generates a full Manager layer that gives you a fluent, type-safe query API as an alternative to the classic style.

```dart
// Classic style — what we use in V1
db.select(db.habits).get()

// Manager style — also valid, more fluent
db.managers.habits.get()
db.managers.habits.filter((f) => f.name.contains('Walk')).get()
```

Both work. Classic style is more explicit and easier to understand when learning. Manager style is more fluent and becomes more powerful in V2 when you have complex filtered queries. For V1 we use classic style.

---

## The camelCase → snake_case Conversion

Notice in the generated code, Drift automatically converts all your Dart camelCase names to SQL snake_case:

```
Your Dart name    →    SQL column name in the database
─────────────────      ───────────────────────────────
createdAt         →    created_at
habitId           →    habit_id
isCompleted       →    is_completed
```

You always use camelCase in Dart. Drift handles the translation to snake_case in SQL automatically everywhere. You never think about it or do it manually.

---

## How Drift Stores `bool` in SQLite

SQLite has **no native boolean type**. Drift handles this by:

- Storing `true` as `1` and `false` as `0`
- Adding a CHECK constraint: `CHECK ("is_completed" IN (0, 1))` — ensures only 0 or 1 can ever be stored
- Automatically converting between Dart `bool` and SQLite integer in both directions

You always work with `true`/`false` in your Dart code. You never see 0 or 1. Drift handles the conversion invisibly.

---

## Interview Questions This File Can Trigger

**Q: What is `build_runner` and why do you use it?**

> `build_runner` is a Dart code generation tool. Drift uses it to read your table definitions and generate all the SQL boilerplate, data classes, companions, and query APIs automatically. This eliminates manual SQL writing and ensures complete type safety throughout the data layer.

---

**Q: What is the difference between `Habit` and `HabitsCompanion`?**

> `Habit` is an immutable data class representing a complete row — used when reading from the database. `HabitsCompanion` is used for writes — inserts and updates. It uses `Value<T>` wrappers that allow fields to be absent, which lets Drift build precise SQL queries that only touch the columns you actually specify.

---

**Q: How does Drift handle type mapping between Dart and SQLite?**

> Drift handles all type conversions internally. `DateTime` is stored as a Unix timestamp integer. `bool` is stored as 0 or 1 with a CHECK constraint. `String` maps to TEXT. The generated `map()` method in each table class reads raw SQL results and converts them into typed Dart objects automatically.

---

**Q: What is `copyWith` and why does Drift generate it?**

> `copyWith` creates a modified copy of an immutable object without mutating the original. Since `Habit` is immutable — all fields are `final` — you use `copyWith` to create a new instance with specific fields changed while keeping the rest the same. This is important in Riverpod state management where immutability is required for change detection.

---

**Q: Why does the generated `Habit` class override `==` and `hashCode`?**

> So that two `Habit` objects with identical field values are considered equal. Riverpod and Flutter use equality checks to decide whether state has actually changed and whether the UI needs to rebuild. Without this override, two objects with the same data would be considered different because they are different instances in memory, causing unnecessary UI rebuilds.

---

**Q: What is `Value.absent()` in the Companion class?**

> `Value.absent()` tells Drift to exclude that field from the SQL query entirely. For `id` on insert, this means the field is not included in the INSERT statement so SQLite auto-generates it. For updates, it means only the fields with actual `Value(someValue)` are included in the UPDATE query — so you can update a single column without touching others.

---

## One-Line Summary for Interviews

> "Drift generates immutable data classes for reading, companion classes for writing, internal table classes for SQL mapping, and a type-safe query API — all from my simple Dart table definitions. I never write or maintain this file."