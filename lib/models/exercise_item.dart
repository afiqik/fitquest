class ExerciseItem {
  final String id;
  final String number;
  final String name;
  final String targetMuscle;
  final int sets;
  final int reps;
  final int durationSeconds;
  final int restSeconds;
  final String meta;
  final String durationText;
  final bool isCompleted;

  ExerciseItem({
    required this.id,
    required this.number,
    required this.name,
    this.targetMuscle = 'Full Body',
    this.sets = 3,
    this.reps = 12,
    this.durationSeconds = 45,
    this.restSeconds = 30,
    required this.meta,
    required this.durationText,
    this.isCompleted = false,
  });

  ExerciseItem copyWith({
    String? id,
    String? number,
    String? name,
    String? targetMuscle,
    int? sets,
    int? reps,
    int? durationSeconds,
    int? restSeconds,
    String? meta,
    String? durationText,
    bool? isCompleted,
  }) {
    return ExerciseItem(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      meta: meta ?? this.meta,
      durationText: durationText ?? this.durationText,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'targetMuscle': targetMuscle,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'meta': meta,
      'durationText': durationText,
      'isCompleted': isCompleted,
    };
  }

  factory ExerciseItem.fromMap(Map<String, dynamic> map) {
    return ExerciseItem(
      id: map['id'] ?? '',
      number: map['number'] ?? '01',
      name: map['name'] ?? '',
      targetMuscle: map['targetMuscle'] ?? 'Full Body',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 12,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 45,
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 30,
      meta: map['meta'] ?? '',
      durationText: map['durationText'] ?? "2'15",
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
