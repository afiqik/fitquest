import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/models/nutrition_data.dart';

void main() {
  group('Water Tracking Domain Tests', () {
    test('WaterIntake model serialization and deserialization', () {
      final now = DateTime.now();
      final intake = WaterIntake(
        id: 'w123',
        userId: 'user_aiman',
        date: '2026-09-16',
        amountMl: 250,
        timestamp: now,
        source: 'quick_add',
      );

      final map = intake.toMap();
      expect(map['id'], 'w123');
      expect(map['amountMl'], 250);
      expect(map['source'], 'quick_add');

      final fromMap = WaterIntake.fromMap(map);
      expect(fromMap.id, 'w123');
      expect(fromMap.amountMl, 250);
      expect(fromMap.userId, 'user_aiman');
    });

    test('DailyNutrition water progress and percentage calculations', () {
      final n = DailyNutrition(
        waterCurrentMl: 1500,
        waterTargetMl: 2000,
      );

      expect(n.waterProgress, 0.75);
      expect(n.waterPercentage, 75);
      expect(n.waterGlasses, 6); // 1500 / 250 = 6 glasses
    });

    test('DailyNutrition handles zero and overflow water bounds safely', () {
      final zero = DailyNutrition(
        waterCurrentMl: 0,
        waterTargetMl: 2000,
      );
      expect(zero.waterProgress, 0.0);
      expect(zero.waterPercentage, 0);

      final over = DailyNutrition(
        waterCurrentMl: 3000,
        waterTargetMl: 2000,
      );
      expect(over.waterProgress, 1.0); // clamped to 1.0
      expect(over.waterPercentage, 100);
    });

    test('DailyNutrition recalculateTotals aggregates waterIntakes correctly', () {
      final now = DateTime.now();
      final intakes = [
        WaterIntake(id: 'w1', userId: 'u1', date: '2026-09-16', amountMl: 250, timestamp: now),
        WaterIntake(id: 'w2', userId: 'u1', date: '2026-09-16', amountMl: 500, timestamp: now),
        WaterIntake(id: 'w3', userId: 'u1', date: '2026-09-16', amountMl: 150, timestamp: now),
      ];

      final nutrition = DailyNutrition(
        waterCurrentMl: 0,
        waterTargetMl: 2000,
        waterIntakes: intakes,
      ).recalculateTotals();

      expect(nutrition.waterCurrentMl, 900);
      expect(nutrition.waterPercentage, 45);
    });

    test('recalculateTotals does NOT wipe out waterCurrentMl when waterIntakes is empty', () {
      final initial = DailyNutrition(
        waterCurrentMl: 1600,
        waterTargetMl: 2000,
        waterIntakes: const [],
      );

      final recalculated = initial.recalculateTotals();
      expect(recalculated.waterCurrentMl, 1600);
    });

    test('WaterIntake supports updatedAt and copyWith', () {
      final intake = WaterIntake(
        id: 'w_test',
        userId: 'u1',
        date: '2026-09-16',
        amountMl: 250,
        timestamp: DateTime.now(),
      );

      final modified = intake.copyWith(amountMl: 100);
      expect(modified.amountMl, 100);
      expect(modified.id, 'w_test');
    });
  });
}
