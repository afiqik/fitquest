import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/core/ai/scanned_food_result.dart';
import 'package:fitquest/features/nutrition/food_scanner_controller.dart';

void main() {
  group('AI Food Scanner Model & Validation Tests', () {
    test('ScannedFoodResult.fromAiResponse parses clean valid JSON', () {
      final json = {
        'foodName': 'Salmon Panggang & Brokoli',
        'calories': 520,
        'protein': 38.0,
        'carbs': 18.0,
        'fat': 22.0,
        'servingSize': '1 hidangan (~300g)',
        'confidence': 0.95,
        'categoryTag': 'Tinggi Protein',
        'healthTip': 'Kaya asid lemak sihat.',
      };

      final result = ScannedFoodResult.fromAiResponse(json, isRealAi: true);
      expect(result.foodName, 'Salmon Panggang & Brokoli');
      expect(result.calories, 520);
      expect(result.protein, 38.0);
      expect(result.carbs, 18.0);
      expect(result.fat, 22.0);
      expect(result.confidence, 0.95);
      expect(result.isRealAi, true);
    });

    test('ScannedFoodResult sanitizes negative or string values safely', () {
      final json = {
        'foodName': '',
        'calories': -150, // negative should clamp to 0
        'protein': '-30g',
        'carbs': '45.5 g',
        'fat': '12',
      };

      final result = ScannedFoodResult.fromAiResponse(json);
      expect(result.foodName, 'Identified Meal');
      expect(result.calories, 0); // sanitized
      expect(result.protein, 0.0); // negative string rejected/clamped
      expect(result.carbs, 45.5); // string parsed safely
      expect(result.fat, 12.0);
    });

    test('ScannedFoodResult auto-generates categoryTag if missing', () {
      final highProtein = ScannedFoodResult.fromAiResponse({
        'foodName': 'Chicken Breast',
        'calories': 300,
        'protein': 35.0,
      });
      expect(highProtein.categoryTag, 'High Protein');

      final highCalorie = ScannedFoodResult.fromAiResponse({
        'foodName': 'Biryani Rice',
        'calories': 850,
        'protein': 20.0,
      });
      expect(highCalorie.categoryTag, 'High Calorie');
    });

    test('ScannedFoodResult throws FoodAiException when AI flags image as not food', () {
      expect(
        () => ScannedFoodResult.fromAiResponse({
          'isFood': false,
          'error': 'Gambar kasut sukan dikesan.',
        }),
        throwsA(isA<FoodAiException>().having((e) => e.code, 'code', 'NOT_FOOD')),
      );

      expect(
        () => ScannedFoodResult.fromAiResponse({
          'foodName': 'Bukan Makanan',
          'calories': 0,
        }),
        throwsA(isA<FoodAiException>().having((e) => e.code, 'code', 'NOT_FOOD')),
      );
    });

    test('ScannedFoodResult throws FoodAiException when confidence is excessively low', () {
      expect(
        () => ScannedFoodResult.fromAiResponse({
          'foodName': 'Objek Samar',
          'confidence': 0.15,
        }),
        throwsA(isA<FoodAiException>().having((e) => e.code, 'code', 'LOW_CONFIDENCE')),
      );
    });
  });

  group('FoodScannerController State Machine Tests', () {
    test('Initial state is idle', () {
      final controller = FoodScannerController();
      expect(controller.state, FoodScannerState.idle);
      expect(controller.selectedImage, isNull);
      expect(controller.result, isNull);
      expect(controller.errorMessage, isNull);
      controller.dispose();
    });

    test('cancel() sets state to cancelled', () {
      final controller = FoodScannerController();
      controller.cancel();
      expect(controller.state, FoodScannerState.cancelled);
      controller.dispose();
    });

    test('reset() restores idle state and clears data', () {
      final controller = FoodScannerController();
      controller.cancel();
      expect(controller.state, FoodScannerState.cancelled);

      controller.reset();
      expect(controller.state, FoodScannerState.idle);
      expect(controller.selectedImage, isNull);
      expect(controller.result, isNull);
      controller.dispose();
    });
  });
}
