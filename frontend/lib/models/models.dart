import 'package:uuid/uuid.dart';

class ExerciseItem {
  final String id;
  final String muscleGroupId;
  final String nameAr;
  final String nameEn;
  final String equipment;
  final bool isCustom;
  double personalBest;

  ExerciseItem({
    required this.id,
    required this.muscleGroupId,
    required this.nameAr,
    required this.nameEn,
    required this.equipment,
    this.isCustom = false,
    this.personalBest = 0.0,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      id: json['id'] ?? '',
      muscleGroupId: json['muscle_group_id'] ?? 'chest',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      equipment: json['equipment'] ?? 'barbell',
      isCustom: json['is_custom'] ?? false,
      personalBest: (json['personal_best'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String name(bool isArabic) => isArabic ? (nameAr.isNotEmpty ? nameAr : nameEn) : (nameEn.isNotEmpty ? nameEn : nameAr);
  String get targetMuscle => muscleGroupId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'muscle_group_id': muscleGroupId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'equipment': equipment,
      'is_custom': isCustom,
      'personal_best': personalBest,
    };
  }
}

class RoutineExerciseItem {
  final String id;
  final String exerciseId;
  int orderIndex;
  int targetSets;

  RoutineExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.orderIndex,
    this.targetSets = 3,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_id': exerciseId,
    'order_index': orderIndex,
    'target_sets': targetSets,
  };
}

class RoutineDayItem {
  final String id;
  final String routineId;
  final int dayNumber;
  String dayName;
  List<RoutineExerciseItem> exercises;

  RoutineDayItem({
    required this.id,
    required this.routineId,
    required this.dayNumber,
    required this.dayName,
    List<RoutineExerciseItem>? exercises,
  }) : exercises = exercises ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'routine_id': routineId,
    'day_number': dayNumber,
    'day_name': dayName,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

class WorkoutRoutineItem {
  final String id;
  String title;
  String description;
  int daysCount;
  bool isActive;
  final bool isSystem;
  List<RoutineDayItem> days;

  WorkoutRoutineItem({
    required this.id,
    required this.title,
    this.description = '',
    this.daysCount = 3,
    this.isActive = false,
    this.isSystem = false,
    List<RoutineDayItem>? days,
  }) : days = days ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'days_count': daysCount,
    'is_active': isActive,
    'is_system': isSystem,
    'days': days.map((d) => d.toJson()).toList(),
  };
}

class SetLogItem {
  final String id;
  final String workoutSessionId;
  final String exerciseId;
  final int setNumber;
  double weightKg;
  int reps;
  double? rpe;
  bool isPr;
  String syncStatus;
  String setType; // 'normal', 'warmup', 'dropset', 'failure'
  String? notes;

  SetLogItem({
    String? id,
    required this.workoutSessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.rpe,
    this.isPr = false,
    this.syncStatus = 'pending',
    this.setType = 'normal',
    this.notes,
  }) : id = id ?? const Uuid().v4();

  factory SetLogItem.fromJson(Map<String, dynamic> json) {
    return SetLogItem(
      id: json['id'],
      workoutSessionId: json['workout_session_id'] ?? '',
      exerciseId: json['exercise_id'] ?? '',
      setNumber: json['set_number'] is int ? json['set_number'] : int.tryParse('${json['set_number']}') ?? 1,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] is int ? json['reps'] : int.tryParse('${json['reps']}') ?? 0,
      rpe: (json['rpe'] as num?)?.toDouble(),
      isPr: json['is_pr'] == true || json['is_pr'] == 1,
      syncStatus: json['sync_status'] ?? 'synced',
      setType: json['set_type'] ?? 'normal',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workout_session_id': workoutSessionId,
    'exercise_id': exerciseId,
    'set_number': setNumber,
    'weight_kg': weightKg,
    'reps': reps,
    'rpe': rpe,
    'is_pr': isPr,
    'sync_status': syncStatus,
    'set_type': setType,
    'notes': notes,
  };
}

class WorkoutSessionItem {
  final String id;
  final String? routineDayId;
  String name;
  DateTime startedAt;
  DateTime? endedAt;
  String? notes;
  String syncStatus;
  List<SetLogItem> sets;

  WorkoutSessionItem({
    String? id,
    this.routineDayId,
    required this.name,
    required this.startedAt,
    this.endedAt,
    this.notes,
    this.syncStatus = 'pending',
    List<SetLogItem>? sets,
  })  : id = id ?? const Uuid().v4(),
        sets = sets ?? [];

  factory WorkoutSessionItem.fromJson(Map<String, dynamic> json) {
    var rawSets = json['sets'] as List? ?? [];
    return WorkoutSessionItem(
      id: json['id'],
      routineDayId: json['routine_day_id'],
      name: json['name'] ?? 'Workout',
      startedAt: DateTime.tryParse(json['started_at'] ?? '') ?? DateTime.now(),
      endedAt: json['ended_at'] != null ? DateTime.tryParse(json['ended_at']) : null,
      notes: json['notes'],
      syncStatus: json['sync_status'] ?? 'synced',
      sets: rawSets.map((s) => SetLogItem.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }

  double get totalVolume {
    double vol = 0;
    for (var s in sets) {
      // Warmup sets typically don't count towards primary working volume
      if (s.setType != 'warmup') {
        vol += (s.weightKg * s.reps);
      }
    }
    // If all sets were warmup or simple count, fallback to standard sum
    if (vol == 0 && sets.isNotEmpty) {
      for (var s in sets) {
        vol += (s.weightKg * s.reps);
      }
    }
    return vol;
  }

  int get totalSets => sets.length;

  int get durationMinutes {
    if (endedAt == null) return 0;
    final diff = endedAt!.difference(startedAt).inMinutes;
    return diff > 0 ? diff : 1;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'routine_day_id': routineDayId,
    'name': name,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'notes': notes,
    'sync_status': syncStatus,
    'sets': sets.map((s) => s.toJson()).toList(),
  };
}

class BodyWeightLogItem {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? note;

  BodyWeightLogItem({
    String? id,
    required this.date,
    required this.weightKg,
    this.note,
  }) : id = id ?? const Uuid().v4();

  factory BodyWeightLogItem.fromJson(Map<String, dynamic> json) => BodyWeightLogItem(
    id: json['id'],
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
    note: json['note'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weight_kg': weightKg,
    'note': note,
  };
}

