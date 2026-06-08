import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onward/features/habits/data/remote/models/habit_cloud_model.dart';
import 'package:onward/features/habits/data/remote/models/habit_completion_cloud_model.dart';

class FirestoreHabitDataSource {
  final FirebaseFirestore _firestore;

  FirestoreHabitDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> uploadHabit({
    required String uid,
    required HabitCloudModel habit,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habit.cloudId)
        .set(habit.toJson());
  }

  Future<List<HabitCloudModel>> downloadHabits({
    required String uid,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .get();

    return snapshot.docs
        .map((doc) => HabitCloudModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteHabit({
    required String uid,
    required String cloudId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(cloudId)
        .delete();
  }

  Future<void> uploadCompletion({
    required String uid,
    required String cloudId,
    required HabitCompletionCloudModel completion,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(cloudId)
        .collection('completions')
        .doc(completion.date)
        .set(completion.toJson());
  }

  Future<List<HabitCompletionCloudModel>> downloadCompletions({
    required String uid,
    required String cloudId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(cloudId)
        .collection('completions')
        .get();

    return snapshot.docs
        .map((doc) => HabitCompletionCloudModel.fromJson(doc.data()))
        .toList();
  }
}
