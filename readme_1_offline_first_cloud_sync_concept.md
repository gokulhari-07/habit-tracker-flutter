================================================================================
OFFLINE-FIRST CLOUD SYNC 
================================================================================

GOAL OF THIS SESSION

Until now, Onward was a local-only habit tracker.

Data Flow:

UI
↓
Riverpod
↓
Repository
↓
Drift (SQLite)

All habit data was stored only inside the user's device.

Problem:

If user:
- uninstalls app
- changes phone
- phone gets damaged
- phone gets lost

all habits are permanently lost.

This is not production-grade behavior.

Therefore we started implementing:

OFFLINE-FIRST CLOUD SYNC

using:

Firebase Authentication
+
Cloud Firestore

================================================================================
WHY FIRESTORE?
================================================================================

Firestore is Google's cloud database.

Instead of storing data only inside the phone:

Phone
└── SQLite

we can also store it in Google's cloud:

Phone
└── SQLite

      ↕

Google Cloud
└── Firestore

Now user data exists in two places:

1. Local SQLite Database
2. Cloud Firestore Database

This allows restoring data after reinstalling app.

================================================================================
WHY NOT STORE DIRECTLY IN FIRESTORE?
================================================================================

Many beginners think:

UI
↓
Firestore

should be enough.

Problem:

What if user has no internet?

Example:

User enters metro.
No network available.

User creates habit.

If app depends entirely on Firestore:

Create Habit
↓
Firestore Request
↓
Fails

Habit is not saved.

Bad user experience.

================================================================================
OFFLINE-FIRST ARCHITECTURE
================================================================================

Production apps usually do:

UI
↓
Repository
↓
Local Database (SQLite)

Immediately save data locally.

Then:

Background Sync
↓
Cloud Upload

Later.

This is called:

OFFLINE-FIRST ARCHITECTURE

Benefits:

✓ Works without internet
✓ Fast UI
✓ No loading indicators everywhere
✓ Better user experience
✓ Production-grade architecture

================================================================================
HOW OUR APP WILL WORK
================================================================================

User creates habit:

Reading

Flow:

UI
↓
Controller
↓
Repository
↓
SQLite

Habit appears immediately.

Then:

Sync Service
↓
Firestore

uploads it in background.

User never waits.

================================================================================
WHY FIREBASE AUTH WAS IMPLEMENTED FIRST
================================================================================

Cloud storage needs user identification.

Example:

users
 └── uid_123
      └── habits

Firebase Authentication gives every user a unique:

UID

Example:

abc123xyz

This UID tells Firestore:

Store this habit under this user.

Without authentication:

No UID exists.

Therefore:

No cloud storage possible.

================================================================================
GUEST USER VS AUTHENTICATED USER
================================================================================

GUEST USER

Continue as Guest

Available:

✓ SQLite
✓ Local storage

Unavailable:

✗ Firestore
✗ Cloud Sync
✗ Backup

If app is uninstalled:

All data is lost.

-------------------------------------------------------------------------------

AUTHENTICATED USER

Continue with Google

Available:

✓ SQLite
✓ Firestore
✓ Cloud Sync
✓ Cloud Backup

If app is uninstalled:

Data still exists in Firestore.

After login:

Firestore
↓
Download Data
↓
Restore SQLite

Everything comes back.

================================================================================
WHY WE CHOSE SIMPLE SYNC
================================================================================

Two options existed.

OPTION 1

Real-Time Sync

Phone A changes data.
Phone B instantly receives update.

Like:

WhatsApp
Google Docs
Discord

Complex implementation.

-------------------------------------------------------------------------------

OPTION 2

Simple Sync

Phone A changes data.
Firestore updated.

Phone B receives update next app launch.

Much simpler.

Much fewer bugs.

Enough for habit tracking.

Decision:

✓ Simple Sync

================================================================================
FINAL ARCHITECTURE DECISION
================================================================================

Guest User
↓
Drift Only

Authenticated User
↓
Drift + Firestore Sync

Drift remains:

PRIMARY DATABASE

Firestore becomes:

BACKUP + CLOUD SYNC

This is extremely important.

We are NOT replacing Drift.

================================================================================
ADDING FIRESTORE
================================================================================

Added dependency:

cloud_firestore

Dependency conflict occurred:

cloud_firestore 6.x
required

firebase_core 4.x

But project currently uses:

firebase_core 3.3.0

Therefore:

cloud_firestore 6.x

was incompatible.

Solution:

cloud_firestore: ^5.6.12

which is compatible with:

firebase_core: ^3.3.0
firebase_auth: ^5.1.2

================================================================================
FIRESTORE SETUP
================================================================================

Created Firestore Database.

Selected:

Standard Edition

Selected:

Production Mode

Reason:

Production Mode allows writing proper security rules later.

Selected region:

Closest region to users.

Firestore database successfully created.

No collections were created manually.

Reason:

Database structure should be designed first before creating data.

================================================================================
NEW FOLDER STRUCTURE ADDED
================================================================================

lib
└── features
    └── habits
        └── data
            ├── models
            ├── repositories
            ├── tables
            │
            ├── remote
            │   ├── datasources
            │   └── models
            │
            └── sync

================================================================================
WHY THESE NEW FOLDERS?
================================================================================

Before:

Only local database existed.

Now:

Two databases exist.

-------------------------------------------------------------------------------

LOCAL DATABASE

SQLite (Drift)

Handled by:

tables/
repositories/

-------------------------------------------------------------------------------

REMOTE DATABASE

Firestore

Handled by:

remote/

-------------------------------------------------------------------------------

SYNC LAYER

Responsible for:

SQLite
↓
Firestore

and

Firestore
↓
SQLite

communication.

Handled by:

sync/

================================================================================
IMPORTANT CONCEPT
================================================================================

SQLite = Source of Truth

Firestore = Cloud Backup + Sync

Sync Service = Bridge between SQLite and Firestore

This is the foundation of the Offline-First Architecture that will be built in
the next sessions.
================================================================================