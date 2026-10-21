import '../../models/user_profile.dart';
import '../../models/workout_plan.dart';
import '../../models/exercise_item.dart';
import '../../models/workout_session.dart';

class AiEngineService {
  /// Generate reading / insight based on BMI and User Profile
  static String generateBmiInsight(UserProfile profile) {
    final bmi = profile.bmi;
    final goal = profile.fitnessGoal;

    if (bmi < 18.5) {
      return 'BMI reading indicates weight is below the optimal range. AI has structured moderate resistance hypertrophy workouts focusing on lean muscle gain and recommended a calorie surplus.';
    } else if (bmi < 25.0) {
      if (goal == 'Muscle Gain') {
        return 'Your BMI is in the ideal range (Normal). Program focuses on progressive strength training with 3–4 sets to maximize lean muscle development.';
      } else if (goal == 'Improve Endurance') {
        return 'Optimal BMI for building cardiovascular base. The plan prioritizes VO2 max enhancement, continuous stamina circuits, and efficient breathing pacing.';
      } else {
        return 'Body composition is in the optimal healthy zone. The plan emphasizes stamina maintenance, core mobility, and moderate cardio conditioning.';
      }
    } else if (bmi < 30.0) {
      if (goal == 'Improve Endurance') {
        return 'BMI is in the moderate range. Focus is on low-impact stamina circuits to burn calories while protecting joints.';
      }
      return 'BMI is in the overweight range. The plan emphasizes controlled-intensity fat-burning circuits (65–75% HR) with low joint impact to protect knees.';
    } else {
      return 'Primary focus is on zero-impact cardio combined with stable bodyweight movements to eliminate joint strain and optimize metabolic health.';
    }
  }

