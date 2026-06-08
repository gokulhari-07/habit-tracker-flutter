# README 3 — Firestore Offline Sync Implementation

## What This Commit Does

This commit completes the offline-first cloud sync architecture for Onward.
Before this, habits synced to Firestore but streaks and completion history
were lost on reinstall. User data was also not isolated — one user could
see another user's habits. This commit fixes all of that.

---

## Files Changed

```
lib
├── core
│   └── database
│       └── app_database.dart                                   [updated]
│
└── features
    ├── auth
    │   └── presentation
    │       └── providers
    │           └── auth_controller.dart                        [updated]
    │
    └── habits
        ├── domain
        │   ├── entities
        │   │   └── habit_entity.dart                           [updated]
        │   └── repositories
        │       └── habit_repository.dart                       [updated]
        │
        └── data
            ├── tables
            │   └── habit_table.dart                            [updated]
            │
            ├── repositories
            │   └── drift_habit_repository.dart                 [updated]
            │
            ├── remote
            │   ├── datasources
            │   │   └── firestore_habit_datasource.dart         [updated]
            │   └── models
            │       ├── habit_cloud_model.dart                  [updated]
            │       └── habit_completion_cloud_model.dart       [created]
            │
            └── sync
                ├── habit_sync_service.dart                     [updated]
                └── sync_providers.dart                         [updated]
│
└── presentation
    └── habits
        ├── providers
        │   └── habit_controller.dart                           [updated]
        ├── screens
        │   └── habit_detail_screen.dart                        [updated]
        └── ui_models
            └── habit_ui_model.dart                             [updated]

pubspec.yaml                                                    [updated]
```

---

## Problems Fixed

### 1. Streaks Lost on Reinstall
Previously, `HabitCloudModel` only carried `id`, `name`, and `createdAt`
to Firestore. Completion history (which habits were done on which days) was
never uploaded. So reinstalling the app meant all streaks reset to zero.

**Fix:** Added a full completions sync. Every habit completion is now
uploaded to Firestore and restored on login.

### 2. ID Collision Bug
Habits used Drift's auto-increment integer (1, 2, 3...) as their Firestore
document ID. If a user installed the app on two phones, both would create
habits starting at ID 1 — and they would silently overwrite each other in
Firestore.

**Fix:** Added a `cloudId` field — a UUID (universally unique identifier)
like `"f47ac10b-58cc-4372-a567-0e02b2c3d479"`. This is now the Firestore
document ID. UUIDs are generated randomly and collisions are statistically
impossible.

### 3. No Conflict Resolution
Without timestamps, there was no way to know which version of a habit was
newer when two devices synced. The code just blindly overwrote everything.

**Fix:** Added `updatedAt` timestamp to every habit. The sync now uses
last-write-wins — if the cloud version is newer than the local version,
the local version is updated. If local is newer, cloud is ignored.

### 4. User Isolation Broken
A logged-in user's habits remained in the local Drift database after
sign-out. If a different user signed in on the same device, they would see
the previous user's habits.

**Fix:** On sign-out, the app now uploads all local data to Firestore
first, then wipes the local Drift database completely. On sign-in, it
restores only that user's data from Firestore.

### 5. Architecture Downcast Bug
`sync_providers.dart` had `repo as DriftHabitRepository` — it was casting
the abstract `HabitRepository` to its concrete implementation. This breaks
clean architecture and would throw a runtime error if the repository
implementation was ever swapped.

**Fix:** `HabitSyncService` now accepts `HabitRepository` (the abstract
interface) instead of `DriftHabitRepository` (the concrete class). The
cast is removed.

---

## Firestore Data Structure

```
Firestore
└── users/
    └── {uid}/
        └── habits/
            └── {cloudId}/               ← UUID, not integer
                ├── cloudId: "f47ac10b-..."
                ├── name: "Reading"
                ├── createdAt: "2026-06-01T10:00:00.000Z"
                ├── updatedAt: "2026-06-08T09:30:00.000Z"
                └── completions/
                    └── {date}/          ← "yyyy-MM-dd" string
                        ├── date: "2026-06-08"
                        └── isCompleted: true
```

---

## File-by-File Changes

### `habit_table.dart` [updated]
Added two new columns to the `Habits` Drift table:
- `cloudId` — nullable UUID string. Nullable because existing rows before
  this update have no UUID yet. Assigned on first sync or edit.
- `updatedAt` — non-nullable DateTime. Tracks when the habit was last
  modified, used for conflict resolution.

### `app_database.dart` [updated]
- Bumped `schemaVersion` from `2` to `3`
- Added `MigrationStrategy` with `onUpgrade` handler:
  - Adds `cloudId` and `updatedAt` columns for users upgrading from v1 or v2
  - Backfills `updatedAt` with `createdAt` for all existing rows
  - Added explicit `onCreate` so fresh installs also work correctly

