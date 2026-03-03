/*
FEATURE-BASED CLEAN ARCHITECTURE – REVISION NOTES

1️⃣ What is Feature-Based Structure?

Instead of organizing the project globally by type (models/, screens/, providers/),
we organize by feature:

lib/
 ├── core/
 ├── features/
 │     └── habits/
 │          ├── data/
 │          ├── domain/
 │          ├── presentation/

Each feature is self-contained and modular.


2️⃣ Why Feature-Based Structure is Better

• Improves scalability — new features can be added without affecting existing ones.
• Prevents global folder clutter (avoids “God folders”).
• Reduces tight coupling between unrelated parts of the app.
• Makes codebase easier to navigate.
• Improves team collaboration (multiple developers can work on separate features).
• Supports future refactoring without large-scale rewrites.


3️⃣ Layer Responsibilities

🔹 Presentation Layer
- Contains UI (screens, widgets)
- Contains state management (Riverpod providers)
- Handles user interactions
- Calls domain layer
- Should NOT contain database logic

🔹 Domain Layer
- Contains business logic
- Contains pure Dart entities
- Contains core rules (e.g., streak calculation logic)
- Independent of Flutter and database
- Does NOT depend on Isar, Firebase, or UI

🔹 Data Layer
- Contains database models
- Contains repository implementations
- Handles Isar configuration
- Handles API calls (future cloud sync)
- Communicates with domain layer


4️⃣ Why Domain Must Not Depend on Isar

If business logic directly depends on Isar:
- The system becomes tightly coupled.
- Replacing Isar with Firebase or REST API becomes difficult.
- Violates Dependency Inversion Principle.
- Makes testing harder.

Keeping domain independent:
- Allows easy data source switching.
- Improves testability.
- Improves long-term maintainability.
- Makes architecture flexible and future-proof.


Summary:
“I used feature-based clean architecture to isolate features into independent modules.
Each feature has presentation, domain, and data layers.
The domain layer is framework-independent and contains pure business logic.
The data layer implements storage logic (Isar in v1, cloud sync in v2).
This allows us to scale features independently and swap data sources without modifying core logic.”
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/app.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  /*WIDGETSFLUTTERBINDING.ENSUREINITIALIZED() – COMPLETE EXPLANATION

1️⃣ What is WidgetsFlutterBinding?

WidgetsFlutterBinding is the glue between:

• Flutter framework (widgets, rendering system)
• Flutter engine
• Platform services (Android/iOS system APIs)

It initializes:
• Rendering system
• Scheduler
• Gesture system
• Platform channels
• Plugin communication

It connects Flutter to the underlying platform.


2️⃣ What does ensureInitialized() do?

WidgetsFlutterBinding.ensureInitialized() ensures that the Flutter engine and platform channels are fully initialized before any Flutter-dependent code runs.

Think of it as:

“Make sure the Flutter engine is ready before executing async setup code.”


3️⃣ Why is it needed?

Normally, when you call:

runApp(MyApp());

Flutter automatically initializes the binding.

So in very simple apps, you don’t need ensureInitialized().

BUT —

If you execute async platform-dependent code BEFORE runApp(),
you must initialize the binding manually.


4️⃣ When is ensureInitialized() REQUIRED?

You must use it if you do any of the following before runApp():

• Initializing a database (Isar, Hive, Drift)
• Using path_provider
• Initializing Firebase
• Using SharedPreferences
• Accessing platform channels
• Any plugin that communicates with native Android/iOS code


5️⃣ What happens if you don’t use it?

You may get runtime errors like:

“Binding has not yet been initialized”
or
“ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.”

This happens because platform services were accessed before Flutter engine setup was complete.


6️⃣ Example – Correct Usage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  await Isar.open(...);

  runApp(const ProviderScope(child: MyApp()));
}

Here, ensureInitialized() guarantees the engine is ready before database initialization.


7️⃣ Analogy

ensureInitialized() is like turning on the car engine before driving.
If you try to drive before turning the engine on, the system fails.


8️⃣ Interview-Level Explanation

“If asynchronous initialization such as database setup or Firebase configuration is required before runApp(), we must call WidgetsFlutterBinding.ensureInitialized() to ensure that the Flutter engine and platform channels are fully initialized. Otherwise, accessing platform services before binding initialization can cause runtime errors.”


9️⃣ Key Takeaway

• Not required for simple apps.
• Required when performing async setup before runApp().
• Prevents platform channel initialization errors.
• Important for production-level app startup. */

/*DATABASE INITIALIZATION & ensureInitialized() – SHORT REVISION NOTES

1️⃣ Why Initialize Database Before runApp()?

Initializing the database before runApp() is considered a production-grade approach because:

• Infrastructure setup happens before UI starts.
• The app launches with all dependencies ready.
• Avoids loading spinners on first screen.
• Centralizes startup error handling.
• Keeps infrastructure separate from UI.
• Follows clean architecture principles.
• Improves perceived startup performance.

In short:
Bootstrap first → UI later.


2️⃣ Why NOT Initialize Database Inside Screens?

If DB is initialized inside a screen/provider:

• UI becomes responsible for infrastructure.
• Adds loading states on first render.
• Harder to control startup failures.
• Slightly tighter coupling with UI lifecycle.

This works for small apps, but not ideal for scalable architecture.


3️⃣ What Does WidgetsFlutterBinding.ensureInitialized() Do?

It ensures that Flutter engine and platform channels are initialized before executing async platform-dependent code.

It is REQUIRED when:

• Initializing database before runApp()
• Using path_provider before runApp()
• Initializing Firebase before runApp()
• Using any plugin before runApp()


4️⃣ Why ensureInitialized() Is NOT Required Inside Provider?

If database initialization happens inside a provider (after runApp()):

• Flutter binding is already initialized automatically.
• Platform channels are already ready.
• So ensureInitialized() is not strictly required.

The difference depends on timing:

Before runApp() → Required  
After runApp() → Not required


5️⃣ Interview-Level Explanation

“We initialize infrastructure like the database before runApp() to ensure all dependencies are ready before the UI starts. This improves startup performance, centralizes error handling, and maintains clean architectural separation between infrastructure and presentation layers. 

WidgetsFlutterBinding.ensureInitialized() is required only when performing asynchronous platform-dependent initialization before runApp(). If initialization occurs after runApp(), the binding is already initialized automatically.” */
  runApp(ProviderScope(child: const MyApp()));
}

