# Onward — Habit Tracker

A production-grade, local-first habit tracking Android app built with Flutter. Available on Google Play Store.

---

## About the App

Onward helps you build powerful daily habits through simple tracking and streak motivation. Whether you want to exercise daily, read more, meditate, or build any positive routine — Onward keeps you accountable with a clean, distraction-free experience.

**App ID:** `com.gokulhari.onward`

---

## Features

- **Daily Habit Tracking** — Add ,  edit, and delete habits. Mark habits complete with a single tap.
- **Streak Tracking** — Current streak and longest streak calculated automatically. Streaks break if a day is missed.
- **Completion Calendar** — Monthly calendar view showing every day a habit was completed. Visualize your consistency at a glance.
- **Dark & Light Mode** — Full Material 3 theming. Follows system theme or set manually in settings.
- **Fully Offline** — No account required. No internet needed. All data stored privately on device using SQLite.
- **Splash Screen & App Icon** — Custom branded splash screen and app icon generated with `flutter_native_splash` and `flutter_launcher_icons`.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.32.x / Dart 3.8.x |
| State Management | Riverpod 2.x (FutureProvider, FutureProvider.family) |
| Local Database | Drift (SQLite) with type-safe generated code |
| Architecture | Feature-first Clean Architecture |
| Navigation | Named routes + onGenerateRoute for dynamic routes |
| Theming | Material 3 with dynamic theme switching |

---

## Architecture

Feature-first clean architecture with three layers per feature:

```
lib/
├── core/
│   ├── database/          # Drift database setup and provider
│   ├── providers/         # Global providers (theme)
│   └── theme/             # Material 3 theme config
└── features/
    └── habits/
        ├── data/
        │   └── repositories/
        │       └── drift_habit_repository.dart   # Drift implementation
        ├── domain/
        │   ├── entities/                          # Pure Dart models
        │   ├── repositories/                      # Abstract contracts
        │   └── services/
        │       └── streak_service.dart            # Pure Dart streak logic
        └── presentation/
            ├── providers/                         # Riverpod providers
            ├── screens/                           # Full screens
            └── widgets/                           # Reusable widgets
```

### Key Architectural Decisions

- **Domain layer has zero Flutter/Drift dependencies** — pure Dart entities and repository interfaces
- **Repository pattern** — `HabitRepository` abstract class with `DriftHabitRepository` implementation. Swapping databases requires only a new implementation class
- **Upsert pattern for completions** — toggle never deletes records, updates `isCompleted` flag instead. Preserves interaction history for future analytics
- **Provider invalidation for state** — `ref.invalidate()` triggers refetch after mutations

---

## Database Schema

### Habits Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Habit name |
| createdAt | DATETIME | Creation timestamp |

### HabitCompletions Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| habitId | INTEGER FK | References Habits.id |
| date | DATETIME | Normalized to midnight |
| isCompleted | BOOLEAN | True = completed, False = unchecked after check |

---

## Streak Logic

Streak calculation is handled by `StreakService` — pure Dart, zero dependencies:

- Dates normalized to midnight to remove time component
- Duplicates removed with `.toSet()`
- Sorted descending — most recent first
- Streak must start from today or yesterday (grace period for late-night users)
- Consecutive days counted by checking 1-day difference between adjacent dates
- Gap found → streak stops

---

## Screens

| Screen | Description |
|--------|-------------|
| Home Screen | Habit list with streak subtitle and completion checkbox |
| Add/Edit Habit | Form with validation, save and delete with confirmation |
| Habit Detail | Streak stats cards + monthly completion calendar |
| Settings | Theme switching (System/Light/Dark) + V2 coming soon section |

---

## Development Journey

This app was built over 12 days as a structured learning project covering:

| Day | What Was Built |
|-----|---------------|
| Day 1 | Project setup, feature-first structure, routing, theming |
| Day 2 | Drift database bootstrap, LazyDatabase, Riverpod provider |
| Day 3 | Habits and HabitCompletions Drift tables, build_runner |
| Day 4 | Repository pattern — HabitEntity, abstract HabitRepository, DriftHabitRepository |
| Day 5 | Home screen functional — streak tracking, completion toggle, providers |
| Day 6 | Add/Edit habit screen — form validation, save, delete |
| Day 7 | Settings screen — dynamic theme switching with StateProvider |
| Day 8-9 | Habit detail screen — streak stats, completion calendar, state sync |
| Day 10 | Refactor — habitStreakProvider, dark mode fixes, import cleanup |
| Day 11 | App icon (DALL-E + Figma + SVG workflow) + native splash screen |
| Day 12 | Release prep — keystore, signed AAB, Play Store submission, closed testing |

---

## Play Store Release

- **App Name:** Onward - Habit Tracker
- **Package ID:** `com.gokulhari.onward`
- **Version:** 1.0.0+1
- **Min SDK:** Android 21 (Android 5.0)
- **Target SDK:** Android 35
- **Download Size:** ~9.94 MB

---

## Running Locally

```bash
# Clone the repo
git clone https://github.com/gokulhari-07/habit-tracker-flutter.git
cd habit-tracker-flutter

# Install dependencies
dart pub get

# Generate Drift code
dart run build_runner build

# Run the app
flutter run
```

**Note:** Release signing requires `onward-release-key.jks` and `android/key.properties` which are not committed to the repository for security reasons.

---

## Packages Used

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.20
  path_provider: ^2.1.5
  flutter_native_splash: ^2.4.7

dev_dependencies:
  drift_dev: ^2.18.0
  build_runner: ^2.4.13
  flutter_launcher_icons: ^0.14.4
```

---

## What's Next — V2

V2 development is in progress on the `v2-development` branch:

- **Google Sign In** — optional account creation
- **Cloud Sync** — back up habits across devices using Supabase
- **AI Coach** — personalized habit insights powered by Claude AI
- **Refactoring** — AsyncNotifier state management, unique DB constraints, date normalization in repository layer

---

## Developer

**Gokul Hari**
- GitHub: [@gokulhari-07](https://github.com/gokulhari-07)
- Email: gokulhari66666@gmail.com