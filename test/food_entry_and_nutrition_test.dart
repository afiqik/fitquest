import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/models/nutrition_data.dart';

void main() {
  group('Food Entry & Nutrition Calculations Tests', () {
    test('MealItem serialization and formatted time', () {
      final loggedTime = DateTime(2026, 9, 16, 13, 15);
      final meal = MealItem(
        id: 'm1',
        name: 'Nasi Ayam Panggang',
        tag: 'MAKAN TENGAH HARI',
        meta: 'P 42g · C 65g · F 16g',
        calories: 580,
        protein: 42.0,
        carbs: 65.0,
        fat: 16.0,
        servingSize: '1 pinggan standard (~350g)',
        icon: '🍗',
        loggedAt: loggedTime,
      );

      expect(meal.formattedTime, '1:15 PM');
      final map = meal.toMap();
      expect(map['calories'], 580);
      expect(map['protein'], 42.0);

      final deserialized = MealItem.fromMap(map);
      expect(deserialized.id, 'm1');
      expect(deserialized.name, 'Nasi Ayam Panggang');
      expect(deserialized.calories, 580);
      expect(deserialized.protein, 42.0);
      expect(deserialized.carbs, 65.0);
      expect(deserialized.fat, 16.0);
    });

    test('DailyNutrition recalculateTotals dynamically sums calories and macros', () {
      final meals = [
        MealItem(
          id: 'm1',
          name: 'Oatmeal & Pisang',
          tag: 'SARAPAN',
          meta: 'meta1',
          calories: 340,
          protein: 14.0,
          carbs: 58.0,
          fat: 6.0,
          loggedAt: DateTime.now(),
        ),
        MealItem(
          id: 'm2',
          name: 'Nasi Ayam',
          tag: 'LUNCH',
          meta: 'meta2',
          calories: 580,
          protein: 42.0,
          carbs: 65.0,
          fat: 16.0,
          loggedAt: DateTime.now(),
        ),
        MealItem(
          id: 'm3',
          name: 'Protein Shake',
          tag: 'SNACK',
          meta: 'meta3',
          calories: 260,
          protein: 28.0,
          carbs: 22.0,
          fat: 3.0,
          loggedAt: DateTime.now(),
        ),
      ];

      final daily = DailyNutrition(
        targetCalories: 2180,
        consumedCalories: 0,
        proteinGrams: 0,
        carbsGrams: 0,
        fatGrams: 0,
        meals: meals,
      ).recalculateTotals();

      expect(daily.consumedCalories, 1180); // 340 + 580 + 260
      expect(daily.proteinGrams, 84.0); // 14 + 42 + 28
      expect(daily.carbsGrams, 145.0); // 58 + 65 + 22
      expect(daily.fatGrams, 25.0); // 6 + 16 + 3
      expect(daily.remainingCalories, 1000); // 2180 - 1180
      expect(daily.calorieProgress, closeTo(1180 / 2180, 0.001));
    });

    test('Remaining calories clamps to zero when consumed exceeds target', () {
      final daily = DailyNutrition(
        targetCalories: 2000,
        consumedCalories: 2500,
      );
      expect(daily.remainingCalories, 0);
      expect(daily.calorieProgress, 1.0);
    });
  });
}