  /// Generate full 4-week plan customized to user's intake
  static WorkoutPlan generatePersonalizedPlan(UserProfile profile) {
    final days = profile.commitDays.clamp(2, 6);
    final goal = profile.fitnessGoal;
    final bmi = profile.bmi;
    final isEndurance = goal.toLowerCase().contains('endurance');
    final isMuscle = goal.toLowerCase().contains('muscle');

    List<ExerciseItem> generateExercises(String focus, int count) {
      final List<ExerciseItem> all;
      if (isEndurance) {
        all = [
          ExerciseItem(id: 'ex_e1', number: '01', name: 'Jumping Jacks', meta: '3 sets × 50 sec', durationText: "2'30", durationSeconds: 50, targetMuscle: 'Cardio'),
          ExerciseItem(id: 'ex_e2', number: '02', name: 'Mountain Climber', meta: '3 sets × 45 sec', durationText: "2'15", durationSeconds: 45, targetMuscle: 'Cardio'),
          ExerciseItem(id: 'ex_e3', number: '03', name: 'Bodyweight Squat', meta: '3 sets × 20 reps (Tempo)', durationText: "4'00", durationSeconds: 60, targetMuscle: 'Legs'),
          ExerciseItem(id: 'ex_e4', number: '04', name: 'High Knees', meta: '3 sets × 40 sec', durationText: "2'00", durationSeconds: 40, targetMuscle: 'Cardio'),
          ExerciseItem(id: 'ex_e5', number: '05', name: 'Plank Hold', meta: '3 sets × 50 sec', durationText: "2'30", durationSeconds: 50, targetMuscle: 'Core'),
          ExerciseItem(id: 'ex_e6', number: '06', name: 'Walking Lunges', meta: '3 sets × 16 reps', durationText: "3'45", durationSeconds: 45, targetMuscle: 'Legs'),
          ExerciseItem(id: 'ex_e7', number: '07', name: 'Glute Bridge', meta: '3 sets × 18 reps', durationText: "3'15", durationSeconds: 45, targetMuscle: 'Glutes'),
          ExerciseItem(id: 'ex_e8', number: '08', name: 'Shoulder Tap Plank', meta: '3 sets × 24 reps', durationText: "3'00", durationSeconds: 45, targetMuscle: 'Shoulders'),
        ];
      } else if (isMuscle) {
        all = [
          ExerciseItem(id: 'ex_m1', number: '01', name: 'Incline Push-up', meta: '4 sets × 12 reps', durationText: "3'30", durationSeconds: 55, targetMuscle: 'Chest'),
          ExerciseItem(id: 'ex_m2', number: '02', name: 'Bodyweight Squat', meta: '4 sets × 15 reps', durationText: "4'00", durationSeconds: 60, targetMuscle: 'Legs'),
          ExerciseItem(id: 'ex_m3', number: '03', name: 'Glute Bridge', meta: '4 sets × 15 reps', durationText: "3'15", durationSeconds: 50, targetMuscle: 'Glutes'),
          ExerciseItem(id: 'ex_m4', number: '04', name: 'Plank Hold', meta: '4 sets × 45 sec', durationText: "3'00", durationSeconds: 45, targetMuscle: 'Core'),
          ExerciseItem(id: 'ex_m5', number: '05', name: 'Shoulder Tap Plank', meta: '3 sets × 20 reps', durationText: "3'00", durationSeconds: 45, targetMuscle: 'Shoulders'),
          ExerciseItem(id: 'ex_m6', number: '06', name: 'Lunges', meta: '4 sets × 12 reps', durationText: "4'00", durationSeconds: 50, targetMuscle: 'Legs'),
          ExerciseItem(id: 'ex_m7', number: '07', name: 'Mountain Climber', meta: '3 sets × 30 sec', durationText: "2'15", durationSeconds: 30, targetMuscle: 'Core'),
          ExerciseItem(id: 'ex_m8', number: '08', name: 'Jumping Jacks', meta: '3 sets × 30 sec', durationText: "1'45", durationSeconds: 30, targetMuscle: 'Cardio'),
        ];
      } else {
        all = [
          ExerciseItem(id: 'ex_1', number: '01', name: 'Jumping Jacks', meta: '3 sets × 45 sec', durationText: "2'15", durationSeconds: 45, targetMuscle: 'Cardio'),
          ExerciseItem(id: 'ex_2', number: '02', name: 'Bodyweight Squat', meta: '3 sets × 15 reps', durationText: "4'00", durationSeconds: 60, targetMuscle: 'Legs'),
          ExerciseItem(id: 'ex_3', number: '03', name: 'Incline Push-up', meta: '3 sets × 12 reps', durationText: "3'30", durationSeconds: 50, targetMuscle: 'Chest'),
          ExerciseItem(id: 'ex_4', number: '04', name: 'Mountain Climber', meta: '3 sets × 30 sec', durationText: "2'45", durationSeconds: 30, targetMuscle: 'Core'),
          ExerciseItem(id: 'ex_5', number: '05', name: 'Glute Bridge', meta: '3 sets × 15 reps', durationText: "3'15", durationSeconds: 45, targetMuscle: 'Glutes'),
          ExerciseItem(id: 'ex_6', number: '06', name: 'Plank Hold', meta: '3 sets × 40 sec', durationText: "2'30", durationSeconds: 40, targetMuscle: 'Core'),
          ExerciseItem(id: 'ex_7', number: '07', name: 'Lunges', meta: '3 sets × 12 reps', durationText: "3'45", durationSeconds: 45, targetMuscle: 'Legs'),
          ExerciseItem(id: 'ex_8', number: '08', name: 'Shoulder Tap Plank', meta: '3 sets × 20 reps', durationText: "3'00", durationSeconds: 40, targetMuscle: 'Shoulders'),
        ];
      }

      if (focus == 'Upper Body') {
        return all.where((e) => ['Chest', 'Shoulders', 'Core'].contains(e.targetMuscle)).take(count).toList();
      } else if (focus == 'Lower Body') {
        return all.where((e) => ['Legs', 'Glutes', 'Core'].contains(e.targetMuscle)).take(count).toList();
      } else if (focus == 'Cardio') {
        return all.where((e) => ['Cardio', 'Legs', 'Core'].contains(e.targetMuscle)).take(count).toList();
      } else {
        return all.take(count).toList();
      }
    }

    final schedule = isEndurance
        ? [
            ScheduledWorkoutDay(
              dayOfWeek: 'MON',
              dateNumber: '1',
              title: 'Cardio Stamina Circuit',
              meta: '34 min · 6 moves · 420 kcal',
              state: 'done',
              durationMinutes: 34,
              estimatedCalories: 420,
              aiRationale: 'Builds aerobic capacity and sustained cardiovascular endurance.',
              exercises: generateExercises('Cardio', 6),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'TUE',
              dateNumber: '2',
              title: 'Core & Aerobic Pace',
              meta: '28 min · 5 moves · 320 kcal',
              state: 'done',
              durationMinutes: 28,
              estimatedCalories: 320,
              aiRationale: 'Strengthens core endurance and breathing stability during exercise.',
              exercises: generateExercises('Core', 5),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'WED',
              dateNumber: '3',
              title: 'Rest & Mobility',
              meta: '15 min stretch',
              state: 'rest',
              durationMinutes: 15,
              estimatedCalories: 80,
              aiRationale: 'Active recovery day allowing muscles and lungs to fully regenerate.',
              exercises: [],
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'THU',
              dateNumber: '4',
              title: 'HIIT Aerobic Intervals',
              meta: '32 min · 6 moves · 440 kcal',
              state: 'today',
              durationMinutes: 32,
              estimatedCalories: 440,
              aiRationale: 'Targeted for Improve Endurance (BMI ${bmi.toStringAsFixed(1)}). Interval training to elevate VO2 max.',
              exercises: generateExercises('Full Body', 6),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'FRI',
              dateNumber: '5',
              title: 'Aerobic Flush & Recovery',
              meta: '24 min · light intensity',
              state: days >= 4 ? 'next' : 'rest',
              durationMinutes: 24,
              estimatedCalories: 220,
              aiRationale: 'Low-impact cardio to stimulate blood flow and stamina recovery.',
              exercises: generateExercises('Core', 4),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'SAT',
              dateNumber: '6',
              title: 'Lower Body Stamina',
              meta: '36 min · 6 moves · 430 kcal',
              state: days >= 5 ? 'next' : 'rest',
              durationMinutes: 36,
              estimatedCalories: 430,
              aiRationale: 'Builds muscular endurance in legs and glutes for running and prolonged stamina.',
              exercises: generateExercises('Lower Body', 6),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'SUN',
              dateNumber: '7',
              title: 'Full Rest',
              meta: 'Recovery day',
              state: 'rest',
              durationMinutes: 0,
              estimatedCalories: 0,
              aiRationale: 'Optimal sleep and hydration ahead of the upcoming training cycle.',
              exercises: [],
            ),
          ]
        : [
            ScheduledWorkoutDay(
              dayOfWeek: 'MON',
              dateNumber: '1',
              title: 'Upper Body Strength',
              meta: '34 min · 6 moves · 380 kcal',
              state: 'done',
              durationMinutes: 34,
              estimatedCalories: 380,
              aiRationale: 'Builds upper body strength across chest and shoulders with progressive mechanics.',
              exercises: generateExercises('Upper Body', 6),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'TUE',
              dateNumber: '2',
              title: 'Core & Mobility',
              meta: '26 min · 5 moves · 290 kcal',
              state: 'done',
              durationMinutes: 26,
              estimatedCalories: 290,
              aiRationale: 'Strengthens hips and core to support posture and daily alignment.',
              exercises: generateExercises('Core', 5),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'WED',
              dateNumber: '3',
              title: 'Rest & Mobility',
              meta: '15 min stretch',
              state: 'rest',
              durationMinutes: 15,
              estimatedCalories: 80,
              aiRationale: 'Active recovery day allowing muscle tissue to fully repair.',
              exercises: [],
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'THU',
              dateNumber: '4',
              title: 'Fat-Burn Circuit',
              meta: '32 min · 6 moves · 410 kcal',
              state: 'today',
              durationMinutes: 32,
              estimatedCalories: 410,
              aiRationale: 'Selected for BMI ${bmi.toStringAsFixed(1)} + goal $goal. Moderate intensity, joint-safe.',
              exercises: generateExercises('Full Body', 6),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'FRI',
              dateNumber: '5',
              title: 'Active Recovery',
              meta: '24 min · light intensity',
              state: days >= 4 ? 'next' : 'rest',
              durationMinutes: 24,
              estimatedCalories: 210,
              aiRationale: 'Low-intensity cardio to promote circulation and minimize muscle tightness.',
              exercises: generateExercises('Core', 4),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'SAT',
              dateNumber: '6',
              title: 'Lower Body Strength',
              meta: '38 min · 7 moves · 450 kcal',
              state: days >= 5 ? 'next' : 'rest',
              durationMinutes: 38,
              estimatedCalories: 450,
              aiRationale: 'Focuses on quads, hamstrings, and calves for balanced stability.',
              exercises: generateExercises('Lower Body', 6),
            ),
            ScheduledWorkoutDay(
              dayOfWeek: 'SUN',
              dateNumber: '7',
              title: 'Full Rest',
              meta: 'Recovery day',
              state: 'rest',
              durationMinutes: 0,
              estimatedCalories: 0,
              aiRationale: 'Optimal sleep and hydration ahead of next week’s training rounds.',
              exercises: [],
            ),
          ];

    return WorkoutPlan(
      planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.uid,
      title: '4-Week Plan: $goal',
      rationale: isEndurance
          ? 'Intelligent Endurance plan designed for aerobic capacity with a commitment of $days days/week.'
          : 'Intelligently generated plan based on BMI ${bmi.toStringAsFixed(1)} and a commitment of $days days/week.',
      totalWeeks: 4,
      currentWeek: 1,
      schedule: schedule,
      createdAt: DateTime.now(),
    );
  }

