================================================================================
HABITCLOUDMODEL — COMPLETE REVISION NOTES
================================================================================

GOAL OF THIS DOCUMENT

After reading this document, I should understand:

✓ Why HabitCloudModel exists
✓ Why HabitEntity alone is not enough
✓ Difference between Entity and CloudModel
✓ How Firestore stores data
✓ What serialization means
✓ What deserialization means
✓ What factory constructors are
✓ What fromEntity() does
✓ What toEntity() does
✓ What toJson() does
✓ What fromJson() does
✓ Complete upload flow
✓ Complete download flow

================================================================================
THE PROBLEM WE ARE TRYING TO SOLVE
================================================================================

Current architecture already has:

HabitEntity

and

HabitTable

So naturally the question is:

"Why do we need HabitCloudModel?"

To understand that, first understand what Firestore stores.

================================================================================
HOW FIRESTORE STORES DATA
================================================================================

Firestore does NOT understand:

HabitEntity

Firestore does NOT understand:

HabitCloudModel

Firestore only understands:

Map<String, dynamic>

Example:

{
  "id": 1,
  "name": "Gym",
  "createdAt": "2026-06-03T10:30:00.000Z"
}

This structure is called:

Map<String, dynamic>

Firestore stores documents in this format.

================================================================================
CURRENT LAYERS IN OUR APP
================================================================================

We currently have:

HabitTable
↓
SQLite Layer

HabitEntity
↓
Domain Layer

Now we are adding:

HabitCloudModel
↓
Firestore Layer

================================================================================
WHAT IS HABITTABLE?
================================================================================

Purpose:

Defines SQLite database structure.

Example:

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

Used by:

Drift

Purpose:

Create SQLite tables.

HabitTable should know:

✓ SQLite

HabitTable should NOT know:

✗ Firestore
✗ JSON
✗ Business Logic

================================================================================
WHAT IS HABITENTITY?
================================================================================

Purpose:

Business Object

Example:

HabitEntity(
  id: 1,
  name: 'Gym',
)

Used by:

✓ Controllers
✓ Repositories
✓ UI
✓ Domain Layer

HabitEntity should know:

✓ Business data

HabitEntity should NOT know:

✗ Firestore
✗ SQLite
✗ JSON
✗ API details

================================================================================
WHAT IS HABITCLOUDMODEL?
================================================================================

Purpose:

Acts as translator between:

HabitEntity

and

Firestore

Visual:

HabitEntity
↕
HabitCloudModel
↕
Firestore

================================================================================
WHY NOT ADD JSON METHODS INSIDE ENTITY?
================================================================================

Many beginners do:

class HabitEntity {
  Map<String,dynamic> toJson()
}

Looks easier.

But this breaks:

Separation Of Concerns

Entity belongs to:

Domain Layer

Firestore belongs to:

Data Layer

Entity should not know anything about Firestore.

Therefore:

HabitCloudModel is introduced.

================================================================================
CURRENT HABITCLOUDMODEL
================================================================================

class HabitCloudModel {
  final int id;
  final String name;
  final DateTime createdAt;

  const HabitCloudModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}

At first glance it looks almost identical to HabitEntity.

This is normal.

The difference is:

HabitEntity
↓
Business Layer

HabitCloudModel
↓
Firestore Layer

Different responsibility.

================================================================================
FUNCTION 1
fromEntity()
================================================================================

Code:

factory HabitCloudModel.fromEntity(
  HabitEntity habit,
)

Purpose:

Convert:

HabitEntity
↓
HabitCloudModel

================================================================================
WHAT IS A FACTORY CONSTRUCTOR?
================================================================================

Normal Constructor:

HabitCloudModel(
  id: 1,
  name: 'Gym',
)

Creates object from raw values.

Factory Constructor:

HabitCloudModel.fromEntity(habit)

Creates object from another object.

Purpose:

Object Transformation

================================================================================
INPUT
================================================================================

Receives:

HabitEntity

Example:

HabitEntity(
  id: 1,
  name: 'Gym',
  createdAt: today,
)

================================================================================
OUTPUT
================================================================================

Returns:

HabitCloudModel(
  id: 1,
  name: 'Gym',
  createdAt: today,
)

================================================================================
CODE BREAKDOWN
================================================================================

factory HabitCloudModel.fromEntity(
  HabitEntity habit,
)

Receives entity.

-------------------------------------------------------------------------------

