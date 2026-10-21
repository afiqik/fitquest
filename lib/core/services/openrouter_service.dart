import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../../models/workout_session.dart';
import '../../models/workout_plan.dart';
import '../../models/chat_message.dart';
import 'ai_engine_service.dart';

class OpenRouterModel {
  final String id;
  final String name;
  final String provider;
  final String description;
  final String icon;
  final bool isDefault;

  const OpenRouterModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.icon,
    this.isDefault = false,
  });
}

class OpenRouterService {
  // Supplied at build via --dart-define=OPENROUTER_API_KEY. Never hardcode a live key.
  static const String defaultApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY');
  static const String defaultModelId = 'google/gemini-2.0-flash-001';

  static const String _prefsKeyApiKey = 'openrouter_api_key';
  static const String _prefsKeyModel = 'openrouter_selected_model';

  static const List<OpenRouterModel> availableModels = [
    OpenRouterModel(
      id: 'google/gemini-2.0-flash-001',
      name: 'Gemini 2.0 Flash',
      provider: 'Google',
      description: 'Fast, deep analytics & scientifically-backed insights',
      icon: '⚡',
      isDefault: true,
    ),
    OpenRouterModel(
      id: 'deepseek/deepseek-chat',
      name: 'DeepSeek V3',
      provider: 'DeepSeek',
      description: 'Sharp reasoning, adaptive workouts & casual tone',
      icon: '🧠',
    ),
    OpenRouterModel(
      id: 'openai/gpt-4o-mini',
      name: 'GPT-4o Mini',
      provider: 'OpenAI',
      description: 'Balanced, fast, and high-energy for fitness motivation',
      icon: '🔥',
    ),
    OpenRouterModel(
      id: 'anthropic/claude-3.5-haiku',
      name: 'Claude 3.5 Haiku',
      provider: 'Anthropic',
      description: 'Nuanced language, empathetic and disciplined coaching',
      icon: '🌿',
    ),
    OpenRouterModel(
      id: 'meta-llama/llama-3.3-70b-instruct',
      name: 'Llama 3.3 70B',
      provider: 'Meta',
      description: 'High-performance open weights model & meticulous plans',
      icon: '🦙',
    ),
  ];

  String _apiKey = defaultApiKey;
  String _selectedModel = defaultModelId;

  String get apiKey => _apiKey;
  String get selectedModel => _selectedModel;

  OpenRouterModel get currentModelObj {
    return availableModels.firstWhere(
      (m) => m.id == _selectedModel,
      orElse: () => availableModels.first,
    );
  }

  OpenRouterService() {
    _loadPreferences();
  }

