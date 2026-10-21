class FoodAiException implements Exception {
  final String message;
  final String? code;

  FoodAiException(this.message, {this.code});

  @override
  String toString() => 'FoodAiException: $message ($code)';
}

class ScannedFoodResult {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final double confidence;
  final String categoryTag;
  final String healthTip;
  final String? imagePath;
  final bool isRealAi;

  ScannedFoodResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    this.confidence = 0.90,
    required this.categoryTag,
    required this.healthTip,
    this.imagePath,
    this.isRealAi = true,
  });

  /// Validate and sanitize raw AI response map safely
  factory ScannedFoodResult.fromAiResponse(
    Map<String, dynamic> json, {
    String? imagePath,
    bool isRealAi = true,
  }) {
    // 0. Check for explicit non-food rejection
    final isFood = json['isFood'];
    if (isFood == false || isFood == 'false') {
      final reason = json['error'] ?? json['reason'] ?? 'Object in the image could not be identified as food.';
      throw FoodAiException(
        'AI determined that this image is not valid food: $reason',
        code: 'NOT_FOOD',
      );
    }

    // 1. Food Name
    String name = (json['foodName'] ?? json['name'] ?? json['title'] ?? '').toString().trim();
    if (name.isEmpty) {
      name = 'Identified Meal';
    }

    if (name.toLowerCase().contains('bukan makanan') || name.toLowerCase().contains('not food')) {
      throw FoodAiException(
        'AI detected that this image is not a food item. Please take a photo of valid food.',
        code: 'NOT_FOOD',
      );
    }

    // 2. Calories
    final rawCal = json['calories'];
    int parsedCal = 0;
    if (rawCal is num) {
      parsedCal = rawCal.toInt();
    } else if (rawCal is String) {
      final match = RegExp(r'-?\d+').firstMatch(rawCal);
      parsedCal = int.tryParse(match?.group(0) ?? '') ?? 0;
    }
    // Reject negative or sanitize extreme
    if (parsedCal < 0) parsedCal = 0;
    if (parsedCal > 5000) parsedCal = 5000;

    // 3. Protein
    double parseMacro(dynamic val) {
      if (val is num) return val.toDouble().clamp(0.0, 500.0);
      if (val is String) {
        final match = RegExp(r'(-?\d+(\.\d+)?)').firstMatch(val);
        if (match != null) {
          return (double.tryParse(match.group(1)!) ?? 0.0).clamp(0.0, 500.0);
        }
      }
      return 0.0;
    }

    final parsedProtein = parseMacro(json['protein'] ?? json['proteinGrams']);
    final parsedCarbs = parseMacro(json['carbs'] ?? json['carbohydrates'] ?? json['carbsGrams']);
    final parsedFat = parseMacro(json['fat'] ?? json['fatGrams']);

    // 4. Serving Size
    String serving = (json['servingSize'] ?? json['portion'] ?? '1 serving (~300g)').toString();

    // 5. Confidence
    double conf = 0.85;
    if (json['confidence'] is num) {
      conf = (json['confidence'] as num).toDouble();
      if (conf < 0.25) {
        throw FoodAiException(
          'AI confidence level is too low (${(conf * 100).toInt()}%). Please take a clearer photo.',
          code: 'LOW_CONFIDENCE',
        );
      }
      conf = conf.clamp(0.0, 1.0);
    }

    // 6. Tag & Health Tip
    String tag = (json['categoryTag'] ?? json['category'] ?? '').toString();
    if (tag.isEmpty) {
      if (parsedProtein >= 30) {
        tag = 'High Protein';
      } else if (parsedCal > 600) {
        tag = 'High Calorie';
      } else if (parsedFat <= 10 && parsedCal < 400) {
        tag = 'Low Fat';
      } else {
        tag = 'Balanced';
      }
    }

    String tip = (json['healthTip'] ?? json['tip'] ?? 'Balanced nutritional combination for daily energy.').toString();

    return ScannedFoodResult(
      foodName: name,
      calories: parsedCal,
      protein: parsedProtein,
      carbs: parsedCarbs,
      fat: parsedFat,
      servingSize: serving,
      confidence: conf,
      categoryTag: tag,
      healthTip: tip,
      imagePath: imagePath,
      isRealAi: isRealAi,
    );
  }
}
