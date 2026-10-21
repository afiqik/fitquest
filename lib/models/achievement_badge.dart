class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final String category; // Streak, Milestone, Consistency, Special
  final DateTime? unlockedAt;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.category = 'Milestone',
    this.unlockedAt,
  });

  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    String? category,
    DateTime? unlockedAt,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      category: category ?? this.category,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'category': category,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementBadge.fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏅',
      isUnlocked: map['isUnlocked'] ?? false,
      category: map['category'] ?? 'Milestone',
      unlockedAt: map['unlockedAt'] != null ? DateTime.tryParse(map['unlockedAt']) : null,
    );
  }

  static List<AchievementBadge> initial24Badges() {
    return [
      AchievementBadge(id: 'b1', title: 'First Step', description: 'Complete your very first workout.', icon: '🎯', isUnlocked: true),
      AchievementBadge(id: 'b2', title: 'Consistency 3', description: 'Maintain a 3-day workout streak.', icon: '🔥', isUnlocked: true),
      AchievementBadge(id: 'b3', title: 'Consistency 7', description: 'Seven days in a row. Your streak is alive.', icon: '🏅', isUnlocked: true),
      AchievementBadge(id: 'b4', title: 'Morning Warrior', description: 'Complete a workout before 8:00 AM.', icon: '🌅', isUnlocked: true),
      AchievementBadge(id: 'b5', title: 'Fat Burner', description: 'Burn over 1,000 calories in a single week.', icon: '⚡', isUnlocked: true),
      AchievementBadge(id: 'b6', title: 'Core Master', description: 'Complete 10 sets of abdominal core exercises.', icon: '🛡️', isUnlocked: true),
      AchievementBadge(id: 'b7', title: 'Hydration Hero', description: 'Hit your daily target of 8 glasses of water.', icon: '💧', isUnlocked: true),
      AchievementBadge(id: 'b8', title: 'Adaptive Mind', description: 'Use AI plan revision after an incomplete workout.', icon: '🤖', isUnlocked: true),
      // Remaining 16 to be unlocked
      AchievementBadge(id: 'b9', title: 'Consistency 14', description: 'Keep up your daily training for 14 straight days.', icon: '🏆'),
      AchievementBadge(id: 'b10', title: 'Consistency 30', description: 'A full month of non-stop consistency.', icon: '👑'),
      AchievementBadge(id: 'b11', title: 'Centurion', description: 'Complete 100 lifetime workout sessions.', icon: '💯'),
      AchievementBadge(id: 'b12', title: 'Iron Body', description: 'Accumulate 500 total push-ups.', icon: '🦾'),
      AchievementBadge(id: 'b13', title: 'Leg Day Hero', description: 'Complete 20 leg training sessions.', icon: '🦵'),
      AchievementBadge(id: 'b14', title: 'Plank King', description: 'Hold a plank for longer than 3 minutes.', icon: '⏱️'),
      AchievementBadge(id: 'b15', title: 'Night Owl', description: 'Finish an evening workout after 8:00 PM.', icon: '🌙'),
      AchievementBadge(id: 'b16', title: 'Calorie Crusher', description: 'Burn 5,000 total cumulative calories.', icon: '💥'),
      AchievementBadge(id: 'b17', title: 'Food Scanner Pro', description: 'Scan 15 meals using AI Food Vision.', icon: '📷'),
      AchievementBadge(id: 'b18', title: 'Macro Master', description: 'Hit your daily protein target 5 days in a row.', icon: '🥩'),
      AchievementBadge(id: 'b19', title: 'Coach Buddy', description: 'Chat with your AI Coach 10 times.', icon: '💬'),
      AchievementBadge(id: 'b20', title: 'Week 1 Champion', description: 'Complete all scheduled sessions in Week 1.', icon: '🌟'),
      AchievementBadge(id: 'b21', title: 'Week 4 Graduate', description: 'Complete the entire 4-week program.', icon: '🎓'),
      AchievementBadge(id: 'b22', title: 'Body Transformer', description: 'Log weight changes aligned with your goal.', icon: '⚖️'),
      AchievementBadge(id: 'b23', title: 'Zero Excuses', description: 'Complete a workout despite a packed schedule.', icon: '🧗'),
      AchievementBadge(id: 'b24', title: 'FitQuest Legend', description: 'Unlock all badges and achieve elite fitness status.', icon: '⭐'),
    ];
  }
}