  Future<void> initPreferences() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(_prefsKeyApiKey) ?? defaultApiKey;
      _selectedModel = prefs.getString(_prefsKeyModel) ?? defaultModelId;
    } catch (e) {
      debugPrint('FitQuest OpenRouter load prefs notice: $e');
    }
  }

  /// Maps model IDs to their live OpenRouter API endpoints
  static String resolveActiveModelEndpoint(String modelId) {
    switch (modelId) {
      case 'google/gemini-2.0-flash-001':
        return 'google/gemini-2.5-flash';
      case 'anthropic/claude-3.5-haiku':
        return 'anthropic/claude-haiku-4.5';
      default:
        return modelId;
    }
  }

  Future<void> setModel(String modelId) async {
    _selectedModel = modelId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyModel, modelId);
    } catch (e) {
      debugPrint('FitQuest OpenRouter setModel error: $e');
    }
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim().isEmpty ? defaultApiKey : key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyApiKey, _apiKey);
    } catch (e) {
      debugPrint('FitQuest OpenRouter setApiKey error: $e');
    }
  }

  /// Low-level chat completion call
  Future<String?> chatCompletion({
    required List<Map<String, String>> messages,
    String? model,
    double temperature = 0.7,
    int maxTokens = 600,
    Duration timeout = const Duration(seconds: 14),
  }) async {
    final activeKey = _apiKey.isNotEmpty ? _apiKey : defaultApiKey;
    final targetModel = model ?? _selectedModel;
    final activeModel = resolveActiveModelEndpoint(targetModel);

    try {
      final response = await http
          .post(
            Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $activeKey',
              'HTTP-Referer': 'https://fitquest.app',
              'X-Title': 'FitQuest AI Coach',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': activeModel,
              'messages': messages,
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']?['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      } else {
        debugPrint(
            'FitQuest OpenRouter API Error: HTTP ${response.statusCode} - ${response.body}');
        // If 404 or decommissioned, retry once with resilient Gemini 2.5 Flash endpoint
        if (response.statusCode == 404 && activeModel != 'google/gemini-2.5-flash') {
          return await chatCompletion(
            messages: messages,
            model: 'google/gemini-2.5-flash',
            temperature: temperature,
            maxTokens: maxTokens,
            timeout: timeout,
          );
        }
      }
    } catch (e) {
      debugPrint('FitQuest OpenRouter network / timeout error: $e');
    }
    return null;
  }

  /// AI Coach Chat with OpenRouter and offline fallback
  Future<String> generateCoachReply({
    required String userMessage,
    required UserProfile profile,
    required List<ChatMessage> chatHistory,
    required String language,
  }) async {
    final systemPrompt =
        'You are FitQuest AI Coach, an expert elite fitness trainer and sports science specialist. '
        'User Profile: Name: ${profile.name}, Age: ${profile.age}, Gender: ${profile.gender}, '
        'Weight: ${profile.weight} kg, Height: ${profile.height} cm, BMI: ${profile.bmi.toStringAsFixed(1)}, '
        'Goal: ${profile.fitnessGoal}, Commit: ${profile.commitDays} days/week, Streak: ${profile.streakDays} days, Completed Workouts: ${profile.completedWorkouts}. '
        'Tone: Encouraging, energetic, scientifically grounded, friendly and concise (max 3-4 sentences). '
        'Reply in fluent English.';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add recent conversation context (last 4 messages)
    final recent = chatHistory.length > 4 ? chatHistory.sublist(chatHistory.length - 4) : chatHistory;
    for (final m in recent) {
      messages.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      });
    }

    messages.add({'role': 'user', 'content': userMessage});

    final openRouterReply = await chatCompletion(
      messages: messages,
      temperature: 0.7,
      maxTokens: 400,
    );

    if (openRouterReply != null && openRouterReply.isNotEmpty) {
      return openRouterReply;
    }

    // Graceful offline fallback
    return AiEngineService.generateCoachReply(userMessage, profile);
  }

  /// Generate Reason & Motivation for Next Workout with OpenRouter and offline fallback
  Future<Map<String, String>> generateNextWorkoutInsight({
    required List<WorkoutSession> history,
    required UserProfile profile,
    required String language,
    WorkoutPlan? plan,
  }) async {
    final fallback = AiEngineService.generateNextWorkoutInsight(
      history: history,
      profile: profile,
      language: language,
      plan: plan,
    );

    final lastSession = history.isNotEmpty ? history.first : null;
    final nextWorkoutTitle = fallback['nextWorkoutTitle'] ?? 'Next Session';

    final prompt =
        'As FitQuest sports science AI, analyze this athlete\'s progression:\n'
        '- Athlete: ${profile.name}, Goal: ${profile.fitnessGoal}, BMI: ${profile.bmi.toStringAsFixed(1)}, Streak: ${profile.streakDays} days\n'
        '- Previous Workout: ${lastSession?.workoutTitle ?? "None (Fresh start)"} (Burned: ${lastSession?.burnedCalories ?? 0} kcal)\n'
        '- Upcoming Scheduled Workout: $nextWorkoutTitle\n'
        'Provide JSON output with two keys:\n'
        '1. "reason": Explain in 2 sentences the physiological and biomechanical rationale for this next workout (muscle recovery window, metabolic adaptation, or kinetic balancing).\n'
        '2. "motivation": Write 1-2 punchy, inspirational sentences to rally the athlete for today\'s session.\n'
        'Return valid JSON only: {"reason": "...", "motivation": "..."}';

    final messages = [
      {
        'role': 'system',
        'content':
            'You are an elite sports physiologist and motivational strength coach. You only respond with JSON.'
      },
      {'role': 'user', 'content': prompt},
    ];

    try {
      final responseText = await chatCompletion(
        messages: messages,
        temperature: 0.6,
        maxTokens: 350,
      );

      if (responseText != null && responseText.isNotEmpty) {
        // Extract JSON if wrapped in markdown blocks
        String cleaned = responseText.trim();
        if (cleaned.startsWith('```')) {
          cleaned = cleaned.replaceAll(RegExp(r'^```[a-z]*\s*'), '');
          cleaned = cleaned.replaceAll(RegExp(r'\s*```$'), '');
        }

        final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
        final reason = parsed['reason'] as String?;
        final motivation = parsed['motivation'] as String?;

        if (reason != null &&
            reason.isNotEmpty &&
            motivation != null &&
            motivation.isNotEmpty) {
          return {
            'lastWorkoutTitle': fallback['lastWorkoutTitle'] ?? 'Recent Workout',
            'nextWorkoutTitle': fallback['nextWorkoutTitle'] ?? nextWorkoutTitle,
            'nextWorkoutMeta': fallback['nextWorkoutMeta'] ?? '32 min · 380 kcal',
            'reason': reason.trim(),
            'motivation': motivation.trim(),
          };
        }
      }
    } catch (e) {
      debugPrint('FitQuest OpenRouter NextWorkoutInsight error: $e');
    }

    return fallback;
  }
}