### `habit_entity.dart` [updated]
Added `cloudId` (nullable `String?`) and `updatedAt` (`DateTime`) fields.
`cloudId` is nullable because habits created before the first sync have no
UUID yet.

### `habit_repository.dart` [updated]
Added `clearAllData()` to the abstract interface so any repository
implementation must provide it.

### `drift_habit_repository.dart` [updated]
- `addHabit` now generates a UUID and sets `updatedAt` to `DateTime.now()`
- `updateHabit` now stamps `updatedAt` on every edit
- `insertHabit` now uses `cloudId`-based lookup instead of integer ID.
  Last-write-wins: if local row exists with same `cloudId` and cloud is
  newer, it updates. Otherwise it inserts fresh.
- `clearAllData` new method — deletes completions first (foreign key
  order), then habits. Called on sign-out.

### `habit_cloud_model.dart` [updated]
- Replaced `int id` with `String cloudId`
- Added `updatedAt` field
- `toJson()` and `fromJson()` include both new fields
- `toEntity()` sets local `id` to `0` — Drift autoassigns integer ID on
  insert, cloud never dictates local integer

### `habit_completion_cloud_model.dart` [created]
New file. Maps `HabitCompletionEntity` to and from Firestore JSON.
- Firestore document ID = ISO date string (`"yyyy-MM-dd"`)
- Stores `date` and `isCompleted`
- Local Drift integer `id` is never synced to Firestore

### `firestore_habit_datasource.dart` [updated]
- `uploadHabit` uses `habit.cloudId` as Firestore document ID
- `deleteHabit` parameter changed from `int habitId` to `String cloudId`
- Added `uploadCompletion` — uploads one completion to
  `users/{uid}/habits/{cloudId}/completions/{date}`
- Added `downloadCompletions` — fetches all completions for a given habit

### `habit_sync_service.dart` [updated]
- `localRepository` type changed from `DriftHabitRepository` to
  `HabitRepository` (fixes the downcast architecture bug)
- `syncHabitsToCloud` now also uploads all completions per habit
- `syncHabitsFromCloud` now also downloads and restores completions.
  Builds a `cloudId → local int id` map after habits are restored, then
  fetches and inserts completions via `toggleCompletion`
- Added `clearLocalData()` — calls `localRepository.clearAllData()`

### `sync_providers.dart` [updated]
- Removed `DriftHabitRepository` import
- Removed `repo as DriftHabitRepository` cast
- `HabitSyncService` now receives `repo` directly as `HabitRepository`

### `auth_controller.dart` [updated]
Sign-out flow updated:
- Uploads local data to Firestore first
- Clears local Drift DB
- Then calls Firebase sign out
This guarantees no data is lost if the user signs out without manually syncing.

### `habit_ui_model.dart` [updated]
Added `updatedAt` field so the presentation layer can pass it back to
`HabitEntity` when navigating to the edit screen.

### `habit_controller.dart` [updated]
Passes `habit.updatedAt` when constructing `HabitUiModel`.

### `habit_detail_screen.dart` [updated]
Passes `habit.updatedAt` when constructing `HabitEntity` for navigation
to the edit screen.

### `pubspec.yaml` [updated]
Added `uuid: ^4.4.0` dependency for UUID generation.

---

## Conceptual Summary

### Offline-First Sync Pattern

The local Drift SQLite database is always the source of truth for the UI.
Firestore is the backup and cross-device sync layer.

```
User Action
    ↓
Drift SQLite (local, instant)
    ↓
UI updates immediately
    ↓
Firestore (background sync)
```

The user never waits for the network. If offline, changes are stored
locally and synced when connectivity returns.

### Last-Write-Wins Conflict Resolution

When two versions of the same habit exist (local and cloud), `updatedAt`
timestamps are compared and the newer one wins. Simple and effective for
a single-user app where multi-device conflicts are rare.

### UUID Strategy

Every habit gets a UUID when created. This UUID is the Firestore document
ID and travels with the habit across devices. The local Drift integer ID
is a local detail only — never sent to Firestore.

### Sign-In / Sign-Out Flow

```
Sign out:
Upload local data to Firestore
    ↓
Clear local Drift DB
    ↓
Firebase sign out

Sign in:
Firebase sign in
    ↓
Download habits from Firestore
    ↓
Download completions for each habit
    ↓
Restore everything to local Drift DB
    ↓
UI refreshes
```

---

## Packages Added
- `uuid: ^4.4.0` — generates RFC 4122 version 4 random UUIDs

## Schema Version
- Previous: `2`
- Current: `3`
- Migration: adds `cloud_id` and `updated_at` columns, backfills
  `updated_at` with `created_at` for all existing rows