  /// Adaptive AI Plan Revision when a workout is incomplete
  static Map<String, dynamic> generatePlanRevision({
    required String reason, // time, fatigue, injury, other
    required String notes,
    required ScheduledWorkoutDay currentWorkout,
  }) {
    String detectionMessage;
    String adjustmentDetails;
    List<ExerciseItem> revisedExercises = [];

    switch (reason) {
      case 'time':
        detectionMessage = 'AI detected your daily time constraint.';
        adjustmentDetails = 'Session will be shortened from ${currentWorkout.durationMinutes} minutes to 20 minutes with efficient supersets.';
        revisedExercises = currentWorkout.exercises.take(4).map((e) => e.copyWith(
          sets: 2,
          reps: 10,
          meta: '2 sets × 10 reps (Express)',
        )).toList();
        break;
      case 'fatigue':
        detectionMessage = 'AI detected signs of severe fatigue / slower recovery.';
        adjustmentDetails = 'Intensity reduced by 25%. Rest between sets increased from 30s to 45s.';
        revisedExercises = currentWorkout.exercises.map((e) => e.copyWith(
          sets: (e.sets - 1).clamp(2, 4),
          restSeconds: 45,
          meta: '${(e.sets - 1).clamp(2, 4)} sets · 45s rest',
        )).toList();
        break;
      case 'injury':
        detectionMessage = 'AI detected joint discomfort or injury warning.';
        adjustmentDetails = 'All high-impact movements removed and replaced with zero-strain mobility exercises.';
        revisedExercises = currentWorkout.exercises.map((e) {
          if (e.name.toLowerCase().contains('jumping') || e.name.toLowerCase().contains('climber')) {
            return e.copyWith(name: 'Glute Bridge Hold', targetMuscle: 'Mobility', meta: '3 sets × 30 sec');
          }
          return e;
        }).toList();
        break;
      default:
        detectionMessage = 'AI tailored your workout based on your custom feedback.';
        adjustmentDetails = 'Stay consistent with a balanced training volume for this week.';
        revisedExercises = currentWorkout.exercises;
    }

    return {
      'detection': detectionMessage,
      'adjustment': adjustmentDetails,
      'revisedExercises': revisedExercises,
      'revisedDuration': (currentWorkout.durationMinutes * 0.75).round(),
    };
  }

