import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/models/fitness_goal.dart';
import 'package:fitquest/models/user_profile.dart';
import 'package:fitquest/core/services/ai_engine_service.dart';

void main() {
  group('FitnessGoal Domain Tests', () {
    test('FitnessGoal contains all 4 goals including Improve Endurance', () {
      expect(FitnessGoal.values.length, 4);
      expect(FitnessGoal.values, contains(FitnessGoal.improveEndurance));
      expect(FitnessGoal.values, contains(FitnessGoal.weightLoss));
      expect(FitnessGoal.values, contains(FitnessGoal.muscleGain));
      expect(FitnessGoal.values, contains(FitnessGoal.generalFitness));
    });

    test('FitnessGoal.fromString parses case-insensitively and handles fallback', () {
      expect(FitnessGoal.fromString('Improve Endurance'), FitnessGoal.improveEndurance);
      expect(FitnessGoal.fromString('improve endurance'), FitnessGoal.improveEndurance);
      expect(FitnessGoal.fromString('endurance'), FitnessGoal.improveEndurance);
      expect(FitnessGoal.fromString('Weight Loss'), FitnessGoal.weightLoss);
      expect(FitnessGoal.fromString('Muscle Gain'), FitnessGoal.muscleGain);
      expect(FitnessGoal.fromString('General Fitness'), FitnessGoal.generalFitness);
      expect(FitnessGoal.fromString('unknown_goal'), FitnessGoal.generalFitness);
      expect(FitnessGoal.fromString(null), FitnessGoal.generalFitness);
    });

    test('Improve Endurance has valid title, icon, and description', () {
      const goal = FitnessGoal.improveEndurance;
      expect(goal.title, 'Improve Endurance');
      expect(goal.icon, '⚡');
      expect(goal.description, contains('Cardio'));
      expect(goal.id, 'Improve Endurance');
    });

    test('AiEngineService generates endurance-specific BMI insight', () {
      final profile = UserProfile(
        uid: 'test_user',
        name: 'Runner',
        email: 'runner@test.com',
        gender: 'Male',
        age: 25,
        height: 175.0,
        weight: 68.0, // Normal BMI ~22.2
        activityLevel: 'Active',
        fitnessGoal: 'Improve Endurance',
        commitDays: 4,
      );

      final insight = AiEngineService.generateBmiInsight(profile);
      expect(insight, contains('cardiovascular'));
      expect(insight, contains('VO2 max'));
    });

    test('AiEngineService coach reply provides endurance-specific advice', () {
      final profile = UserProfile(
        uid: 'test_user',
        name: 'Runner',
        email: 'runner@test.com',
        gender: 'Male',
        age: 25,
        height: 175.0,
        weight: 68.0,
        activityLevel: 'Active',
        fitnessGoal: 'Improve Endurance',
        commitDays: 4,
      );

      final reply = AiEngineService.generateCoachReply('How can I improve my running stamina?', profile);
      expect(reply, contains('stamina'));
      expect(reply, contains('cardio'));
    });

    test('AiEngineService generates personalized plan tailored for Improve Endurance', () {
      final profile = UserProfile(
        uid: 'test_user',
        name: 'Runner',
        email: 'runner@test.com',
        gender: 'Male',
        age: 25,
        height: 175.0,
        weight: 68.0,
        activityLevel: 'Active',
        fitnessGoal: 'Improve Endurance',
        commitDays: 4,
      );

      final plan = AiEngineService.generatePersonalizedPlan(profile);
      expect(plan.title, contains('Improve Endurance'));
      expect(plan.rationale, contains('Endurance'));
      final workoutTitles = plan.schedule.map((d) => d.title).toList();
      expect(workoutTitles, contains('Cardio Stamina Circuit'));
      expect(workoutTitles, contains('HIIT Aerobic Intervals'));
      expect(workoutTitles, contains('Lower Body Stamina'));
    });
  });
}
