import 'dart:io'; //Needed because: We create a File. SQLite stores data in a file
import 'package:drift/drift.dart'; //Core Drift API: @DriftDatabase, GeneratedDatabase, QueryExecutor etc.
import 'package:drift/native.dart'; // This gives us:NativeDatabase(file). Meaning: Use SQLite on mobile (Android/iOS). If this was web → different implementation.
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'app_database.g.dart';

@DriftDatabase(tables: []) //this line tells drift the below class represents a database. tables:[] means currently no tables yet. 
class AppDatabase extends _$AppDatabase {
//   _$AppDatabase is generated code.
// Your class extends it.
// Why?
// Because:
// Generated code contains internal logic
// You provide configuration
// Drift combines both

  AppDatabase() : super(_openConnection()); //?? explain in detail here whts parnt constructor. WHts the purpose of super? explain evrything..


  @override
  int get schemaVersion => 1;
// This controls:
// Database migrations

// If later you change schema:
// int get schemaVersion => 2;

// Drift knows:
// DB structure changed
// Run migration logic
// This is production-level database versioning.
}

LazyDatabase _openConnection() {
// Why LazyDatabase?
// It delays DB creation until first use.
// Better performance.
// Cleaner startup.
print("Opening SQLite database..."); //for testing purpose to check database opened or not
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory(); //Safe folder inside phone storage to store DB file. This gets: /data/user/0/com.app.package/files/. Safe internal storage.
    final file = File(p.join(dir.path, 'habit_tracker.db')); // This line creates habit_tracker.db file. THis is our sqlite file. If app is deleted → file deleted. p.join used to safely join paths. Because: Windows uses \. Android uses /. This avoids platform bugs.
    return NativeDatabase(file); //This tells Drift: Use SQLite engine with this file.
  });
}

/* DRIFT DATABASE CORE CONCEPTS – REVISION NOTES

---

## 1️⃣  AppDatabase() : super(_openConnection());

• AppDatabase extends _$AppDatabase (generated class by Drift).
• The generated parent class requires a QueryExecutor (database engine).
• super() calls the parent constructor.
• We pass _openConnection() to give Drift the SQLite connection.

Without super(_openConnection()):

* No database engine is provided.
* Drift cannot execute queries.
* App will not work.

🔎 EXACT SIMPLE EXAMPLE OF super():

class Parent {
Parent(int value) {
print("Parent received: $value");
}
}

class Child extends Parent {
Child() : super(10);
}

void main() {
Child();
}

Output:
Parent received: 10

Explanation:
• Child extends Parent.
• Parent constructor requires an int.
• Child MUST call super(10) to give that value.
• Parent constructor runs first.

Now relate this to Drift:

class _$AppDatabase extends GeneratedDatabase {
_$AppDatabase(QueryExecutor e) : super(e);
}

class AppDatabase extends _$AppDatabase {
AppDatabase() : super(_openConnection());
}

Here:
• Parent requires QueryExecutor.
• _openConnection() returns QueryExecutor.
• super(_openConnection()) passes the engine to Drift.

---

## 2️⃣  What is QueryExecutor?

QueryExecutor = The database engine that runs SQL.

Examples:

* NativeDatabase (mobile)
* LazyDatabase (delayed mobile)
* WebDatabase (web)

Drift needs this engine to execute queries.

---

## 3️⃣  Why use LazyDatabase?

We cannot make constructors async in Dart.

Wrong ❌:
AppDatabase() async {}

Correct approach:
Wrap async work inside LazyDatabase.

LazyDatabase(() async {
// async operations
return NativeDatabase(file);
});

LazyDatabase delays opening the database
until the FIRST query runs.

---

## 4️⃣  When is SQLite actually opened?

Step 1: AppDatabase() created
Step 2: Parent constructor called
Step 3: LazyDatabase created
Step 4: SQLite NOT opened yet
Step 5: First query executed
Step 6: LazyDatabase runs async function
Step 7: SQLite file opened

So SQLite opens ONLY during first query.

---

## 5️⃣  Why is this production grade?

• Improves startup performance
• Avoids blocking UI thread
• Clean separation of concerns
• Works with async file system
• Scalable for migrations

---

Mental Model:

UI
↓
Repository
↓
AppDatabase
↓
LazyDatabase
↓
NativeDatabase (SQLite engine)
↓
habit_tracker.db file

---

Key Takeaway:
super() = Give Drift the engine.
LazyDatabase = Delay opening DB.
SQLite opens at first query.

---
*/