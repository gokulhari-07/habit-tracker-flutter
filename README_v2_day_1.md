# Onward — Refactor Day 1

## Context
- V1 successfully shipped to Play Store
- Closed testing ongoing
- Started refactoring before V2 development
- Goal = prepare architecture for scalable AI + cloud features

---

# Problems Identified

## 1. UI Handling Business Logic ❌

Current UI directly:
- calls repository
- mutates DB
- invalidates providers

Example:

```dart
await repo.toggleCompletion(...)
ref.invalidate(...)
```

Problem:
- tightly coupled UI
- poor scalability
- hard to maintain
- hard to support sync/AI later

Future fix:
- introduce AsyncNotifier
- create HabitController
- move mutations out of UI

Target architecture:

```text
UI → Controller → Repository → DB
```

---

## 2. Overuse of ref.invalidate ❌

Current architecture manually refreshes state everywhere.

Problem:
- unnecessary rebuilds
- inefficient updates
- poor scalability

Future:
controller-driven state management.

---

# Database Integrity Fix Done ✅

## Problem
Duplicate completion rows were possible for same:
- habitId
- date

Example:

| habitId | date |
|---|---|
| 1 | 2026-05-20 |
| 1 | 2026-05-20 ❌ |

This could break:
- streaks
- analytics
- future sync logic

---

# Fix Added ✅

Inside:
habit_completion_table.dart

Added:

```dart
@override
List<Set<Column>> get uniqueKeys => [
  {habitId, date},
];
```

Meaning:
One habit can only have ONE completion row per day.

This is called:
COMPOSITE UNIQUE CONSTRAINT.

---

# Learned About @override 🧠

Drift already defines:

```dart
uniqueKeys
```

We override framework behavior using:

```dart
@override
```

Important:
Framework method/property names must EXACTLY match.

Wrong:

```dart
myUniqueKeys
```

Drift ignores it completely.

---

# Schema Versioning Learned 🧠

Changed:

```dart
schemaVersion => 1
```

to:

```dart
schemaVersion => 2
```

Reason:
Database structure changed.

Rule:
Whenever DB structure changes:
- columns
- constraints
- indexes
- tables

➡ increase schemaVersion.

---

# Date Normalization Learned 🧠

These are DIFFERENT timestamps:

```text
2026-05-20 00:00:00
2026-05-20 14:37:22
```

Even though humans see same date.

Without normalization:
- duplicate rows possible
- equality checks fail

---

# Repository Normalization Added ✅

Inside:
toggleCompletion()

Added:

```dart
final normalizedDate = DateTime(
  date.year,
  date.month,
  date.day,
);
```

Repository now guarantees consistent dates.

Important principle:
❌ UI should not enforce DB consistency
✅ Repository layer should enforce consistency

---

# Important Engineering Concepts Learned

- Data Integrity
- Composite Unique Constraints
- Schema Versioning
- Framework Overrides
- Defensive Programming
- Data Normalization
- Separation of Concerns

---

# Current Status

✅ unique constraint added  
✅ schemaVersion updated to 2  
✅ build_runner regenerated  
✅ repository normalization added  
✅ DB recreated via reinstall  
✅ app tested successfully  

---

# Next Refactor Plan

## BIG GOAL:
Remove business logic from UI.

Planned:
- AsyncNotifier
- HabitController
- remove ref.invalidate spam
- scalable Riverpod architecture

Future architecture:

```text
UI → Controller → Repository → DB
```