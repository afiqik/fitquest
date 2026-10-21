import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/core/localization/app_localizations.dart';
import 'package:fitquest/core/services/ai_engine_service.dart';
import 'package:fitquest/models/user_profile.dart';
import 'package:fitquest/models/workout_session.dart';
import 'package:fitquest/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1. Localization & Dual-Language Tests', () {
    test('AppLocalizations returns valid strings in BM and EN', () {
      expect(AppLocalizations.tr('nav_history', 'ms'), 'Sejarah');
      expect(AppLocalizations.tr('nav_history', 'en'), 'History');

      expect(AppLocalizations.tr('history_title', 'ms'), 'Sejarah Workout');
      expect(AppLocalizations.tr('history_title', 'en'), 'Workout History');

      expect(AppLocalizations.tr('ai_reason_label', 'ms'), 'Sebab Sesi Seterusnya');
      expect(AppLocalizations.tr('ai_reason_label', 'en'), 'Reason for Next Workout');

      expect(AppLocalizations.tr('ai_motivation_label', 'ms'), 'Motivasi Jurulatih AI');
      expect(AppLocalizations.tr('ai_motivation_label', 'en'), 'AI Coach Motivation');

      expect(AppLocalizations.tr('change_photo_title', 'ms'), 'Tukar Gambar Profil');
      expect(AppLocalizations.tr('change_photo_title', 'en'), 'Change Profile Picture');
    });

    test('AppState language switching and persistence', () async {
      final appState = AppState();
      expect(appState.language, 'en');
      expect(appState.isEnglish, true);

      await appState.setLanguage('ms');
      expect(appState.language, 'ms');
      expect(appState.isEnglish, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'ms');

      await appState.setLanguage('en');
      expect(appState.language, 'en');
      expect(appState.isEnglish, true);
      expect(prefs.getString('app_language'), 'en');
    });
  });

  group('2. Workout History Model & AppState Tests', () {
    test('WorkoutSession serializes and deserializes properly', () {
      final now = DateTime.now();
      final session = WorkoutSession(
        sessionId: 's_test_123',
        userId: 'u_test_123',
        workoutTitle: 'Upper Body Strength',
        totalExercises: 6,
        completedExercises: 6,
        totalSets: 18,
        durationSeconds: 1800,
        burnedCalories: 350,
        isCompleted: true,
        startedAt: now.subtract(const Duration(minutes: 30)),
        completedAt: now,
      );

      final map = session.toMap();
      expect(map['sessionId'], 's_test_123');
      expect(map['workoutTitle'], 'Upper Body Strength');
      expect(map['durationSeconds'], 1800);
      expect(map['burnedCalories'], 350);

      final fromMap = WorkoutSession.fromMap(map);
      expect(fromMap.sessionId, session.sessionId);
      expect(fromMap.workoutTitle, session.workoutTitle);
      expect(fromMap.totalExercises, 6);
      expect(fromMap.isCompleted, true);
    });

    test('AppState initializes with seeded workout history', () {
      final appState = AppState();
      expect(appState.workoutHistory.isNotEmpty, true);
      expect(appState.workoutHistory.length, greaterThanOrEqualTo(4));
      expect(appState.workoutHistory.first.workoutTitle.isNotEmpty, true);
    });
  });

  group('3. AI Reason & Motivation Generation Tests', () {
    final profile = UserProfile(
      uid: 'u1',
      name: 'Aiman',
      fitnessGoal: 'Weight Loss',
      commitDays: 4,
      streakDays: 7,
      completedWorkouts: 24,
    );

    test('Generates scientific Reason & high-energy Motivation after Upper Body in BM & EN', () {
      final history = [
        WorkoutSession(
          sessionId: 's1',
          userId: 'u1',
          workoutTitle: 'Upper Body Strength',
          totalExercises: 6,
          completedExercises: 6,
          totalSets: 18,
          durationSeconds: 2000,
          burnedCalories: 380,
          isCompleted: true,
          startedAt: DateTime.now().subtract(const Duration(hours: 2)),
          completedAt: DateTime.now(),
        ),
      ];

      // Test BM
      final insightBm = AiEngineService.generateNextWorkoutInsight(
        history: history,
        profile: profile,
        language: 'ms',
      );
      expect(insightBm['reason']!.contains('otot bahagian atas') || insightBm['reason']!.contains('dada'), true);
      expect(insightBm['reason']!.contains('rehat 36 hingga 48 jam'), true);
      expect(insightBm['motivation']!.contains('7 hari'), true);
      expect(insightBm['nextWorkoutTitle']!.isNotEmpty, true);

      // Test EN
      final insightEn = AiEngineService.generateNextWorkoutInsight(
        history: history,
        profile: profile,
        language: 'en',
      );
      expect(insightEn['reason']!.contains('upper body'), true);
      expect(insightEn['reason']!.contains('36 to 48 hours'), true);
      expect(insightEn['motivation']!.contains('7-day streak'), true);
      expect(insightEn['nextWorkoutTitle']!.isNotEmpty, true);
    });

    test('Generates appropriate Reason & Motivation after Lower Body', () {
      final history = [
        WorkoutSession(
          sessionId: 's2',
          userId: 'u1',
          workoutTitle: 'Lower Body Strength',
          totalExercises: 6,
          completedExercises: 6,
          totalSets: 18,
          durationSeconds: 2100,
          burnedCalories: 420,
          isCompleted: true,
          startedAt: DateTime.now().subtract(const Duration(hours: 3)),
          completedAt: DateTime.now(),
        ),
      ];

      final insight = AiEngineService.generateNextWorkoutInsight(
        history: history,
        profile: profile,
        language: 'ms',
      );
      expect(insight['reason']!.contains('kaki') || insight['reason']!.contains('otot terbesar'), true);
      expect(insight['motivation']!.isNotEmpty, true);
    });
  });

  group('4. Profile Photo Upload & Management Tests', () {
    test('UserProfile supports photoPath serialization', () {
      final profile = UserProfile(
        uid: 'u_photo',
        name: 'Aiman',
        photoPath: '/storage/emulated/0/DCIM/profile.jpg',
      );

      expect(profile.photoPath, '/storage/emulated/0/DCIM/profile.jpg');

      final copy = profile.copyWith(name: 'Aiman Updated');
      expect(copy.photoPath, '/storage/emulated/0/DCIM/profile.jpg');

      final map = profile.toMap();
      expect(map['photoPath'], '/storage/emulated/0/DCIM/profile.jpg');

      final restored = UserProfile.fromMap(map, 'u_photo');
      expect(restored.photoPath, '/storage/emulated/0/DCIM/profile.jpg');
    });

    test('AppState updates and removes profile photo', () async {
      final appState = AppState();
      expect(appState.profile.photoPath, isNull);

      await appState.updateProfilePhoto('/data/user/0/app/photo.png');
      expect(appState.profile.photoPath, '/data/user/0/app/photo.png');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_photo_path_${appState.profile.uid}'), '/data/user/0/app/photo.png');

      await appState.removeProfilePhoto();
      expect(appState.profile.photoPath, isNull);
      expect(prefs.getString('user_photo_path_${appState.profile.uid}'), isNull);
    });
  });
}
