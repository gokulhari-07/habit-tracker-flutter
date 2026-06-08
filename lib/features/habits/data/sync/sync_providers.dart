import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:onward/core/database/database_provider.dart';
import 'package:onward/features/habits/data/remote/datasources/firestore_habit_datasource.dart';
import 'package:onward/features/habits/data/sync/habit_sync_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreHabitDataSourceProvider =
    Provider<FirestoreHabitDataSource>((ref) {
      final firestore = ref.watch(firestoreProvider);
      return FirestoreHabitDataSource(firestore: firestore);
    });

final habitSyncServiceProvider = Provider<HabitSyncService>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final firestoreDataSource = ref.watch(firestoreHabitDataSourceProvider);

  return HabitSyncService(
    localRepository: repo,
    firestoreDataSource: firestoreDataSource,
  );
});
