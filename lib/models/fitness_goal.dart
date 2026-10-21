enum FitnessGoal {
  weightLoss,
  muscleGain,
  generalFitness,
  improveEndurance;

  String get id {
    switch (this) {
      case FitnessGoal.weightLoss:
        return 'Weight Loss';
      case FitnessGoal.muscleGain:
        return 'Muscle Gain';
      case FitnessGoal.generalFitness:
        return 'General Fitness';
      case FitnessGoal.improveEndurance:
        return 'Improve Endurance';
    }
  }

  String get title {
    switch (this) {
      case FitnessGoal.weightLoss:
        return 'Weight Loss';
      case FitnessGoal.muscleGain:
        return 'Muscle Gain';
      case FitnessGoal.generalFitness:
        return 'General Fitness';
      case FitnessGoal.improveEndurance:
        return 'Improve Endurance';
    }
  }

  String get description {
    switch (this) {
      case FitnessGoal.weightLoss:
        return 'Focus on calorie deficit & continuous circuit training';
      case FitnessGoal.muscleGain:
        return 'Focus on strength, hypertrophy & progressive overload';
      case FitnessGoal.generalFitness:
        return 'Balance of stamina, flexibility & healthy mobility';
      case FitnessGoal.improveEndurance:
        return 'Cardio capacity, sustained stamina & endurance';
    }
  }

  String get icon {
    switch (this) {
      case FitnessGoal.weightLoss:
        return '🔥';
      case FitnessGoal.muscleGain:
        return '💪';
      case FitnessGoal.generalFitness:
        return '🌱';
      case FitnessGoal.improveEndurance:
        return '⚡';
    }
  }

  static FitnessGoal fromString(String? value) {
    if (value == null) return FitnessGoal.generalFitness;
    switch (value.toLowerCase().trim()) {
      case 'weight loss':
      case 'weightloss':
        return FitnessGoal.weightLoss;
      case 'muscle gain':
      case 'musclegain':
        return FitnessGoal.muscleGain;
      case 'improve endurance':
      case 'improveendurance':
      case 'endurance':
        return FitnessGoal.improveEndurance;
      case 'general fitness':
      case 'generalfitness':
      default:
        return FitnessGoal.generalFitness;
    }
  }
}
