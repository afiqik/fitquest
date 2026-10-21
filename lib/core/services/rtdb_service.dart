import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../../models/user_profile.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_session.dart';

class RtdbService {
  FirebaseDatabase? _databaseInstance;

  FirebaseDatabase? get _database {
    if (_databaseInstance != null) return _databaseInstance;
    try {
      final dbUrl = DefaultFirebaseOptions.currentPlatform.databaseURL ??
          'https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app';
      _databaseInstance = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: dbUrl,
      );
    } catch (e) {
      try {
        _databaseInstance = FirebaseDatabase.instance;
      } catch (_) {
        _databaseInstance = null;
      }
    }
    return _databaseInstance;
  }

  RtdbService();

  // --- REFERENCES ---
  DatabaseReference? _userRef(String uid) => _database?.ref('users/$uid');
  DatabaseReference? _userProfileRef(String uid) => _database?.ref('users/$uid/profile');
  DatabaseReference? _userPlanRef(String uid) => _database?.ref('users/$uid/plan');
  DatabaseReference? _userHistoryRef(String uid) => _database?.ref('users/$uid/history');
  DatabaseReference? _userSessionRef(String uid) => _database?.ref('users/$uid/activeWorkout');

  // --- USER PROFILE SYNC ---
  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    try {
      final ref = _userProfileRef(uid);
      if (ref == null) return;
      await ref.set(profile.toMap());
      debugPrint('FitQuest RTDB: User profile synced for $uid');
    } catch (e) {
      debugPrint('FitQuest RTDB saveUserProfile error: $e');
    }
  }

  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final ref = _userProfileRef(uid);
      if (ref == null) return null;
      final snap = await ref.get();
      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        return UserProfile.fromMap(data, uid);
      }
    } catch (e) {
      debugPrint('FitQuest RTDB fetchUserProfile error: $e');
    }
    return null;
  }

  // --- WORKOUT PLAN SYNC ---
  Future<void> saveWorkoutPlan(String uid, WorkoutPlan plan) async {
    try {
      final ref = _userPlanRef(uid);
      if (ref == null) return;
      await ref.set(plan.toMap());
      debugPrint('FitQuest RTDB: Workout plan synced for $uid');
    } catch (e) {
      debugPrint('FitQuest RTDB saveWorkoutPlan error: $e');
    }
  }

  Future<WorkoutPlan?> fetchWorkoutPlan(String uid) async {
    try {
      final ref = _userPlanRef(uid);
      if (ref == null) return null;
      final snap = await ref.get();
      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        return WorkoutPlan.fromMap(data);
      }
    } catch (e) {
      debugPrint('FitQuest RTDB fetchWorkoutPlan error: $e');
    }
    return null;
  }

  // --- WORKOUT HISTORY SYNC ---
  Future<void> recordWorkoutSession(String uid, WorkoutSession session) async {
    try {
      final historyRef = _userHistoryRef(uid);
      if (historyRef == null) return;
      await historyRef.child(session.sessionId).set(session.toMap());

      // Update aggregate stats
      final userRef = _userRef(uid);
      if (userRef != null) {
        await userRef.child('stats').update({
          'lastWorkoutAt': session.completedAt.toIso8601String(),
          'totalBurnedCalories': ServerValue.increment(session.burnedCalories),
          'totalWorkouts': ServerValue.increment(1),
        });
      }
      debugPrint('FitQuest RTDB: Workout session recorded for $uid');
    } catch (e) {
      debugPrint('FitQuest RTDB recordWorkoutSession error: $e');
    }
  }

  Future<List<WorkoutSession>> fetchWorkoutHistory(String uid) async {
    try {
      final historyRef = _userHistoryRef(uid);
      if (historyRef == null) return [];
      final snap = await historyRef.orderByChild('startedAt').get();
      if (snap.exists && snap.value != null) {
        final List<WorkoutSession> sessions = [];
        final rawMap = Map<dynamic, dynamic>.from(snap.value as Map);
        rawMap.forEach((key, val) {
          if (val is Map) {
            sessions.add(WorkoutSession.fromMap(Map<String, dynamic>.from(val)));
          }
        });
        // Sort descending by startedAt
        sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return sessions;
      }
    } catch (e) {
      debugPrint('FitQuest RTDB fetchWorkoutHistory error: $e');
    }
    return [];
  }

  // --- LIVE WORKOUT STATE ---
  Future<void> updateLiveWorkoutState({
    required String uid,
    required String workoutId,
    required int exerciseIndex,
    required int setIndex,
    required String status, // 'active', 'resting', 'paused', 'completed'
    required int elapsedSeconds,
    required int remainingSeconds,
  }) async {
    try {
      final ref = _userSessionRef(uid);
      if (ref == null) return;
      await ref.set({
        'workoutId': workoutId,
        'exerciseIndex': exerciseIndex,
        'setIndex': setIndex,
        'status': status,
        'elapsedSeconds': elapsedSeconds,
        'remainingSeconds': remainingSeconds,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('FitQuest RTDB update error: $e');
    }
  }

  Stream<DatabaseEvent> streamLiveWorkoutState(String uid) {
    final ref = _userSessionRef(uid);
    if (ref == null) return const Stream.empty();
    return ref.onValue;
  }

  Future<void> clearLiveWorkoutState(String uid) async {
    try {
      final ref = _userSessionRef(uid);
      if (ref == null) return;
      await ref.remove();
    } catch (e) {
      debugPrint('FitQuest RTDB clear error: $e');
    }
  }
}
