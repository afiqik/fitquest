import 'exercise_item.dart';

class ScheduledWorkoutDay {
  final String dayOfWeek; // ISN, SEL, RAB, KHA, JUM, SAB, AHD
  final String dateNumber; // 11, 12, 13...
  final String title;
  final String meta;
  final String state; // 'done', 'today', 'rest', 'next'
  final int durationMinutes;
  final int estimatedCalories;
  final String aiRationale;
  final List<ExerciseItem> exercises;

  ScheduledWorkoutDay({
    required this.dayOfWeek,
    required this.dateNumber,
    required this.title,
    required this.meta,
    required this.state,
    this.durationMinutes = 32,
    this.estimatedCalories = 410,
    this.aiRationale = 'Low-impact circuit designed for safe heart rate and current weight conditioning.',
    this.exercises = const [],
  });

  ScheduledWorkoutDay copyWith({
    String? dayOfWeek,
    String? dateNumber,
    String? title,
    String? meta,
    String? state,
    int? durationMinutes,
    int? estimatedCalories,
    String? aiRationale,
    List<ExerciseItem>? exercises,
  }) {
    return ScheduledWorkoutDay(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dateNumber: dateNumber ?? this.dateNumber,
      title: title ?? this.title,
      meta: meta ?? this.meta,
      state: state ?? this.state,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      aiRationale: aiRationale ?? this.aiRationale,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'dateNumber': dateNumber,
      'title': title,
      'meta': meta,
      'state': state,
      'durationMinutes': durationMinutes,
      'estimatedCalories': estimatedCalories,
      'aiRationale': aiRationale,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory ScheduledWorkoutDay.fromMap(Map<String, dynamic> map) {
    return ScheduledWorkoutDay(
      dayOfWeek: map['dayOfWeek'] ?? 'MON',
      dateNumber: map['dateNumber'] ?? '01',
      title: map['title'] ?? 'Workout',
      meta: map['meta'] ?? '',
      state: map['state'] ?? 'next',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 32,
      estimatedCalories: (map['estimatedCalories'] as num?)?.toInt() ?? 410,
      aiRationale: map['aiRationale'] ?? '',
      exercises: () {
        final raw = map['exercises'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) => ExerciseItem.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        } else if (raw is Map) {
          return raw.values
              .whereType<Map>()
              .map((e) => ExerciseItem.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <ExerciseItem>[];
      }(),
    );
  }
}

class WorkoutPlan {
  final String planId;
  final String userId;
  final String title;
  final String rationale;
  final int totalWeeks;
  final int currentWeek;
  final List<ScheduledWorkoutDay> schedule;
  final DateTime createdAt;

  WorkoutPlan({
    required this.planId,
    required this.userId,
    required this.title,
    required this.rationale,
    this.totalWeeks = 4,
    this.currentWeek = 1,
    required this.schedule,
    required this.createdAt,
  });

  WorkoutPlan copyWith({
    String? planId,
    String? userId,
    String? title,
    String? rationale,
    int? totalWeeks,
    int? currentWeek,
    List<ScheduledWorkoutDay>? schedule,
    DateTime? createdAt,
  }) {
    return WorkoutPlan(
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      rationale: rationale ?? this.rationale,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      currentWeek: currentWeek ?? this.currentWeek,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ScheduledWorkoutDay? get todayWorkout {
    try {
      return schedule.firstWhere((d) => d.state == 'today');
    } catch (_) {
      return schedule.isNotEmpty ? schedule.first : null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'userId': userId,
      'title': title,
      'rationale': rationale,
      'totalWeeks': totalWeeks,
      'currentWeek': currentWeek,
      'schedule': schedule.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      planId: map['planId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'FitQuest 4-Week Plan',
      rationale: map['rationale'] ?? '',
      totalWeeks: (map['totalWeeks'] as num?)?.toInt() ?? 4,
      currentWeek: (map['currentWeek'] as num?)?.toInt() ?? 1,
      schedule: () {
        final raw = map['schedule'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((d) => ScheduledWorkoutDay.fromMap(Map<String, dynamic>.from(d)))
              .toList();
        } else if (raw is Map) {
          return raw.values
              .whereType<Map>()
              .map((d) => ScheduledWorkoutDay.fromMap(Map<String, dynamic>.from(d)))
              .toList();
        }
        return <ScheduledWorkoutDay>[];
      }(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
