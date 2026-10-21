class WorkoutSession {
  final String sessionId;
  final String userId;
  final String workoutTitle;
  final int totalExercises;
  final int completedExercises;
  final int totalSets;
  final int durationSeconds;
  final int burnedCalories;
  final bool isCompleted;
  final String? incompleteReason; // time, fatigue, injury, other
  final String? incompleteNotes;
  final DateTime startedAt;
  final DateTime completedAt;

  WorkoutSession({
    required this.sessionId,
    required this.userId,
    required this.workoutTitle,
    required this.totalExercises,
    required this.completedExercises,
    required this.totalSets,
    required this.durationSeconds,
    required this.burnedCalories,
    required this.isCompleted,
    this.incompleteReason,
    this.incompleteNotes,
    required this.startedAt,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'workoutTitle': workoutTitle,
      'totalExercises': totalExercises,
      'completedExercises': completedExercises,
      'totalSets': totalSets,
      'durationSeconds': durationSeconds,
      'burnedCalories': burnedCalories,
      'isCompleted': isCompleted,
      'incompleteReason': incompleteReason,
      'incompleteNotes': incompleteNotes,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? '',
      workoutTitle: map['workoutTitle'] ?? 'Workout',
      totalExercises: (map['totalExercises'] as num?)?.toInt() ?? 0,
      completedExercises: (map['completedExercises'] as num?)?.toInt() ?? 0,
      totalSets: (map['totalSets'] as num?)?.toInt() ?? 0,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      burnedCalories: (map['burnedCalories'] as num?)?.toInt() ?? 0,
      isCompleted: map['isCompleted'] ?? true,
      incompleteReason: map['incompleteReason'],
      incompleteNotes: map['incompleteNotes'],
      startedAt: map['startedAt'] != null
          ? DateTime.tryParse(map['startedAt']) ?? DateTime.now()
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
