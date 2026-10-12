import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/app_translations.dart';
import '../services/biometric_service.dart';

class WorkoutProvider extends ChangeNotifier {
  static String get apiUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.contains('msulimancode.com') || origin.contains('161.97.93.30')) {
        return '$origin/api';
      }
    }
    return 'http://ironleg.msulimancode.com/api';
  }

  Locale _locale = const Locale('ar'); // العربية هي الافتراضية
  List<ExerciseItem> _exercises = [];
  List<WorkoutRoutineItem> _routines = [];
  List<WorkoutSessionItem> _sessions = [];

  WorkoutRoutineItem? _activeRoutine;
  RoutineDayItem? _selectedDay;
  WorkoutSessionItem? _activeSession;

  String? _authToken;
  String _athleteName = '';
  String _athletePhone = '';
  String _athleteEmail = '';
  bool _isLoggedIn = false; // تبدأ غير مسجل دخول لتمكين المستخدم من إنشاء حسابه لأول مرة
  bool _isBiometricEnabled = false;

  // Getters
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  List<ExerciseItem> get exercises => _exercises;
  List<WorkoutRoutineItem> get routines => _routines;
  List<WorkoutSessionItem> get sessions => _sessions;
  WorkoutRoutineItem? get activeRoutine => _activeRoutine;
  RoutineDayItem? get selectedDay => _selectedDay;
  WorkoutSessionItem? get activeSession => _activeSession;
  String get athleteName => _athleteName;
  String get athletePhone => _athletePhone;
  String get athleteEmail => _athleteEmail;
  bool get isLoggedIn => _isLoggedIn;
  bool get isBiometricEnabled => _isBiometricEnabled;

  String get athleteDisplayName {
    final trimmed = _athleteName.trim();
    if (trimmed.isEmpty || RegExp(r'^[\+\d\s\-]+$').hasMatch(trimmed)) {
      return isArabic ? 'محمد سليمان' : 'Suliman';
    }
    return trimmed;
  }

  String get athleteAvatarLetter {
    final name = athleteDisplayName;
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(char)) {
        return char.toUpperCase();
      }
    }
    return isArabic ? 'م' : 'S';
  }

  void updateAthleteName(String newName) {
    if (newName.trim().isNotEmpty) {
      _athleteName = newName.trim();
      notifyListeners();
    }
  }

  String t(String key) => AppTranslations.t(key, isArabic);

  void toggleLanguage() {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }

  void setLocale(String langCode) {
    _locale = Locale(langCode);
    notifyListeners();
  }

  WorkoutProvider() {
    _initializeData();
  }

  void _initializeData() {
    // 1. مكتبة التمارين المدمجة مسبقاً (مطابقة للباك إند)
    _exercises = [
      // الصدر
      ExerciseItem(id: '11111111-1111-1111-1111-000000000001', muscleGroupId: 'chest', nameAr: 'بنش برس بار مستوي', nameEn: 'Barbell bench press', equipment: 'Barbell', personalBest: 0.0),
      ExerciseItem(id: '11111111-1111-1111-1111-000000000002', muscleGroupId: 'chest', nameAr: 'بنش برس دمبلز علوي', nameEn: 'Incline dumbbell press', equipment: 'Dumbbell', personalBest: 0.0),
      ExerciseItem(id: '11111111-1111-1111-1111-000000000003', muscleGroupId: 'chest', nameAr: 'فراشة جهاز', nameEn: 'Pec deck fly', equipment: 'Machine', personalBest: 0.0),
      ExerciseItem(id: '11111111-1111-1111-1111-000000000004', muscleGroupId: 'chest', nameAr: 'تجميع كابل سفلي', nameEn: 'Low cable fly', equipment: 'Cable', personalBest: 0.0),

      // الظهر
      ExerciseItem(id: '22222222-2222-2222-2222-000000000001', muscleGroupId: 'back', nameAr: 'سحب عالي كابل أمامي', nameEn: 'Lat pulldown', equipment: 'Machine', personalBest: 0.0),
      ExerciseItem(id: '22222222-2222-2222-2222-000000000002', muscleGroupId: 'back', nameAr: 'تجديف بار مستوي', nameEn: 'Bent-over row', equipment: 'Barbell', personalBest: 0.0),
      ExerciseItem(id: '22222222-2222-2222-2222-000000000003', muscleGroupId: 'back', nameAr: 'سحب كابل جالس', nameEn: 'Cable row', equipment: 'Cable', personalBest: 0.0),
      ExerciseItem(id: '22222222-2222-2222-2222-000000000004', muscleGroupId: 'back', nameAr: 'ديدلفت بار كلاسيكي', nameEn: 'Deadlift', equipment: 'Barbell', personalBest: 0.0),

      // الأكتاف
      ExerciseItem(id: '33333333-3333-3333-3333-000000000001', muscleGroupId: 'shoulders', nameAr: 'ضغط دمبلز جالس للأكتاف', nameEn: 'Seated shoulder press', equipment: 'Dumbbell', personalBest: 0.0),
      ExerciseItem(id: '33333333-3333-3333-3333-000000000002', muscleGroupId: 'shoulders', nameAr: 'رفرفة دمبلز جانبي', nameEn: 'Dumbbell lateral raise', equipment: 'Dumbbell', personalBest: 0.0),
      ExerciseItem(id: '33333333-3333-3333-3333-000000000003', muscleGroupId: 'shoulders', nameAr: 'رفرفة كابل جانبي', nameEn: 'Cable lateral raise', equipment: 'Cable', personalBest: 0.0),

      // الأرجل
      ExerciseItem(id: '44444444-4444-4444-4444-000000000001', muscleGroupId: 'legs', nameAr: 'سكوات بار خلفي', nameEn: 'Barbell back squat', equipment: 'Barbell', personalBest: 0.0),
      ExerciseItem(id: '44444444-4444-4444-4444-000000000002', muscleGroupId: 'legs', nameAr: 'جهاز ضغط الأرجل', nameEn: 'Leg press', equipment: 'Machine', personalBest: 0.0),
      ExerciseItem(id: '44444444-4444-4444-4444-000000000003', muscleGroupId: 'legs', nameAr: 'مرجحة أرجل خلفية', nameEn: 'Lying leg curl', equipment: 'Machine', personalBest: 0.0),

      // الذراعين
      ExerciseItem(id: '55555555-5555-5555-5555-000000000001', muscleGroupId: 'arms', nameAr: 'بايسبس بار متعرج', nameEn: 'EZ-bar curl', equipment: 'Barbell', personalBest: 0.0),
      ExerciseItem(id: '55555555-5555-5555-5555-000000000003', muscleGroupId: 'arms', nameAr: 'ترايسبس حبل كابل', nameEn: 'Cable triceps pushdown', equipment: 'Cable', personalBest: 0.0),
      ExerciseItem(id: '55555555-5555-5555-5555-000000000004', muscleGroupId: 'arms', nameAr: 'ترايسبس كابل خلف الرأس', nameEn: 'Overhead triceps extension', equipment: 'Cable', personalBest: 0.0),

      // الكور
      ExerciseItem(id: '66666666-6666-6666-6666-000000000001', muscleGroupId: 'core', nameAr: 'طحن بطن كابل', nameEn: 'Cable crunch', equipment: 'Cable', personalBest: 0.0),
    ];

    // 2. الجداول الجاهزة (PPL, Upper/Lower, Arnold)
    final ppl = WorkoutRoutineItem(
      id: '77777777-7777-7777-7777-000000000001',
      title: 'Push / Pull / Legs',
      description: 'Accelerated split built for steady volume across chest, back and legs.',
      daysCount: 3,
      isActive: true,
      isSystem: true,
      days: [
        RoutineDayItem(
          id: '88888888-8888-8888-8888-000000000001',
          routineId: '77777777-7777-7777-7777-000000000001',
          dayNumber: 1,
          dayName: 'Push day.',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000001', orderIndex: 1, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000002', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000001', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000003', orderIndex: 4, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000003', orderIndex: 5, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000004', orderIndex: 6, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: '88888888-8888-8888-8888-000000000002',
          routineId: '77777777-7777-7777-7777-000000000001',
          dayNumber: 2,
          dayName: 'Pull day.',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000001', orderIndex: 1, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000002', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000003', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000001', orderIndex: 4, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: '88888888-8888-8888-8888-000000000003',
          routineId: '77777777-7777-7777-7777-000000000001',
          dayNumber: 3,
          dayName: 'Legs & Abs.',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000001', orderIndex: 1, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000002', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000003', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '66666666-6666-6666-6666-000000000001', orderIndex: 4, targetSets: 3),
          ],
        ),
      ],
    );

    final upperLower = WorkoutRoutineItem(
      id: '77777777-7777-7777-7777-000000000002',
      title: 'Upper / Lower',
      description: 'More recovery, consistent strength work across upper and lower body.',
      daysCount: 4,
      isSystem: true,
      days: [
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000002',
          dayNumber: 1,
          dayName: 'Upper Body A (علوي أ)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000001', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000002', orderIndex: 2, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000001', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000001', orderIndex: 4, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000003', orderIndex: 5, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000002',
          dayNumber: 2,
          dayName: 'Lower Body A (سفلي أ)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000001', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000002', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000003', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000005', orderIndex: 4, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '66666666-6666-6666-6666-000000000001', orderIndex: 5, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000002',
          dayNumber: 3,
          dayName: 'Upper Body B (علوي ب)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000002', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000001', orderIndex: 2, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000002', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000002', orderIndex: 4, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000004', orderIndex: 5, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000002',
          dayNumber: 4,
          dayName: 'Lower Body B (سفلي ب)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000002', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000004', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000003', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000005', orderIndex: 4, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '66666666-6666-6666-6666-000000000001', orderIndex: 5, targetSets: 3),
          ],
        ),
      ],
    );

    final arnold = WorkoutRoutineItem(
      id: '77777777-7777-7777-7777-000000000003',
      title: 'Arnold split',
      description: 'Classic bodybuilding volume and high frequency targeting antagonistic muscles.',
      daysCount: 6,
      isSystem: true,
      days: [
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000003',
          dayNumber: 1,
          dayName: 'Chest & Back A (صدر وظهر أ)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000001', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000001', orderIndex: 2, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000002', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000002', orderIndex: 4, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000003',
          dayNumber: 2,
          dayName: 'Shoulders & Arms A (أكتاف وذراعين أ)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000004', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000002', orderIndex: 2, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000001', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000003', orderIndex: 4, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000003',
          dayNumber: 3,
          dayName: 'Legs & Abs A (أرجل وبطن أ)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000001', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000002', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000003', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '66666666-6666-6666-6666-000000000001', orderIndex: 4, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000003',
          dayNumber: 4,
          dayName: 'Chest & Back B (صدر وظهر ب)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000002', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000003', orderIndex: 2, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000001', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000002', orderIndex: 4, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000003',
          dayNumber: 5,
          dayName: 'Shoulders & Arms B (أكتاف وذراعين ب)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000001', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000003', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000002', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000004', orderIndex: 4, targetSets: 3),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000003',
          dayNumber: 6,
          dayName: 'Legs & Abs B (أرجل وبطن ب)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000002', orderIndex: 1, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000004', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000005', orderIndex: 3, targetSets: 4),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '66666666-6666-6666-6666-000000000001', orderIndex: 4, targetSets: 3),
          ],
        ),
      ],
    );

    final fullBody = WorkoutRoutineItem(
      id: '77777777-7777-7777-7777-000000000004',
      title: 'Full body',
      description: 'Efficient sessions hitting all major muscle groups for a busy week.',
      daysCount: 3,
      isSystem: true,
      days: [
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000004',
          dayNumber: 1,
          dayName: 'Full Body A (كامل الجسم أ)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000001', orderIndex: 1, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000001', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000001', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000001', orderIndex: 4, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000001', orderIndex: 5, targetSets: 2),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000004',
          dayNumber: 2,
          dayName: 'Full Body B (كامل الجسم ب)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000002', orderIndex: 1, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000002', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000002', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000002', orderIndex: 4, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '55555555-5555-5555-5555-000000000003', orderIndex: 5, targetSets: 2),
          ],
        ),
        RoutineDayItem(
          id: const Uuid().v4(),
          routineId: '77777777-7777-7777-7777-000000000004',
          dayNumber: 3,
          dayName: 'Full Body C (كامل الجسم ج)',
          exercises: [
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '44444444-4444-4444-4444-000000000001', orderIndex: 1, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '11111111-1111-1111-1111-000000000001', orderIndex: 2, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '22222222-2222-2222-2222-000000000003', orderIndex: 3, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '33333333-3333-3333-3333-000000000003', orderIndex: 4, targetSets: 3),
            RoutineExerciseItem(id: const Uuid().v4(), exerciseId: '66666666-6666-6666-6666-000000000001', orderIndex: 5, targetSets: 3),
          ],
        ),
      ],
    );

    _routines = [
      ppl,
      upperLower,
      arnold,
      fullBody,
    ];

    _activeRoutine = ppl;
    _selectedDay = ppl.days.first;

    // 3. جلسات فارغة للبدء من الصفر
    _sessions = [];
    notifyListeners();
  }

  int _restTimerDuration = 90;
  final List<BodyWeightLogItem> _bodyWeights = [];

  int get restTimerDuration => _restTimerDuration;
  void setRestTimerDuration(int sec) {
    _restTimerDuration = sec;
    notifyListeners();
  }

  List<BodyWeightLogItem> get bodyWeights => _bodyWeights;
  void logBodyWeight(double weightKg, {String? note}) {
    _bodyWeights.insert(0, BodyWeightLogItem(
      date: DateTime.now(),
      weightKg: weightKg,
      note: note,
    ));
    notifyListeners();
  }

  // ميزة المقارنة الفورية (Progressive Overload Engine)
  List<SetLogItem> getLastSessionSetsForExercise(String exerciseId) {
    for (var s in _sessions.reversed) {
      final matches = s.sets.where((st) => st.exerciseId == exerciseId).toList();
      if (matches.isNotEmpty) return matches;
    }
    return [];
  }

  // بدء تمرين جديد
  void startWorkout({RoutineDayItem? day}) {
    final d = day ?? _selectedDay;
    _activeSession = WorkoutSessionItem(
      name: d != null ? (isArabic ? d.dayName : d.dayName) : (isArabic ? 'تمرين حر (Free session)' : 'Free session'),
      routineDayId: d?.id,
      startedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // إضافة جولة مع كشف الرقم القياسي PR تلقائياً وتحديد نوع الجولة
  bool logSet({
    required String exerciseId,
    required double weightKg,
    required int reps,
    double? rpe,
    String setType = 'normal',
    String? notes,
  }) {
    if (_activeSession == null) return false;

    final exercise = _exercises.firstWhere((e) => e.id == exerciseId);
    bool isNewPr = false;

    // جولات التسخين لا تكسر أرقام قياسية PR
    if (setType != 'warmup' && weightKg > exercise.personalBest) {
      isNewPr = true;
      exercise.personalBest = weightKg;
    }

    final existingSets = _activeSession!.sets.where((s) => s.exerciseId == exerciseId).toList();
    final newSet = SetLogItem(
      workoutSessionId: _activeSession!.id,
      exerciseId: exerciseId,
      setNumber: existingSets.length + 1,
      weightKg: weightKg,
      reps: reps,
      rpe: rpe,
      isPr: isNewPr,
      setType: setType,
      notes: notes,
    );

    _activeSession!.sets.add(newSet);
    notifyListeners();
    return isNewPr;
  }

  // حذف جولة أثناء التمرين
  void deleteSet(String setId) {
    if (_activeSession == null) return;
    _activeSession!.sets.removeWhere((s) => s.id == setId);
    notifyListeners();
  }

  // تعديل جولة أثناء التمرين
  void updateSet(String setId, {double? weightKg, int? reps, String? setType}) {
    if (_activeSession == null) return;
    final idx = _activeSession!.sets.indexWhere((s) => s.id == setId);
    if (idx != -1) {
      if (weightKg != null) _activeSession!.sets[idx].weightKg = weightKg;
      if (reps != null) _activeSession!.sets[idx].reps = reps;
      if (setType != null) _activeSession!.sets[idx].setType = setType;
      notifyListeners();
    }
  }

  // إنهاء التمرين وحفظه في السجل وإرجاع الجلسة المكتملة
  WorkoutSessionItem? finishWorkout() {
    if (_activeSession != null) {
      _activeSession!.endedAt = DateTime.now();
      final completed = _activeSession!;
      _sessions.insert(0, completed);
      _activeSession = null;
      notifyListeners();
      syncWithBackend();
      return completed;
    }
    return null;
  }

  // حذف جلسة من السجل
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  // حاسبة بليتات البار الأولمبي
  Map<double, int> calculatePlates(double totalWeightKg, {double barWeightKg = 20.0}) {
    final Map<double, int> result = {};
    double weightPerSide = (totalWeightKg - barWeightKg) / 2.0;
    if (weightPerSide <= 0) return result;

    final availablePlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
    for (var p in availablePlates) {
      if (weightPerSide >= p) {
        int count = (weightPerSide / p).floor();
        result[p] = count;
        weightPerSide -= (count * p);
        weightPerSide = double.parse(weightPerSide.toStringAsFixed(2));
      }
    }
    return result;
  }

  // توليد تقرير مشاركة التمرينة للأصدقاء وشبكات التواصل
  String generateWorkoutShareText(WorkoutSessionItem session) {
    final duration = session.durationMinutes;
    final totalVol = session.totalVolume.toStringAsFixed(0);
    final prs = session.sets.where((s) => s.isPr).length;
    
    final buffer = StringBuffer();
    buffer.writeln('🏋️‍♂️ IRONLOG - تقرير جلسة التدريب');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📌 التمرينة: ${session.name}');
    buffer.writeln('⏱️ المدة: $duration دقيقة');
    buffer.writeln('⚡ إجمالي الحجم: $totalVol كجم');
    buffer.writeln('🔥 إجمالي الجولات: ${session.totalSets} جولة');
    if (prs > 0) {
      buffer.writeln('🏆 أرقام قياسية جديدة: $prs PRs!');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💪 سجل تمرينك وطوّر مستواك مع IRONLOG');
    return buffer.toString();
  }

  // تصدير البيانات إلى CSV
  String exportDataToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Session Name,Started At,Ended At,Exercise ID,Set Number,Weight KG,Reps,Set Type,Is PR');
    for (var s in _sessions) {
      for (var st in s.sets) {
        buffer.writeln('"${s.name}","${s.startedAt}","${s.endedAt ?? ''}","${st.exerciseId}",${st.setNumber},${st.weightKg},${st.reps},"${st.setType}",${st.isPr}');
      }
    }
    return buffer.toString();
  }

  // تصدير البيانات إلى JSON
  String exportDataToJson() {
    return jsonEncode({
      'athlete_name': _athleteName,
      'exported_at': DateTime.now().toIso8601String(),
      'sessions_count': _sessions.length,
      'sessions': _sessions.map((s) => s.toJson()).toList(),
      'custom_routines': _routines.where((r) => !r.isSystem).map((r) => r.toJson()).toList(),
      'body_weights': _bodyWeights.map((b) => b.toJson()).toList(),
    });
  }

  // جلب البيانات من السيرفر عند تسجيل الدخول
  Future<void> pullFromBackend() async {
    if (_authToken == null) return;
    try {
      final res = await http.get(
        Uri.parse('$apiUrl/sync/pull'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['sessions'] is List) {
          final serverSessions = (data['sessions'] as List)
              .map((s) => WorkoutSessionItem.fromJson(s as Map<String, dynamic>))
              .toList();
          for (var s in serverSessions) {
            if (!_sessions.any((loc) => loc.id == s.id)) {
              _sessions.add(s);
            }
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  // مزامنة البيانات مع لارفيل API
  Future<void> syncWithBackend() async {
    try {
      final pendingSessions = _sessions.where((s) => s.syncStatus == 'pending').toList();
      if (pendingSessions.isEmpty) return;

      final body = {
        'sessions': pendingSessions.map((s) => s.toJson()).toList(),
        'sets': pendingSessions.expand((s) => s.sets).map((st) => st.toJson()).toList(),
      };

      final response = await http.post(
        Uri.parse('$apiUrl/sync/push'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        for (var s in pendingSessions) {
          s.syncStatus = 'synced';
          for (var st in s.sets) {
            st.syncStatus = 'synced';
          }
        }
        notifyListeners();
      }
    } catch (_) {
      // وضع الأوفلاين: لا توجد مشكلة، السجلات محفوظة محلياً
    }
  }

  void setActiveRoutine(WorkoutRoutineItem r) {
    _activeRoutine = r;
    _selectedDay = r.days.isNotEmpty ? r.days.first : null;
    notifyListeners();
  }

  void selectDay(RoutineDayItem d) {
    _selectedDay = d;
    notifyListeners();
  }

  void toggleBiometrics() {
    _isBiometricEnabled = !_isBiometricEnabled;
    notifyListeners();
  }

  // إحصائيات لوحة التحكم المحسوبة من الجلسات الفعلية
  double get weeklyVolumeKg {
    double vol = 0;
    for (var s in _sessions) {
      vol += s.totalVolume;
    }
    return vol;
  }
  int get workoutsDoneThisWeek => _sessions.length;
  int get totalWorkoutsGoal => _activeRoutine?.daysCount ?? 4;
  int get totalPersonalRecords => _exercises.where((e) => e.personalBest > 0).length;
  int get streak => _sessions.isEmpty ? 0 : 1;

  // دوال تسجيل الدخول وإنشاء الحساب
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'phone': phone.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 || (data is Map && data['status'] == 'success')) {
        _authToken = data['token'];
        _athleteName = data['user']?['name'] ?? name;
        _athletePhone = data['user']?['phone'] ?? phone;
        _athleteEmail = data['user']?['email'] ?? (email ?? '');
        _isLoggedIn = true;
        notifyListeners();
        BiometricService.saveLinkedUser(phone: _athletePhone, name: _athleteName, token: _authToken);
        return {'success': true, 'message': data['message'] ?? 'تم إنشاء الحساب بنجاح'};
      } else {
        String msg = data['message'] ?? 'حدث خطأ أثناء إنشاء الحساب';
        if (data['errors'] is Map) {
          final errs = (data['errors'] as Map).values.expand((e) => e is List ? e : [e]).join('\n');
          if (errs.isNotEmpty) msg = errs;
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': isArabic
            ? 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل السيرفر أو الاتصال بالإنترنت'
            : 'Could not connect to server. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && (data is Map && data['status'] == 'success')) {
        _authToken = data['token'];
        final serverName = data['user']?['name']?.toString() ?? '';
        if (serverName.isNotEmpty && !RegExp(r'^[\+\d\s\-]+$').hasMatch(serverName)) {
          _athleteName = serverName;
        } else if (_athleteName.isEmpty || RegExp(r'^[\+\d\s\-]+$').hasMatch(_athleteName)) {
          _athleteName = isArabic ? 'محمد سليمان' : 'Suliman';
        }
        _athletePhone = data['user']?['phone'] ?? phone;
        _athleteEmail = data['user']?['email'] ?? '';
        _isLoggedIn = true;
        notifyListeners();
        BiometricService.saveLinkedUser(phone: _athletePhone, name: _athleteName, token: _authToken);
        pullFromBackend();
        return {'success': true, 'message': data['message'] ?? 'تم تسجيل الدخول بنجاح'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'رقم الهاتف أو كلمة المرور غير صحيحة'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': isArabic
            ? 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل السيرفر أو الاتصال بالإنترنت'
            : 'Could not connect to server. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> loginWithBiometrics() async {
    // 1. التحقق الصارم: هل يوجد حساب مسجل بالفعل ومربوط بالبصمة على هذا الجهاز؟
    final hasLinked = await BiometricService.hasLinkedUser();
    if (!hasLinked) {
      return {
        'success': false,
        'message': isArabic
            ? 'لا يوجد حساب مرتبط بالبصمة على هذا الجهاز! يجب تسجيل الدخول أو إنشاء حساب أولاً.'
            : 'No account linked with biometrics on this device. Please log in or sign up first.',
      };
    }

    // 2. استدعاء مستشعر البصمة الحقيقي للجهاز (Android Native BiometricPrompt)
    final authResult = await BiometricService.authenticateWithResult(
      localizedReason: isArabic
          ? 'يرجى وضع بصمتك على مستشعر الهاتف لتسجيل الدخول إلى حسابك'
          : 'Scan your fingerprint to access your IRONLOG account',
      isArabic: isArabic,
    );

    if (!authResult.success) {
      return {
        'success': false,
        'message': authResult.errorMessage ??
            (isArabic ? 'فشلت المصادقة بالبصمة أو تم إلغاؤها' : 'Fingerprint authentication cancelled'),
      };
    }

    // 3. استرجاع بيانات المستخدم الفعلي المرتبط بالبصمة على الهاتف
    final linked = await BiometricService.getLinkedUser();
    if (linked == null || linked['phone'] == null || linked['phone']!.isEmpty) {
      return {
        'success': false,
        'message': isArabic
            ? 'تعذر العثور على بيانات الحساب المرتبط'
            : 'Could not retrieve linked account credentials',
      };
    }

    _athletePhone = linked['phone']!;
    _athleteName = linked['name']!.isNotEmpty ? linked['name']! : (isArabic ? 'بطل الحديد' : 'Athlete');
    _authToken = linked['token'];

    _isLoggedIn = true;
    _isBiometricEnabled = true;
    notifyListeners();
    pullFromBackend();
    return {
      'success': true,
      'message': isArabic ? 'تم تأكيد البصمة والدخول بنجاح' : 'Fingerprint authenticated successfully',
    };
  }

  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone.trim(),
          'password': newPassword,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && (data is Map && data['status'] == 'success')) {
        return {'success': true, 'message': data['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'فشلت عملية إعادة تعيين كلمة المرور'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': isArabic
            ? 'تعذر الاتصال بالخادم لإعادة تعيين كلمة المرور، يرجى التحقق من اتصالك'
            : 'Could not connect to server to reset password. Please check your connection.',
      };
    }
  }

  void logout() {
    _authToken = null;
    _athleteName = '';
    _athletePhone = '';
    _athleteEmail = '';
    _isLoggedIn = false;
    notifyListeners();
  }

  double calculateTotalVolumeToday() => _activeSession?.totalVolume ?? 0.0;

  List<SetLogItem> getPreviousLogs(String exerciseId) => getLastSessionSetsForExercise(exerciseId);

  void addCustomExercise({
    required String nameAr,
    required String nameEn,
    required String muscleGroupId,
    required String equipment,
  }) {
    final newEx = ExerciseItem(
      id: const Uuid().v4(),
      muscleGroupId: muscleGroupId,
      nameAr: nameAr,
      nameEn: nameEn,
      equipment: equipment,
      isCustom: true,
    );
    _exercises.add(newEx);
    notifyListeners();
  }

  void createCustomRoutine({
    required String title,
    String description = '',
    required int daysCount,
    List<String>? dayNames,
  }) {
    final routineId = const Uuid().v4();
    final List<RoutineDayItem> days = [];

    for (int i = 1; i <= daysCount; i++) {
      final defaultName = isArabic ? 'اليوم 0$i' : 'Day 0$i';
      final name = (dayNames != null && dayNames.length >= i && dayNames[i - 1].trim().isNotEmpty)
          ? dayNames[i - 1].trim()
          : defaultName;

      days.add(RoutineDayItem(
        id: const Uuid().v4(),
        routineId: routineId,
        dayNumber: i,
        dayName: name,
        exercises: [],
      ));
    }

    final newRoutine = WorkoutRoutineItem(
      id: routineId,
      title: title,
      description: description.isEmpty
          ? (isArabic ? 'جدول تدريبي مخصص صممه اللاعب بحرية.' : 'Custom personalized training split.')
          : description,
      daysCount: daysCount,
      isSystem: false,
      isActive: false,
      days: days,
    );

    _routines.add(newRoutine);
    setActiveRoutine(newRoutine);
    notifyListeners();
  }

  void deleteRoutine(String routineId) {
    _routines.removeWhere((r) => r.id == routineId && !r.isSystem);
    if (_activeRoutine?.id == routineId) {
      _activeRoutine = _routines.first;
      _selectedDay = _activeRoutine?.days.isNotEmpty == true ? _activeRoutine!.days.first : null;
    }
    notifyListeners();
  }
}
