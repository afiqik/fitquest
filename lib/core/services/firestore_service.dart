import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_profile.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_session.dart';
import '../../models/achievement_badge.dart';
import '../../models/nutrition_data.dart';
import '../../models/chat_message.dart';

class FirestoreService {
  FirebaseFirestore? _dbInstance;
  FirebaseFirestore? get _db {
    try {
      return _dbInstance ??= FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Document reference for user profile
  DocumentReference<Map<String, dynamic>>? _userProfileDoc(String uid) {
    return _db?.collection('users').doc(uid).collection('profile').doc('current');
  }

  // Collection for plans
  CollectionReference<Map<String, dynamic>>? _userPlansCol(String uid) {
    return _db?.collection('users').doc(uid).collection('plans');
  }

  // Collection for sessions history
  CollectionReference<Map<String, dynamic>>? _userSessionsCol(String uid) {
    return _db?.collection('users').doc(uid).collection('sessions');
  }

  // Collection for adaptive plan revisions
  CollectionReference<Map<String, dynamic>>? _userRevisionsCol(String uid) {
    return _db?.collection('users').doc(uid).collection('revisions');
  }

  // Collection for achievements
  CollectionReference<Map<String, dynamic>>? _userAchievementsCol(String uid) {
    return _db?.collection('users').doc(uid).collection('achievements');
  }

  // Collection for coach chat
  CollectionReference<Map<String, dynamic>>? _userChatsCol(String uid) {
    return _db?.collection('users').doc(uid).collection('chats');
  }

  // Collection for daily nutrition and water
  CollectionReference<Map<String, dynamic>>? _userNutritionCol(String uid) {
    return _db?.collection('users').doc(uid).collection('nutrition');
  }

  // --- NUTRITION & WATER ---
  Future<void> saveDailyNutrition(String uid, DailyNutrition nutrition) async {
    try {
      final col = _userNutritionCol(uid);
      if (col == null) return;
      await col.doc(nutrition.date).set(
        nutrition.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Firestore saveDailyNutrition error: $e');
    }
  }

  Future<DailyNutrition?> fetchDailyNutrition(String uid, String date) async {
    try {
      final col = _userNutritionCol(uid);
      if (col == null) return null;
      final snap = await col.doc(date).get();
      if (snap.exists && snap.data() != null) {
        return DailyNutrition.fromMap(snap.data()!);
      }
    } catch (e) {
      debugPrint('Firestore fetchDailyNutrition error: $e');
    }
    return null;
  }

  // --- USER PROFILE ---
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final doc = _userProfileDoc(profile.uid);
      if (doc == null) return;
      await doc.set(
        profile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: $e');
    }
  }

  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final doc = _userProfileDoc(uid);
      if (doc == null) return null;
      final snap = await doc.get();
      if (snap.exists && snap.data() != null) {
        return UserProfile.fromMap(snap.data()!, uid);
      }
    } catch (e) {
      debugPrint('Firestore fetchUserProfile error: $e');
    }
    return null;
  }

  // --- WORKOUT PLANS ---
  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    try {
      final col = _userPlansCol(plan.userId);
      if (col == null) return;
      await col.doc(plan.planId).set(plan.toMap());
    } catch (e) {
      debugPrint('Firestore saveWorkoutPlan error: $e');
    }
  }

  Future<WorkoutPlan?> fetchLatestWorkoutPlan(String uid) async {
    try {
      final col = _userPlansCol(uid);
      if (col == null) return null;
      final snap = await col
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return WorkoutPlan.fromMap(snap.docs.first.data());
      }
    } catch (e) {
      debugPrint('Firestore fetchLatestWorkoutPlan error: $e');
    }
    return null;
  }

  // --- WORKOUT SESSIONS (HISTORY) ---
  Future<void> recordWorkoutSession(WorkoutSession session) async {
    try {
      final col = _userSessionsCol(session.userId);
      if (col != null) {
        await col.doc(session.sessionId).set(session.toMap());
      }

      // Also increment user completed workouts & streak in profile
      final profileDoc = _userProfileDoc(session.userId);
      if (profileDoc != null) {
        await profileDoc.update({
          'completedWorkouts': FieldValue.increment(1),
          'streakDays': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Firestore recordWorkoutSession error: $e');
    }
  }

  Future<List<WorkoutSession>> fetchWorkoutHistory(String uid) async {
    try {
      final col = _userSessionsCol(uid);
      if (col == null) return [];
      final snap = await col
          .orderBy('startedAt', descending: true)
          .get();
      return snap.docs.map((d) => WorkoutSession.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchWorkoutHistory error: $e');
      return [];
    }
  }

  // --- ADAPTIVE REVISIONS ---
  Future<void> recordPlanRevision({
    required String uid,
    required String reason,
    required String notes,
    required String planId,
    required Map<String, dynamic> adjustments,
  }) async {
    try {
      final col = _userRevisionsCol(uid);
      if (col == null) return;
      await col.add({
        'reason': reason,
        'notes': notes,
        'planId': planId,
        'adjustments': adjustments,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore recordPlanRevision error: $e');
    }
  }

  // --- ACHIEVEMENTS ---
  Future<void> unlockBadge(String uid, AchievementBadge badge) async {
    try {
      final col = _userAchievementsCol(uid);
      if (col == null) return;
      await col.doc(badge.id).set(badge.toMap());
    } catch (e) {
      debugPrint('Firestore unlockBadge error: $e');
    }
  }

  // --- CHAT MESSAGES ---
  Future<void> saveChatMessage(String uid, ChatMessage message) async {
    try {
      final col = _userChatsCol(uid);
      if (col == null) return;
      await col.doc(message.id).set(message.toMap());
    } catch (e) {
      debugPrint('Firestore saveChatMessage error: $e');
    }
  }

  Future<List<ChatMessage>> fetchChatHistory(String uid) async {
    try {
      final col = _userChatsCol(uid);
      if (col == null) return [];
      final snap = await col
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();
      return snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchChatHistory error: $e');
      return [];
    }
  }
}
