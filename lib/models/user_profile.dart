class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String gender;
  final int age;
  final double height; // cm
  final double weight; // kg
  final String activityLevel; // Sedentary, Light, Active
  final String fitnessGoal; // Weight Loss, Muscle Gain, General Fitness, Improve Endurance
  final int commitDays; // 2 - 7 days
  final int streakDays;
  final int completedWorkouts;
  final String? photoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    this.email = '',
    this.gender = 'Male',
    this.age = 22,
    this.height = 170.0,
    this.weight = 70.0,
    this.activityLevel = 'Sedentary',
    this.fitnessGoal = 'Weight Loss',
    this.commitDays = 4,
    this.streakDays = 1,
    this.completedWorkouts = 0,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
  });

  double get bmi {
    if (height <= 0) return 0.0;
    final hInM = height / 100.0;
    return weight / (hInM * hInM);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? activityLevel,
    String? fitnessGoal,
    int? commitDays,
    int? streakDays,
    int? completedWorkouts,
    String? photoPath,
    bool clearPhoto = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      commitDays: commitDays ?? this.commitDays,
      streakDays: streakDays ?? this.streakDays,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'fitnessGoal': fitnessGoal,
      'commitDays': commitDays,
      'streakDays': streakDays,
      'completedWorkouts': completedWorkouts,
      'photoPath': photoPath,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? 'FitQuest User',
      email: map['email'] ?? '',
      gender: map['gender'] ?? 'Male',
      age: (map['age'] as num?)?.toInt() ?? 22,
      height: (map['height'] as num?)?.toDouble() ?? 170.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 70.0,
      activityLevel: map['activityLevel'] ?? 'Sedentary',
      fitnessGoal: map['fitnessGoal'] ?? 'Weight Loss',
      commitDays: (map['commitDays'] as num?)?.toInt() ?? 4,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 1,
      completedWorkouts: (map['completedWorkouts'] as num?)?.toInt() ?? 0,
      photoPath: map['photoPath'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }
}
