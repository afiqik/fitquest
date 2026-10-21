import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/firebase_options.dart';
import 'package:fitquest/core/services/openrouter_service.dart';
import 'package:fitquest/core/widgets/ai_model_selector_sheet.dart';
import 'package:fitquest/features/auth/login_screen.dart';
import 'package:fitquest/features/auth/register_screen.dart';
import 'package:fitquest/features/chatbot/coach_chat_screen.dart';
import 'package:fitquest/features/progress/progress_screen.dart';
import 'package:fitquest/models/workout_plan.dart';
import 'package:fitquest/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1. Firebase Configuration Tests', () {
    test('DefaultFirebaseOptions contains correct real project settings', () {
      expect(DefaultFirebaseOptions.android.projectId, 'fitquest-97517');
      expect(DefaultFirebaseOptions.android.messagingSenderId, '359702741609');
      expect(
        DefaultFirebaseOptions.android.databaseURL,
        'https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app',
      );

      expect(DefaultFirebaseOptions.web.projectId, 'fitquest-97517');
      expect(DefaultFirebaseOptions.web.messagingSenderId, '359702741609');
      expect(
        DefaultFirebaseOptions.web.databaseURL,
        'https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app',
      );
    });
  });

  group('2. OpenRouter Multi-Model Service Tests', () {
    test('OpenRouterService has correct default API key and 5 models', () {
      final service = OpenRouterService();
      expect(
        service.apiKey,
        const String.fromEnvironment('OPENROUTER_API_KEY'),
      );
      expect(service.selectedModel, 'google/gemini-2.0-flash-001');

      final modelIds = OpenRouterService.availableModels.map((m) => m.id).toList();
      expect(modelIds, contains('google/gemini-2.0-flash-001'));
      expect(modelIds, contains('deepseek/deepseek-chat'));
      expect(modelIds, contains('openai/gpt-4o-mini'));
      expect(modelIds, contains('anthropic/claude-3.5-haiku'));
      expect(modelIds, contains('meta-llama/llama-3.3-70b-instruct'));
      expect(modelIds.length, 5);
    });

    test('OpenRouterService model switching works correctly', () async {
      final service = OpenRouterService();
      await service.setModel('deepseek/deepseek-chat');
      expect(service.selectedModel, 'deepseek/deepseek-chat');
      expect(service.currentModelObj.name, 'DeepSeek V3');

      await service.setModel('openai/gpt-4o-mini');
      expect(service.selectedModel, 'openai/gpt-4o-mini');
      expect(service.currentModelObj.provider, 'OpenAI');
    });

    test('OpenRouterService offline graceful fallback', () async {
      final service = OpenRouterService();
      final appState = AppState();

      // Calling generateCoachReply when offline falls back to rule-based reply
      final reply = await service.generateCoachReply(
        userMessage: 'Berapa gram protein aku kena makan sehari?',
        profile: appState.profile,
        chatHistory: [],
        language: 'ms',
      );
      expect(reply, isNotEmpty);
      expect(reply.toLowerCase(), contains('protein'));

      // Next workout insight fallback
      final insight = await service.generateNextWorkoutInsight(
        history: appState.workoutHistory,
        profile: appState.profile,
        language: 'ms',
        plan: appState.activePlan,
      );
      expect(insight['reason'], isNotNull);
      expect(insight['motivation'], isNotNull);
      expect(insight['nextWorkoutTitle'], isNotNull);
    });
  });

  group('3. AppState Firebase & Auth Integration Tests', () {
    test('AppState initializes OpenRouter and Auth state gracefully', () {
      final appState = AppState();
      expect(appState.selectedAiModel, 'google/gemini-2.0-flash-001');
      expect(appState.availableAiModels.length, 5);
      expect(appState.isAuthLoading, isFalse);
      expect(appState.authError, isNull);
    });

    test('AppState switches AI model and notifies listeners', () async {
      final appState = AppState();
      bool notified = false;
      appState.addListener(() => notified = true);

      await appState.setAiModel('anthropic/claude-3.5-haiku');
      expect(appState.selectedAiModel, 'anthropic/claude-3.5-haiku');
      expect(appState.currentAiModel.name, 'Claude 3.5 Haiku');
      expect(notified, isTrue);
    });

    test('AppState signInAsGuest sets guest identity', () async {
      final appState = AppState();
      await appState.signInAsGuest();
      expect(appState.profile.name, 'FitQuest Guest');
      expect(appState.isAuthLoading, isFalse);
    });

    test('AppState dual persistence calls succeed without crashing', () async {
      final appState = AppState();
      await appState.updateProfile(
        height: 175.0,
        weight: 75.0,
        goal: 'Improve Endurance',
        days: 5,
      );
      expect(appState.profile.height, 175.0);
      expect(appState.profile.fitnessGoal, 'Improve Endurance');
      expect(appState.profile.commitDays, 5);

      await appState.generateAndSavePlan();
      expect(appState.activePlan, isNotNull);
      expect(appState.activePlan!.title, contains('Improve Endurance'));
    });
  });

  group('4. UI Widget & Model Selection Sheet Tests', () {
    testWidgets('LoginScreen renders email, password fields and buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders registration fields and buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Display Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('AiModelSelectorSheet shows all 5 models and allows selection', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: Scaffold(
              body: AiModelSelectorSheet(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Choose AI Model (OpenRouter)'), findsOneWidget);
      expect(find.text('Gemini 2.0 Flash'), findsOneWidget);
      expect(find.text('DeepSeek V3'), findsOneWidget);
      expect(find.text('GPT-4o Mini'), findsOneWidget);
      expect(find.text('Claude 3.5 Haiku'), findsOneWidget);
      expect(find.text('Llama 3.3 70B'), findsOneWidget);

      // Tap on DeepSeek V3
      await tester.tap(find.text('DeepSeek V3'));
      await tester.pumpAndSettle();

      expect(appState.selectedAiModel, 'deepseek/deepseek-chat');
    });

    testWidgets('CoachChatScreen renders model selector chip in top bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: CoachChatScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('AI Coach FitQuest'), findsOneWidget);
      expect(find.text('Gemini 2.0 Flash'), findsOneWidget);
    });

    testWidgets('ProgressScreen renders AI Insight card with model chip and refresh button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: ProgressScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Gemini 2.0 Flash'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.text('Reason for Next Workout'), findsOneWidget);
      expect(find.text('AI Coach Motivation'), findsOneWidget);
    });
  });

  group('5. RTDB & OpenRouter Resilience Tests', () {
    test('OpenRouterService resolves decommissioned endpoints to active live models', () {
      expect(
        OpenRouterService.resolveActiveModelEndpoint('google/gemini-2.0-flash-001'),
        'google/gemini-2.5-flash',
      );
      expect(
        OpenRouterService.resolveActiveModelEndpoint('anthropic/claude-3.5-haiku'),
        'anthropic/claude-haiku-4.5',
      );
      expect(
        OpenRouterService.resolveActiveModelEndpoint('deepseek/deepseek-chat'),
        'deepseek/deepseek-chat',
      );
    });

    test('WorkoutPlan and ScheduledWorkoutDay handle RTDB Map-based serialization safely', () {
      // Simulating RTDB returning a Map with string keys instead of List
      final rtdbPlanMap = {
        'planId': 'plan_rtdb_1',
        'userId': 'user_test',
        'title': 'RTDB Plan Test',
        'rationale': 'Testing map parsing',
        'totalWeeks': 4,
        'currentWeek': 1,
        'schedule': {
          '0': {
            'dayOfWeek': 'ISN',
            'dateNumber': '10',
            'title': 'Upper Body RTDB',
            'meta': '32 min',
            'state': 'today',
            'durationMinutes': 32,
            'estimatedCalories': 400,
            'aiRationale': 'Good recovery',
            'exercises': {
              '0': {
                'id': 'ex_1',
                'name': 'Push Up',
                'setsReps': '3x12',
                'durationSeconds': 45,
                'targetMuscle': 'Chest',
                'instructions': 'Keep core tight',
                'icon': '💪',
              }
            },
          }
        },
      };

      final plan = WorkoutPlan.fromMap(rtdbPlanMap);
      expect(plan.schedule.length, 1);
      expect(plan.schedule[0].title, 'Upper Body RTDB');
      expect(plan.schedule[0].exercises.length, 1);
      expect(plan.schedule[0].exercises[0].name, 'Push Up');
    });

    test('AppState fetchNextWorkoutInsight caches insight and forceRefresh updates it', () async {
      final appState = AppState();
      expect(appState.cachedAiInsight, isNull);

      final insight1 = await appState.fetchNextWorkoutInsight();
      expect(insight1, isNotNull);
      expect(appState.cachedAiInsight, isNotNull);
      expect(appState.cachedAiInsight!['reason'], isNotNull);

      // Subsequent call without forceRefresh returns cached value
      final insight2 = await appState.fetchNextWorkoutInsight(forceRefresh: false);
      expect(identical(insight1, insight2), isTrue);

      // Model switch clears cache
      await appState.setAiModel('openai/gpt-4o-mini');
      expect(appState.cachedAiInsight, isNull);
    });
  });
}
