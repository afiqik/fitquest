import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/workout_plan.dart';
import '../models/exercise_item.dart';
import '../models/workout_session.dart';
import '../models/achievement_badge.dart';
import '../models/nutrition_data.dart';
import '../models/chat_message.dart';
import '../core/services/auth_service.dart';
import '../core/services/rtdb_service.dart';
import '../core/services/firestore_service.dart';
import '../core/services/ai_engine_service.dart';
import '../core/services/openrouter_service.dart';
import '../core/ai/scanned_food_result.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final RtdbService _rtdbService = RtdbService();
  final FirestoreService _firestoreService = FirestoreService();
  final OpenRouterService _openRouterService = OpenRouterService();

  StreamSubscription<User?>? _authSubscription;
  String? _authError;
  String? get authError => _authError;

  bool _isAuthLoading = false;
  bool get isAuthLoading => _isAuthLoading;

  AuthService get authService => _authService;
  RtdbService get rtdbService => _rtdbService;
  FirestoreService get firestoreService => _firestoreService;
  OpenRouterService get openRouterService => _openRouterService;

  // AI Model Selection
  String get selectedAiModel => _openRouterService.selectedModel;
  OpenRouterModel get currentAiModel => _openRouterService.currentModelObj;
  List<OpenRouterModel> get availableAiModels => OpenRouterService.availableModels;

  Map<String, String>? _cachedAiInsight;
  bool _isInsightLoading = false;
  Map<String, String>? get cachedAiInsight => _cachedAiInsight;
  bool get isInsightLoading => _isInsightLoading;

  Future<void> setAiModel(String modelId) async {
    await _openRouterService.setModel(modelId);
    _cachedAiInsight = null;
    notifyListeners();
  }

  Future<void> setOpenRouterApiKey(String apiKey) async {
    await _openRouterService.setApiKey(apiKey);
    _cachedAiInsight = null;
    notifyListeners();
  }

  // Theme
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // Language Selection (Bahasa Melayu 'ms' / English 'en')
  String _language = 'en';
  String get language => _language;
  bool get isEnglish => _language == 'en';

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', lang);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  // Workout History
  List<WorkoutSession> _workoutHistory = [];
  List<WorkoutSession> get workoutHistory => _workoutHistory;

  static const String _prefsHistoryKey = 'fitquest_workout_history';

  // Current User Profile
  late UserProfile _profile;
  UserProfile get profile => _profile;

  // Onboarding Intake Draft
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Active Workout Plan
  WorkoutPlan? _activePlan;
  WorkoutPlan? get activePlan => _activePlan;

  // Live Workout Session State (Synced with RTDB)
  bool _isWorkoutActive = false;
  bool get isWorkoutActive => _isWorkoutActive;

  ScheduledWorkoutDay? _currentSessionDay;
  ScheduledWorkoutDay? get currentSessionDay => _currentSessionDay;

  int _currentExerciseIndex = 0;
  int get currentExerciseIndex => _currentExerciseIndex;

  int _currentSet = 1;
  int get currentSet => _currentSet;

  int _remainingSeconds = 45;
  int get remainingSeconds => _remainingSeconds;

  int _totalElapsedSeconds = 0;
  int get totalElapsedSeconds => _totalElapsedSeconds;

  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  bool _isResting = false;
  bool get isResting => _isResting;

  int _restSeconds = 30;
  int get restSeconds => _restSeconds;

  Timer? _timer;

  // Incomplete Feedback State
  String _selectedReason = 'time';
  String get selectedReason => _selectedReason;

  String _feedbackNotes = '';
  String get feedbackNotes => _feedbackNotes;

  Map<String, dynamic>? _latestRevision;
  Map<String, dynamic>? get latestRevision => _latestRevision;

  // Nutrition Data
  DailyNutrition _nutrition = DailyNutrition(
    targetCalories: 2180,
    consumedCalories: 1180,
    proteinGrams: 84.0,
    targetProteinGrams: 140.0,
    carbsGrams: 145.0,
    targetCarbsGrams: 220.0,
    fatGrams: 38.0,
    targetFatGrams: 65.0,
    waterCurrentMl: 1600,
    waterTargetMl: 2000,
    waterIntakes: [
      WaterIntake(
        id: 'w_init',
        userId: 'user_default',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        amountMl: 1600,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        source: 'initial_state',
      ),
    ],
    meals: [
      MealItem(
        id: 'm1',
        name: 'Oatmeal & Banana',
        tag: 'BREAKFAST',
        meta: '8:30 AM · P 14g · C 58g · F 6g',
        calories: 340,
        protein: 14.0,
        carbs: 58.0,
        fat: 6.0,
        servingSize: '1 bowl (~250g)',
        icon: '🥣',
        loggedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      MealItem(
        id: 'm2',
        name: 'White Rice + Grilled Chicken',
        tag: 'LUNCH',
        meta: '1:15 PM · P 42g · C 65g · F 16g',
        calories: 580,
        protein: 42.0,
        carbs: 65.0,
        fat: 16.0,
        servingSize: '1 plate (~350g)',
        icon: '🍗',
        loggedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MealItem(
        id: 'm3',
        name: 'Protein Shake + Apple',
        tag: 'PRE-WORKOUT',
        meta: '5:00 PM · P 28g · C 22g · F 16g',
        calories: 260,
        protein: 28.0,
        carbs: 22.0,
        fat: 16.0,
        servingSize: '1 shake bottle (400ml)',
        icon: '🥤',
        loggedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  );
  DailyNutrition get nutrition => _nutrition;

  // Achievements
  final List<AchievementBadge> _badges = AchievementBadge.initial24Badges();
  List<AchievementBadge> get badges => _badges;

  AchievementBadge? _recentlyUnlockedBadge;
  AchievementBadge? get recentlyUnlockedBadge => _recentlyUnlockedBadge;

  // Chat Messages
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      id: 'c_init',
      text:
          "Hi! I'm your FitQuest AI Coach. I've reviewed your profile. Ask me anything about your workout plan, exercise technique, or daily nutrition tips.",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];
  List<ChatMessage> get chatMessages => _chatMessages;

  bool _isChatLoading = false;
  bool get isChatLoading => _isChatLoading;

  AppState() {
    _initDefaultProfile();
    _seedDefaultHistory();
    _loadPersistedLanguage();
    _loadPersistedProfilePhoto();
    _loadPersistedNutrition();
    _loadPersistedHistory();
    _loadPersistedAiSettings();
    _listenToAuthChanges();
  }

  Future<void> _loadPersistedAiSettings() async {
    await _openRouterService.initPreferences();
    notifyListeners();
  }

  void _listenToAuthChanges() {
    try {
      _authSubscription = _authService.authStateChanges.listen((user) {
        if (user != null) {
          _onUserSignedIn(user);
        } else {
          _onUserSignedOut();
        }
      });
    } catch (e) {
      debugPrint('FitQuest Auth state changes notice: $e');
    }
  }

  void _onUserSignedOut() {
    if (!_profile.uid.startsWith('guest_') && _profile.uid != 'guest_fitquest_uid') {
      _initDefaultProfile();
      notifyListeners();
    }
  }

  Future<void> _onUserSignedIn(User user) async {
    _profile = _profile.copyWith(
      uid: user.uid,
      email: user.email ?? _profile.email,
      name: (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : (user.isAnonymous ? 'FitQuest Guest' : _profile.name),
    );
    notifyListeners();

    // 1. Fetch remote profile (RTDB first, fallback Firestore)
    try {
      UserProfile? remote = await _rtdbService.fetchUserProfile(user.uid);
      remote ??= await _firestoreService.fetchUserProfile(user.uid);
      if (remote != null) {
        _profile = remote;
      } else {
        await Future.wait([
          _rtdbService.saveUserProfile(user.uid, _profile),
          _firestoreService.saveUserProfile(_profile),
        ]);
      }
    } catch (e) {
      debugPrint('FitQuest error syncing profile on sign-in: $e');
    }

    // 2. Fetch workout plan
    try {
      WorkoutPlan? remotePlan = await _rtdbService.fetchWorkoutPlan(user.uid);
      remotePlan ??= await _firestoreService.fetchLatestWorkoutPlan(user.uid);
      if (remotePlan != null) {
        _activePlan = remotePlan;
      } else if (_activePlan != null) {
        _activePlan = _activePlan!.copyWith(userId: user.uid);
        await Future.wait([
          _rtdbService.saveWorkoutPlan(user.uid, _activePlan!),
          _firestoreService.saveWorkoutPlan(_activePlan!),
        ]);
      }
    } catch (e) {
      debugPrint('FitQuest error syncing plan on sign-in: $e');
    }

    // 3. Load history & nutrition
    await _loadPersistedHistory();
    await _loadPersistedNutrition();
    notifyListeners();
  }

  // --- AUTH ACTIONS ---
  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final cred = await _authService.signInWithEmail(email, password);
      if (cred?.user != null) {
        await _onUserSignedIn(cred!.user!);
        _isAuthLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _authError = _formatAuthError(e.code);
    } catch (e) {
      _authError = e.toString();
    }
    _isAuthLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final cred = await _authService.registerWithEmail(
        email,
        password,
        displayName: name,
      );
      if (cred?.user != null) {
        if (name != null && name.trim().isNotEmpty) {
          _profile = _profile.copyWith(name: name.trim());
        }
        await _onUserSignedIn(cred!.user!);
        _isAuthLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _authError = _formatAuthError(e.code);
    } catch (e) {
      _authError = e.toString();
    }
    _isAuthLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithGoogle() async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred?.user != null) {
        await _onUserSignedIn(cred!.user!);
        _isAuthLoading = false;
        notifyListeners();
        return true;
      }
      // User cancelled sign in
      _isAuthLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final str = e.toString();
      if (str.contains('10') || str.contains('ApiException')) {
        _authError = isEnglish
            ? 'Google Sign-In requires SHA-1 fingerprint registered in Firebase Console.'
            : 'Google Sign-In memerlukan cap jari SHA-1 didaftarkan dalam Firebase Console.';
      } else if (str.contains('network') || str.contains('SocketException')) {
        _authError = isEnglish
            ? 'Network error. Please check your internet connection.'
            : 'Ralat sambungan. Sila semak sambungan internet anda.';
      } else {
        _authError = str;
      }
      debugPrint('FitQuest Google Sign-In Error: $e');
    }
    _isAuthLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInAsGuest() async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final cred = await _authService.signInAnonymously();
      if (cred?.user != null) {
        await _onUserSignedIn(cred!.user!);
        _isAuthLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('FitQuest Anonymous login fallback: $e');
    }

    // Local guest fallback when offline or in test environment
    _profile = _profile.copyWith(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'FitQuest Guest',
      email: 'guest@fitquest.app',
    );
    _isAuthLoading = false;
    notifyListeners();
    return true;
  }

  String _formatAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please log in.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }

  Future<void> _loadPersistedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('app_language');
      if (savedLang != null && savedLang.isNotEmpty) {
        _language = savedLang;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> _loadPersistedProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('user_photo_path_${_profile.uid}');
      if (savedPath != null && savedPath.isNotEmpty) {
        _profile = _profile.copyWith(photoPath: savedPath);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached photo path: $e');
    }
  }

  Future<void> _loadPersistedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_prefsHistoryKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        _workoutHistory = list
            .map((item) => WorkoutSession.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading cached workout history: $e');
    }

    if (_workoutHistory.isEmpty) {
      _seedDefaultHistory();
    }
    notifyListeners();

    // Sync from RTDB
    try {
      final rtdbHistory = await _rtdbService.fetchWorkoutHistory(_profile.uid);
      if (rtdbHistory.isNotEmpty) {
        _mergeHistory(rtdbHistory);
      }
    } catch (e) {
      debugPrint('Error fetching RTDB workout history: $e');
    }

    // Sync from Firestore
    try {
      final firestoreHistory = await _firestoreService.fetchWorkoutHistory(_profile.uid);
      if (firestoreHistory.isNotEmpty) {
        _mergeHistory(firestoreHistory);
      }
    } catch (e) {
      debugPrint('Error fetching Firestore workout history: $e');
    }
  }

  void _mergeHistory(List<WorkoutSession> incoming) {
    final existingIds = _workoutHistory.map((s) => s.sessionId).toSet();
    bool added = false;
    for (final s in incoming) {
      if (!existingIds.contains(s.sessionId)) {
        _workoutHistory.add(s);
        existingIds.add(s.sessionId);
        added = true;
      }
    }
    if (added) {
      _workoutHistory.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      _saveHistoryToCache();
      notifyListeners();
    }
  }

  void _seedDefaultHistory() {
    final now = DateTime.now();
    _workoutHistory = [
      WorkoutSession(
        sessionId: 'session_seed_1',
        userId: _profile.uid,
        workoutTitle: 'Upper Body Strength',
        totalExercises: 6,
        completedExercises: 6,
        totalSets: 18,
        durationSeconds: 34 * 60,
        burnedCalories: 380,
        isCompleted: true,
        startedAt: now.subtract(const Duration(days: 1, hours: 3)),
        completedAt: now.subtract(const Duration(days: 1, hours: 2, minutes: 26)),
      ),
      WorkoutSession(
        sessionId: 'session_seed_2',
        userId: _profile.uid,
        workoutTitle: 'Core & Mobility',
        totalExercises: 5,
        completedExercises: 5,
        totalSets: 15,
        durationSeconds: 26 * 60,
        burnedCalories: 290,
        isCompleted: true,
        startedAt: now.subtract(const Duration(days: 2, hours: 5)),
        completedAt: now.subtract(const Duration(days: 2, hours: 4, minutes: 34)),
      ),
      WorkoutSession(
        sessionId: 'session_seed_3',
        userId: _profile.uid,
        workoutTitle: 'Fat-Burn Circuit',
        totalExercises: 6,
        completedExercises: 6,
        totalSets: 18,
        durationSeconds: 32 * 60,
        burnedCalories: 410,
        isCompleted: true,
        startedAt: now.subtract(const Duration(days: 4, hours: 2)),
        completedAt: now.subtract(const Duration(days: 4, hours: 1, minutes: 28)),
      ),
      WorkoutSession(
        sessionId: 'session_seed_4',
        userId: _profile.uid,
        workoutTitle: 'Cardio Stamina Circuit',
        totalExercises: 6,
        completedExercises: 6,
        totalSets: 18,
        durationSeconds: 30 * 60,
        burnedCalories: 395,
        isCompleted: true,
        startedAt: now.subtract(const Duration(days: 5, hours: 4)),
        completedAt: now.subtract(const Duration(days: 5, hours: 3, minutes: 30)),
      ),
    ];
    _saveHistoryToCache();
  }

  Future<void> _saveHistoryToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maps = _workoutHistory.map((s) => s.toMap()).toList();
      await prefs.setString(_prefsHistoryKey, jsonEncode(maps));
    } catch (e) {
      debugPrint('Error saving workout history to cache: $e');
    }
  }

  void _initDefaultProfile() {
    _profile = UserProfile(
      uid: _authService.currentUid,
      name: 'Aiman',
      email: 'aiman@fitquest.app',
      gender: 'Male',
      age: 24,
      height: 172.0,
      weight: 78.0,
      activityLevel: 'Sedentary',
      fitnessGoal: 'Weight Loss',
      commitDays: 4,
      streakDays: 7,
      completedWorkouts: 24,
    );
    _activePlan = AiEngineService.generatePersonalizedPlan(_profile);
  }

  // --- ONBOARDING ACTIONS ---
  void updateIntakeProfile({
    String? name,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? activityLevel,
    String? fitnessGoal,
    int? commitDays,
  }) {
    _profile = _profile.copyWith(
      name: name,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      activityLevel: activityLevel,
      fitnessGoal: fitnessGoal,
      commitDays: commitDays,
    );
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<void> generateAndSavePlan() async {
    _activePlan = AiEngineService.generatePersonalizedPlan(_profile);
    await Future.wait([
      _firestoreService.saveUserProfile(_profile),
      _rtdbService.saveUserProfile(_profile.uid, _profile),
      if (_activePlan != null) ...[
        _firestoreService.saveWorkoutPlan(_activePlan!),
        _rtdbService.saveWorkoutPlan(_profile.uid, _activePlan!),
      ],
    ]);
    notifyListeners();
  }

  // --- ACTIVE WORKOUT LOOP (RTDB SYNC) ---
  void startWorkout(ScheduledWorkoutDay workoutDay) {
    _currentSessionDay = workoutDay;
    _isWorkoutActive = true;
    _currentExerciseIndex = 0;
    _currentSet = 1;
    _remainingSeconds = workoutDay.exercises.isNotEmpty
        ? workoutDay.exercises[0].durationSeconds
        : 45;
    _totalElapsedSeconds = 0;
    _isPlaying = true;
    _isResting = false;
    _restSeconds = 30;

    _startTimer();
    _syncWithRtdb('active');
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPlaying) return;

      _totalElapsedSeconds++;

      if (_isResting) {
        if (_restSeconds > 1) {
          _restSeconds--;
        } else {
          _advanceToNextExercise();
        }
      } else {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _triggerRest();
        }
      }

      // Periodically update Realtime Database every 3 seconds
      if (_totalElapsedSeconds % 3 == 0) {
        _syncWithRtdb(_isResting ? 'resting' : 'active');
      }

      notifyListeners();
    });
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    _syncWithRtdb(_isPlaying ? 'active' : 'paused');
    notifyListeners();
  }

  void _triggerRest() {
    _isResting = true;
    _restSeconds = 30;
    notifyListeners();
  }

  void addRestTime() {
    _restSeconds += 15;
    notifyListeners();
  }

  void skipRest() {
    _advanceToNextExercise();
  }

  void _advanceToNextExercise() {
    if (_currentSessionDay == null) return;
    _isResting = false;

    if (_currentExerciseIndex < _currentSessionDay!.exercises.length - 1) {
      _currentExerciseIndex++;
      _remainingSeconds =
          _currentSessionDay!.exercises[_currentExerciseIndex].durationSeconds;
    } else {
      finishWorkout(completed: true);
    }
    notifyListeners();
  }

  void nextExerciseManual() {
    _advanceToNextExercise();
  }

  void _syncWithRtdb(String status) {
    _rtdbService.updateLiveWorkoutState(
      uid: _profile.uid,
      workoutId: _currentSessionDay?.title ?? 'workout_today',
      exerciseIndex: _currentExerciseIndex,
      setIndex: _currentSet,
      status: status,
      elapsedSeconds: _totalElapsedSeconds,
      remainingSeconds: _isResting ? _restSeconds : _remainingSeconds,
    );
  }

  Future<void> finishWorkout({required bool completed}) async {
    _timer?.cancel();
    _isWorkoutActive = false;

    await _rtdbService.clearLiveWorkoutState(_profile.uid);

    if (completed && _currentSessionDay != null) {
      final session = WorkoutSession(
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        userId: _profile.uid,
        workoutTitle: _currentSessionDay!.title,
        totalExercises: _currentSessionDay!.exercises.length,
        completedExercises: _currentSessionDay!.exercises.length,
        totalSets: _currentSessionDay!.exercises.length * 3,
        durationSeconds: _totalElapsedSeconds,
        burnedCalories: _currentSessionDay!.estimatedCalories,
        isCompleted: true,
        startedAt:
            DateTime.now().subtract(Duration(seconds: _totalElapsedSeconds)),
        completedAt: DateTime.now(),
      );

      // Dual Save to Firestore and RTDB
      await Future.wait([
        _firestoreService.recordWorkoutSession(session),
        _rtdbService.recordWorkoutSession(_profile.uid, session),
      ]);

      _workoutHistory.insert(0, session);
      await _saveHistoryToCache();

      _profile = _profile.copyWith(
        completedWorkouts: _profile.completedWorkouts + 1,
        streakDays: _profile.streakDays + 1,
      );

      // Save updated profile
      await Future.wait([
        _firestoreService.saveUserProfile(_profile),
        _rtdbService.saveUserProfile(_profile.uid, _profile),
      ]);

      // Check badge unlock
      _unlockBadgeCelebration('b3'); // Consistency 7
    }

    notifyListeners();
  }

  // --- INCOMPLETE & ADAPTIVE REVISION ---
  void setIncompleteReason(String reason, String notes) {
    _selectedReason = reason;
    _feedbackNotes = notes;
    notifyListeners();
  }

  Future<void> processAdaptiveRevision() async {
    if (_currentSessionDay == null) return;

    _latestRevision = AiEngineService.generatePlanRevision(
      reason: _selectedReason,
      notes: _feedbackNotes,
      currentWorkout: _currentSessionDay!,
    );

    await _firestoreService.recordPlanRevision(
      uid: _profile.uid,
      reason: _selectedReason,
      notes: _feedbackNotes,
      planId: _activePlan?.planId ?? 'current_plan',
      adjustments: _latestRevision!,
    );

    // Update current plan with adjusted exercises
    if (_activePlan != null && _latestRevision != null) {
      final revisedList =
          _latestRevision!['revisedExercises'] as List<ExerciseItem>;
      final updatedSchedule = _activePlan!.schedule.map((day) {
        if (day.title == _currentSessionDay!.title) {
          return day.copyWith(exercises: revisedList);
        }
        return day;
      }).toList();

      _activePlan = _activePlan!.copyWith(schedule: updatedSchedule);
      await Future.wait([
        _firestoreService.saveWorkoutPlan(_activePlan!),
        _rtdbService.saveWorkoutPlan(_profile.uid, _activePlan!),
      ]);
    }

    _isWorkoutActive = false;
    _timer?.cancel();
    await _rtdbService.clearLiveWorkoutState(_profile.uid);
    notifyListeners();
  }

  // --- NUTRITION & WATER PERSISTENCE ---
  static const String _prefsNutritionKeyPrefix = 'daily_nutrition_';

  Future<void> _loadPersistedNutrition() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_prefsNutritionKeyPrefix$today');
      if (cached != null) {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        _nutrition = DailyNutrition.fromMap(map).recalculateTotals();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached nutrition: $e');
    }

    // Background reconcile from Firestore
    try {
      final remote =
          await _firestoreService.fetchDailyNutrition(_profile.uid, today);
      if (remote != null) {
        _nutrition = remote.recalculateTotals();
        await _saveNutritionToCache();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching remote nutrition: $e');
    }
  }

  Future<void> _saveNutritionToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_prefsNutritionKeyPrefix${_nutrition.date}',
        jsonEncode(_nutrition.toMap()),
      );
    } catch (e) {
      debugPrint('Error saving cached nutrition: $e');
    }
  }

  bool _isSyncPending = false;
  bool get isSyncPending => _isSyncPending;
  int _syncRetryCount = 0;
  Timer? _syncRetryTimer;

  Future<void> _syncNutritionToFirestore() async {
    await _saveNutritionToCache();
    _isSyncPending = true;
    try {
      await _firestoreService.saveDailyNutrition(_profile.uid, _nutrition);
      _isSyncPending = false;
      _syncRetryCount = 0;
      _syncRetryTimer?.cancel();
    } catch (e) {
      debugPrint('Firestore sync error, scheduling retry: $e');
      _scheduleSyncRetry();
    }
  }

  void _scheduleSyncRetry() {
    if (_syncRetryCount >= 5) return;
    _syncRetryTimer?.cancel();
    final delay = Duration(seconds: 2 * (1 << _syncRetryCount));
    _syncRetryTimer = Timer(delay, () {
      _syncRetryCount++;
      _syncNutritionToFirestore();
    });
  }

  // --- WATER TRACKING ---
  void addWater(int amountMl, {String source = 'quick_add'}) {
    if (amountMl <= 0) return;
    final intake = WaterIntake(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      userId: _profile.uid,
      date: _nutrition.date,
      amountMl: amountMl,
      timestamp: DateTime.now(),
      source: source,
    );

    final updatedIntakes = List<WaterIntake>.from(_nutrition.waterIntakes)
      ..add(intake);
    final newTotal = updatedIntakes.fold<int>(0, (s, i) => s + i.amountMl);
    _nutrition = _nutrition.copyWith(
      waterCurrentMl: newTotal,
      waterIntakes: updatedIntakes,
    );
    notifyListeners();
    _syncNutritionToFirestore();
  }

  void removeWater(int amountMl) {
    if (amountMl <= 0) return;
    int toDeduct = amountMl;
    final updatedIntakes = List<WaterIntake>.from(_nutrition.waterIntakes);
    while (updatedIntakes.isNotEmpty && toDeduct > 0) {
      final last = updatedIntakes.last;
      if (last.amountMl <= toDeduct) {
        toDeduct -= last.amountMl;
        updatedIntakes.removeLast();
      } else {
        updatedIntakes[updatedIntakes.length - 1] = last.copyWith(
          amountMl: last.amountMl - toDeduct,
          updatedAt: DateTime.now(),
        );
        toDeduct = 0;
      }
    }
    final newTotal = updatedIntakes.fold<int>(0, (s, i) => s + i.amountMl);
    _nutrition = _nutrition.copyWith(
      waterCurrentMl: newTotal,
      waterIntakes: updatedIntakes,
    );
    notifyListeners();
    _syncNutritionToFirestore();
  }

  void undoLastWater() {
    if (_nutrition.waterIntakes.isEmpty) return;
    final last = _nutrition.waterIntakes.last;
    removeWater(last.amountMl);
  }

  void addWaterGlass() {
    addWater(250, source: 'glass_tap');
  }

  // --- FOOD ENTRIES ---
  void logScannedFood(
    String name,
    int calories,
    String meta, {
    double protein = 0.0,
    double carbs = 0.0,
    double fat = 0.0,
    String servingSize = '1 serving',
    String? imagePath,
  }) {
    final newMeal = MealItem(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      tag: 'AI SCAN',
      meta: meta,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      servingSize: servingSize,
      icon: '🥗',
      imagePath: imagePath,
      loggedAt: DateTime.now(),
    );

    final updatedMeals = List<MealItem>.from(_nutrition.meals)..add(newMeal);
    _nutrition = _nutrition.copyWith(meals: updatedMeals).recalculateTotals();
    notifyListeners();
    _syncNutritionToFirestore();
  }

  void addScannedFoodResult(ScannedFoodResult result) {
    final timeStr = DateFormat('h:mm a').format(DateTime.now());
    final meta =
        '$timeStr · P ${result.protein.toInt()}g · C ${result.carbs.toInt()}g · F ${result.fat.toInt()}g';

    final newMeal = MealItem(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      name: result.foodName,
      tag: result.categoryTag.isNotEmpty ? result.categoryTag : 'AI SCAN',
      meta: meta,
      calories: result.calories,
      protein: result.protein,
      carbs: result.carbs,
      fat: result.fat,
      servingSize: result.servingSize,
      icon: '🥗',
      imagePath: result.imagePath,
      loggedAt: DateTime.now(),
    );

    final updatedMeals = List<MealItem>.from(_nutrition.meals)..add(newMeal);
    _nutrition = _nutrition.copyWith(meals: updatedMeals).recalculateTotals();
    notifyListeners();
    _syncNutritionToFirestore();
  }

  void editMeal(MealItem meal) {
    final idx = _nutrition.meals.indexWhere((m) => m.id == meal.id);
    if (idx != -1) {
      final updatedMeals = List<MealItem>.from(_nutrition.meals);
      updatedMeals[idx] = meal;
      _nutrition = _nutrition.copyWith(meals: updatedMeals).recalculateTotals();
      notifyListeners();
      _syncNutritionToFirestore();
    }
  }

  void deleteMeal(String mealId) {
    final updatedMeals =
        _nutrition.meals.where((m) => m.id != mealId).toList();
    _nutrition = _nutrition.copyWith(meals: updatedMeals).recalculateTotals();
    notifyListeners();
    _syncNutritionToFirestore();
  }

  Future<void> refreshNutrition() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_isSyncPending) {
      await _syncNutritionToFirestore();
    }
    try {
      final remote =
          await _firestoreService.fetchDailyNutrition(_profile.uid, today);
      if (remote != null) {
        _nutrition = remote.recalculateTotals();
        await _saveNutritionToCache();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing nutrition: $e');
    }
  }

  // --- ACHIEVEMENTS ---
  void _unlockBadgeCelebration(String badgeId) {
    final idx = _badges.indexWhere((b) => b.id == badgeId);
    if (idx != -1) {
      _badges[idx] =
          _badges[idx].copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      _recentlyUnlockedBadge = _badges[idx];
      _firestoreService.unlockBadge(_profile.uid, _badges[idx]);
    }
  }

  void dismissBadgeDialog() {
    _recentlyUnlockedBadge = null;
    notifyListeners();
  }

  // --- COACH CHAT (POWERED BY OPENROUTER) ---
  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _chatMessages.add(userMsg);
    _isChatLoading = true;
    notifyListeners();

    await _firestoreService.saveChatMessage(_profile.uid, userMsg);

    // Call OpenRouter multi-model AI coach with resilient offline fallback
    final aiReplyText = await _openRouterService.generateCoachReply(
      userMessage: text,
      profile: _profile,
      chatHistory: _chatMessages,
      language: _language,
    );

    final aiMsg = ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: aiReplyText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _chatMessages.add(aiMsg);
    _isChatLoading = false;
    notifyListeners();

    await _firestoreService.saveChatMessage(_profile.uid, aiMsg);
  }

  // --- NEXT WORKOUT INSIGHT (OPENROUTER AI) ---
  Future<Map<String, String>> fetchNextWorkoutInsight({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedAiInsight != null) {
      return _cachedAiInsight!;
    }
    _isInsightLoading = true;
    notifyListeners();
    try {
      final result = await _openRouterService.generateNextWorkoutInsight(
        history: _workoutHistory,
        profile: _profile,
        language: _language,
        plan: _activePlan,
      );
      _cachedAiInsight = result;
      _isInsightLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isInsightLoading = false;
      notifyListeners();
      return AiEngineService.generateNextWorkoutInsight(
        history: _workoutHistory,
        profile: _profile,
        language: _language,
        plan: _activePlan,
      );
    }
  }

  // --- PROFILE EDIT ---
  Future<void> updateProfile({
    required double height,
    required double weight,
    required String goal,
    required int days,
  }) async {
    _profile = _profile.copyWith(
      height: height,
      weight: weight,
      fitnessGoal: goal,
      commitDays: days,
    );
    await Future.wait([
      _firestoreService.saveUserProfile(_profile),
      _rtdbService.saveUserProfile(_profile.uid, _profile),
    ]);
    notifyListeners();
  }

  Future<void> updateProfilePhoto(String? path) async {
    if (path != null && path.isNotEmpty) {
      _profile = _profile.copyWith(photoPath: path);
    } else {
      _profile = _profile.copyWith(clearPhoto: true);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path != null && path.isNotEmpty) {
        await prefs.setString('user_photo_path_${_profile.uid}', path);
      } else {
        await prefs.remove('user_photo_path_${_profile.uid}');
      }
    } catch (e) {
      debugPrint('Error saving photo path: $e');
    }
    await Future.wait([
      _firestoreService.saveUserProfile(_profile),
      _rtdbService.saveUserProfile(_profile.uid, _profile),
    ]);
  }

  Future<void> removeProfilePhoto() async {
    await updateProfilePhoto(null);
  }

  Future<void> resetSession() async {
    _initDefaultProfile();
    await _authService.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _syncRetryTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
