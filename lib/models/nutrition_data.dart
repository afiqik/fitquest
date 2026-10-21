import 'package:intl/intl.dart';

class MealItem {
  final String id;
  final String name;
  final String tag;
  final String meta;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final String icon;
  final String? imagePath;
  final DateTime loggedAt;

  MealItem({
    required this.id,
    required this.name,
    required this.tag,
    required this.meta,
    required this.calories,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.servingSize = '1 serving',
    this.icon = '🍽️',
    this.imagePath,
    required this.loggedAt,
  });

  String get formattedTime => DateFormat('h:mm a').format(loggedAt);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'meta': meta,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSize': servingSize,
      'icon': icon,
      'imagePath': imagePath,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  factory MealItem.fromMap(Map<String, dynamic> map) {
    return MealItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      tag: map['tag']?.toString() ?? 'MEAL',
      meta: map['meta']?.toString() ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      servingSize: map['servingSize']?.toString() ?? '1 serving',
      icon: map['icon']?.toString() ?? '🍽️',
      imagePath: map['imagePath']?.toString(),
      loggedAt: map['loggedAt'] != null
          ? DateTime.tryParse(map['loggedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MealItem copyWith({
    String? id,
    String? name,
    String? tag,
    String? meta,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? servingSize,
    String? icon,
    String? imagePath,
    DateTime? loggedAt,
  }) {
    return MealItem(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      meta: meta ?? this.meta,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      servingSize: servingSize ?? this.servingSize,
      icon: icon ?? this.icon,
      imagePath: imagePath ?? this.imagePath,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}

class WaterIntake {
  final String id;
  final String userId;
  final String date;
  final int amountMl;
  final DateTime timestamp;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  WaterIntake({
    required this.id,
    required this.userId,
    required this.date,
    required this.amountMl,
    required this.timestamp,
    this.source = 'quick_add',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  WaterIntake copyWith({
    String? id,
    String? userId,
    String? date,
    int? amountMl,
    DateTime? timestamp,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      amountMl: (map['amountMl'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      source: map['source']?.toString() ?? 'quick_add',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class DailyNutrition {
  final String date;
  final int targetCalories;
  final int consumedCalories;
  final double proteinGrams;
  final double targetProteinGrams;
  final double carbsGrams;
  final double targetCarbsGrams;
  final double fatGrams;
  final double targetFatGrams;
  final int waterCurrentMl;
  final int waterTargetMl;
  final List<MealItem> meals;
  final List<WaterIntake> waterIntakes;

  DailyNutrition({
    String? date,
    this.targetCalories = 2180,
    this.consumedCalories = 1180,
    this.proteinGrams = 84.0,
    this.targetProteinGrams = 140.0,
    this.carbsGrams = 145.0,
    this.targetCarbsGrams = 220.0,
    this.fatGrams = 38.0,
    this.targetFatGrams = 65.0,
    this.waterCurrentMl = 1500,
    this.waterTargetMl = 2000,
    this.meals = const [],
    this.waterIntakes = const [],
  }) : date = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get remainingCalories => (targetCalories - consumedCalories).clamp(0, 99999);
  double get calorieProgress => targetCalories > 0 ? (consumedCalories / targetCalories).clamp(0.0, 1.0) : 0.0;
  double get waterProgress => waterTargetMl > 0 ? (waterCurrentMl / waterTargetMl).clamp(0.0, 1.0) : 0.0;
  int get waterPercentage => (waterProgress * 100).round();

  // Backward compatibility getter for older widgets if referenced
  int get waterGlasses => (waterCurrentMl / 250).round().clamp(0, 8);

  DailyNutrition recalculateTotals() {
    int totalCal = 0;
    double totalP = 0.0;
    double totalC = 0.0;
    double totalF = 0.0;

    for (final m in meals) {
      totalCal += m.calories;
      totalP += m.protein;
      totalC += m.carbs;
      totalF += m.fat;
    }

    final totalWater = waterIntakes.fold<int>(0, (sum, item) => sum + item.amountMl);

    return copyWith(
      consumedCalories: totalCal,
      proteinGrams: totalP,
      carbsGrams: totalC,
      fatGrams: totalF,
      waterCurrentMl: waterIntakes.isNotEmpty ? totalWater : waterCurrentMl,
    );
  }

  DailyNutrition copyWith({
    String? date,
    int? targetCalories,
    int? consumedCalories,
    double? proteinGrams,
    double? targetProteinGrams,
    double? carbsGrams,
    double? targetCarbsGrams,
    double? fatGrams,
    double? targetFatGrams,
    int? waterCurrentMl,
    int? waterTargetMl,
    List<MealItem>? meals,
    List<WaterIntake>? waterIntakes,
  }) {
    return DailyNutrition(
      date: date ?? this.date,
      targetCalories: targetCalories ?? this.targetCalories,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      targetProteinGrams: targetProteinGrams ?? this.targetProteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      targetCarbsGrams: targetCarbsGrams ?? this.targetCarbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      targetFatGrams: targetFatGrams ?? this.targetFatGrams,
      waterCurrentMl: waterCurrentMl ?? this.waterCurrentMl,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
      meals: meals ?? this.meals,
      waterIntakes: waterIntakes ?? this.waterIntakes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'targetCalories': targetCalories,
      'consumedCalories': consumedCalories,
      'proteinGrams': proteinGrams,
      'targetProteinGrams': targetProteinGrams,
      'carbsGrams': carbsGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'fatGrams': fatGrams,
      'targetFatGrams': targetFatGrams,
      'waterCurrentMl': waterCurrentMl,
      'waterTargetMl': waterTargetMl,
      'meals': meals.map((m) => m.toMap()).toList(),
      'waterIntakes': waterIntakes.map((w) => w.toMap()).toList(),
    };
  }

  factory DailyNutrition.fromMap(Map<String, dynamic> map) {
    final rawMeals = map['meals'] as List<dynamic>? ?? [];
    final rawWater = map['waterIntakes'] as List<dynamic>? ?? [];

    return DailyNutrition(
      date: map['date']?.toString(),
      targetCalories: (map['targetCalories'] as num?)?.toInt() ?? 2180,
      consumedCalories: (map['consumedCalories'] as num?)?.toInt() ?? 0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      targetProteinGrams: (map['targetProteinGrams'] as num?)?.toDouble() ?? 140.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      targetCarbsGrams: (map['targetCarbsGrams'] as num?)?.toDouble() ?? 220.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      targetFatGrams: (map['targetFatGrams'] as num?)?.toDouble() ?? 65.0,
      waterCurrentMl: (map['waterCurrentMl'] as num?)?.toInt() ?? 0,
      waterTargetMl: (map['waterTargetMl'] as num?)?.toInt() ?? 2000,
      meals: rawMeals
          .whereType<Map<String, dynamic>>()
          .map((m) => MealItem.fromMap(m))
          .toList(),
      waterIntakes: rawWater
          .whereType<Map<String, dynamic>>()
          .map((w) => WaterIntake.fromMap(w))
          .toList(),
    );
  }
}