  /// AI Coach Chat response
  static String generateCoachReply(String userMessage, UserProfile profile) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('makan') || lower.contains('diet') || lower.contains('kalori') || lower.contains('protein') || lower.contains('eat') || lower.contains('food') || lower.contains('calorie')) {
      final proteinTarget = (profile.weight * 1.6).round();
      return 'For your goal of ${profile.fitnessGoal} at ${profile.weight.toInt()} kg, I recommend approximately ${proteinTarget}g of protein daily. Divide across 3–4 meals with fibrous vegetables and at least 2.5 liters of water.';
    } else if (lower.contains('lutut') || lower.contains('sakit') || lower.contains('cedera') || lower.contains('knee') || lower.contains('pain') || lower.contains('injury') || lower.contains('ache')) {
      return 'If your knees or joints feel uncomfortable during squats, avoid excessive depth. You can substitute with Glute Bridges or Wall Sits to build stability without stressing the patella.';
    } else if (lower.contains('endurance') || lower.contains('stamina') || lower.contains('lari') || lower.contains('kardio') || lower.contains('run') || lower.contains('cardio')) {
      return 'For your goal of ${profile.fitnessGoal}, focus on steady-rhythm cardio zones. Ensure adequate hydration of at least 2.5 liters of water to sustain stamina and prevent muscle cramps.';
    } else if (lower.contains('jadual') || lower.contains('hari') || lower.contains('masa') || lower.contains('schedule') || lower.contains('day') || lower.contains('time') || lower.contains('miss')) {
      return 'Your schedule is planned for ${profile.commitDays} days per week. If you miss a day, don\'t worry—your streak remains protected and you can resume next session without doubling up volume.';
    } else {
      return 'Your primary focus today is consistency over perfection. Every session you complete reinforces your habits and moves you closer to your goal of ${profile.fitnessGoal}. Is there a specific exercise you need guidance with?';
    }
  }

  /// Generate Reason and Motivation for next workout based on history and user profile
  static Map<String, String> generateNextWorkoutInsight({
    required List<WorkoutSession> history,
    required UserProfile profile,
    required String language,
    WorkoutPlan? plan,
  }) {
    final isEn = language == 'en';
    final lastSession = history.isNotEmpty ? history.first : null;
    final lastTitle = lastSession?.workoutTitle.toLowerCase() ?? '';

    // Find next workout from plan schedule
    ScheduledWorkoutDay? nextDay;
    if (plan != null && plan.schedule.isNotEmpty) {
      nextDay = plan.schedule.firstWhere(
        (d) => d.state == 'today' || d.state == 'next',
        orElse: () => plan.schedule.first,
      );
    }

    final nextWorkoutTitle = nextDay?.title ??
        (isEn ? 'Lower Body & Core' : 'Lower Body & Teras');
    final nextWorkoutMeta = nextDay != null
        ? '${nextDay.durationMinutes} min · ${nextDay.estimatedCalories} kcal'
        : (isEn ? '32 min · 380 kcal' : '32 min · 380 kcal');

    String reason;
    String motivation;

    if (lastTitle.contains('upper') || lastTitle.contains('dada') || lastTitle.contains('tangan')) {
      if (isEn) {
        reason = 'Your previous session exerted high mechanical tension on your upper body (chest, shoulders, and triceps). These muscle groups require 36 to 48 hours for protein synthesis and recovery. Next up is $nextWorkoutTitle to engage your lower kinetic chain and core, preserving upper body recovery while sustaining metabolic burn.';
        motivation = 'You are maintaining a strong ${profile.streakDays}-day streak with ${profile.completedWorkouts} workouts completed! Keep the discipline alive—bring full power to your legs and core today!';
      } else {
        reason = 'Sesi lalu memberi bebanan tinggi pada otot bahagian atas (dada, bahu, dan trisep). Kumpulan otot ini memerlukan rehat 36 hingga 48 jam untuk sintesis protein dan pemulihan mikro. Oleh itu, sesi seterusnya ialah $nextWorkoutTitle untuk melatih bahagian bawah dan teras bagi mengimbangi postur sambil mengekalkan kadar pembakaran kalori.';
        motivation = 'Streak aktif anda kini mencecah ${profile.streakDays} hari dengan ${profile.completedWorkouts} sesi selesai! Disiplin adalah pembeza juara—hayunkan langkah bertenaga untuk takluki sesi kaki dan teras hari ini!';
      }
    } else if (lastTitle.contains('lower') || lastTitle.contains('kaki') || lastTitle.contains('squat')) {
      if (isEn) {
        reason = 'Your last session heavily stimulated the body\'s largest muscle groups (quads, hamstrings, and glutes). To prevent localized fatigue and promote active recovery, the upcoming session balances your physique with $nextWorkoutTitle to enhance posture and aerobic conditioning.';
        motivation = 'Leg day conquered! That proves your determination toward ${profile.fitnessGoal}. Take that same unstoppable energy into your next workout and keep progressing!';
      } else {
        reason = 'Sesi senaman kaki lalu telah merangsang kelompok otot terbesar tubuh (paha hadapan, hamstring, dan glute). Bagi mengelakkan keletihan setempat dan mengalirkan asid laktik keluar, sesi seterusnya memfokuskan $nextWorkoutTitle untuk mengimbangi bentuk tubuh dan stamina.';
        motivation = 'Kaki anda telah diuji dan anda berjaya harungi dengan mantap! Buktikan lagi komitmen anda terhadap sasaran ${profile.fitnessGoal} dalam sesi seterusnya!';
      }
    } else if (lastTitle.contains('core') || lastTitle.contains('mobiliti') || lastTitle.contains('stretch')) {
      if (isEn) {
        reason = 'Your prior core and mobility work established solid spinal stability and relieved neuromuscular tension. Your joints and muscular stabilizers are now primed for $nextWorkoutTitle to burn calories with optimal form.';
        motivation = 'A stable core is the foundation of every great athlete. You are stronger today than yesterday—let\'s ignite the next session with passion!';
      } else {
        reason = 'Latihan teras dan mobiliti sebelum ini berjaya menstabilkan tulang belakang dan melegakan ketegangan saraf. Sendi dan otot penstabil kini berada dalam fasa optimum untuk $nextWorkoutTitle bagi membakar kalori dengan teknik yang selamat.';
        motivation = 'Teras yang kukuh adalah asas kecergasan sejati. Anda semakin cergas dari hari ke hari—ayuh bakar semangat dalam sesi latihan seterusnya!';
      }
    } else {
      // General or cardio/first workout
      if (isEn) {
        reason = 'Based on your overall training history and goal (${profile.fitnessGoal}), continuous rotational training across muscle splits ensures steady metabolic adaptation without overtraining.';
        motivation = 'Consistency creates champions. Every single repetition counts toward your transformation. Let\'s step up and make today count!';
      } else {
        reason = 'Berdasarkan sejarah senaman dan matlamat anda (${profile.fitnessGoal}), giliran latihan berperingkat memastikan adaptasi metabolisme yang konsisten tanpa risiko beban lampau (overtraining).';
        motivation = 'Konsistensi membentuk kejayaan sebenar. Setiap titisan peluh mendekatkan anda kepada bentuk badan idaman. Ayuh mulakan sesi seterusnya dengan semangat membara!';
      }
    }

    return {
      'lastWorkoutTitle': lastSession?.workoutTitle ?? (isEn ? 'Recent Workout' : 'Sesi Lalu'),
      'nextWorkoutTitle': nextWorkoutTitle,
      'nextWorkoutMeta': nextWorkoutMeta,
      'reason': reason,
      'motivation': motivation,
    };
  }
}