return HabitCloudModel(

Creates CloudModel.

-------------------------------------------------------------------------------

id: habit.id,

Copies id.

-------------------------------------------------------------------------------

name: habit.name,

Copies name.

-------------------------------------------------------------------------------

createdAt: habit.createdAt,

Copies date.

-------------------------------------------------------------------------------

Result:

HabitEntity
↓
HabitCloudModel

================================================================================
FUNCTION 2
toEntity()
================================================================================

Code:

HabitEntity toEntity()

Purpose:

Convert:

HabitCloudModel
↓
HabitEntity

================================================================================
WHY IS THIS NEEDED?
================================================================================

Firestore layer understands:

HabitCloudModel

UI understands:

HabitEntity

Therefore conversion is required.

================================================================================
EXAMPLE
================================================================================

Before:

HabitCloudModel(
  id: 1,
  name: 'Gym',
)

After:

HabitEntity(
  id: 1,
  name: 'Gym',
)

================================================================================
VISUAL FLOW
================================================================================

Firestore
↓
CloudModel
↓
toEntity()
↓
HabitEntity
↓
UI

================================================================================
FUNCTION 3
toJson()
================================================================================

Code:

Map<String,dynamic> toJson()

Most important function in this file.

================================================================================
PURPOSE
================================================================================

Convert:

HabitCloudModel
↓
Map<String,dynamic>

Firestore stores:

Map<String,dynamic>

Therefore upload requires this conversion.

================================================================================
EXAMPLE
================================================================================

Before:

HabitCloudModel(
  id: 1,
  name: 'Gym',
)

After:

{
  'id': 1,
  'name': 'Gym',
  'createdAt': ...
}

This map is exactly what Firestore stores.

================================================================================
CODE BREAKDOWN
================================================================================

return {

Creates Map.

-------------------------------------------------------------------------------

'id': id,

Stores id.

-------------------------------------------------------------------------------

'name': name,

Stores name.

-------------------------------------------------------------------------------

'createdAt': createdAt.toIso8601String(),

Stores date.

================================================================================
WHY toIso8601String()?
================================================================================

DateTime is a Dart object.

Firestore cannot directly store Dart objects.

Need String format.

Example:

Before:

DateTime(2026,6,3)

After:

2026-06-03T10:30:00.000Z

This standard format is called:

ISO 8601

Used worldwide.

================================================================================
FUNCTION 4
fromJson()
================================================================================

Code:

factory HabitCloudModel.fromJson(
  Map<String,dynamic> json,
)

Purpose:

Convert:

Firestore Data
↓
HabitCloudModel

================================================================================
WHY IS THIS NEEDED?
================================================================================

Firestore returns:

Map<String,dynamic>

But app code should work with objects.

Therefore:

Map
↓
Object

conversion required.

================================================================================
EXAMPLE
================================================================================

Firestore returns:

{
  'id': 1,
  'name': 'Gym',
  'createdAt':
      '2026-06-03T10:30:00.000Z'
}

After conversion:

HabitCloudModel(
  id: 1,
  name: 'Gym',
  createdAt: ...
)

================================================================================
CODE BREAKDOWN
================================================================================

id: json['id'] as int

Read id from map.

-------------------------------------------------------------------------------

name: json['name'] as String

Read name from map.

-------------------------------------------------------------------------------

createdAt:
    DateTime.parse(
      json['createdAt'] as String,
    )

Convert String
↓
DateTime

================================================================================
WHY DateTime.parse()?
================================================================================

Firestore returns:

String

Example:

2026-06-03T10:30:00.000Z

App wants:

DateTime

DateTime.parse()

performs conversion.

================================================================================
COMPLETE UPLOAD FLOW
================================================================================

User creates habit

↓

HabitEntity

↓

HabitCloudModel.fromEntity()

↓

HabitCloudModel

↓

toJson()

↓

Map<String,dynamic>

↓

Firestore

================================================================================
COMPLETE DOWNLOAD FLOW
================================================================================

Firestore

↓

Map<String,dynamic>

↓

HabitCloudModel.fromJson()

↓

HabitCloudModel

↓

toEntity()

↓

HabitEntity

↓

UI

================================================================================
SEPARATION OF RESPONSIBILITIES
================================================================================

HabitTable
↓
SQLite Structure

HabitEntity
↓
Business Object

HabitCloudModel
↓
Firestore Translation Layer

Each class has ONE responsibility.

This follows:

Separation Of Concerns

and

Clean Architecture

================================================================================
INTERVIEW ANSWER
================================================================================

Question:

Why create HabitCloudModel when HabitEntity already exists?

Answer:

HabitEntity belongs to the domain layer and should remain independent of external data sources. HabitCloudModel acts as a mapper between Firestore documents and domain entities, allowing Firestore serialization and deserialization without polluting the domain layer with persistence-related logic. This maintains separation of concerns and follows Clean Architecture principles.

================================================================================
KEY TAKEAWAYS
================================================================================

✓ Firestore stores Map<String,dynamic>

✓ HabitEntity is a business object

✓ HabitCloudModel is a Firestore translation layer

✓ fromEntity() converts Entity → CloudModel

✓ toEntity() converts CloudModel → Entity

✓ toJson() converts CloudModel → Firestore Map

✓ fromJson() converts Firestore Map → CloudModel

✓ HabitCloudModel prevents Firestore logic from leaking into Domain Layer

✓ This follows Separation of Concerns and Clean Architecture
================================================================================