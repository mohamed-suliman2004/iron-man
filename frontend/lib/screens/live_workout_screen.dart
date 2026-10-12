import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../services/audio_feedback.dart';
import '../theme/app_theme.dart';
import '../widgets/plate_calculator_dialog.dart';
import '../widgets/workout_complete_dialog.dart';

class LiveWorkoutScreen extends StatefulWidget {
  const LiveWorkoutScreen({super.key});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  int _restSeconds = 90;
  bool _isRestTimerActive = false;
  Timer? _restTimer;

  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, String> _selectedSetTypes = {}; // 'normal', 'warmup', 'dropset', 'failure'

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  void _startRestTimer({int? durationSec}) {
    _restTimer?.cancel();
    final total = durationSec ?? context.read<WorkoutProvider>().restTimerDuration;
    setState(() {
      _restSeconds = total;
      _isRestTimerActive = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds > 1) {
        if (mounted) setState(() => _restSeconds--);
      } else {
        _restTimer?.cancel();
        if (mounted) {
          setState(() => _isRestTimerActive = false);
          AudioFeedbackService.playRestTimerDone();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              backgroundColor: AppTheme.primaryNeon,
              content: Text(
                context.read<WorkoutProvider>().t('time_up'),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }
    });
  }

  void _addRestTime(int sec) {
    if (_isRestTimerActive) {
      setState(() => _restSeconds += sec);
    } else {
      _startRestTimer(durationSec: sec);
    }
  }

  void _subRestTime(int sec) {
    if (_isRestTimerActive) {
      setState(() {
        _restSeconds = (_restSeconds - sec).clamp(1, 600);
      });
    }
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _isRestTimerActive = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    for (var c in _weightControllers.values) {
      c.dispose();
    }
    for (var c in _repsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final session = workout.activeSession;

    if (session == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: Text(workout.t('live_workout_title'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(workout.t('no_active_workout'), style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNeon, foregroundColor: Colors.black),
                onPressed: () {
                  workout.startWorkout();
                },
                child: Text(workout.t('start_workout'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final dayExercises = workout.selectedDay?.exercises ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              workout.t('live_workout_title'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${workout.t('elapsed')} ${_formatTime(_secondsElapsed)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // حاسبة البليتات السريعة
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: AppTheme.primaryNeon, size: 20),
            tooltip: workout.t('open_plate_calc'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => PlateCalculatorDialog.show(context, initialWeight: 60.0),
          ),
          // زر إنهاء التمرين
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeon,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final completedSession = workout.finishWorkout();
                Navigator.pop(context);
                if (completedSession != null) {
                  WorkoutCompleteDialog.show(context, completedSession);
                }
              },
              child: Text(workout.t('finish_workout'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // بانر مؤقت الراحة التفاعلي
            if (_isRestTimerActive) _buildRestTimerInteractiveBanner(workout),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // ملخص الجلسة الحالي في أعلى الشاشة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        _headerStat(workout.t('total_volume'), '${workout.calculateTotalVolumeToday().toStringAsFixed(0)} ${workout.t('kg_unit')}'),
                        _vDivider(),
                        _headerStat(workout.t('completed_sets'), '${session.sets.length} ${workout.t('sets_unit')}'),
                        _vDivider(),
                        _headerStat(workout.t('offline_ready'), 'OFFLINE', isNeon: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // قائمة تمارين اليوم
                  ...List.generate(dayExercises.length, (idx) {
                    final rEx = dayExercises[idx];
                    final ex = workout.exercises.firstWhere(
                      (e) => e.id == rEx.exerciseId,
                      orElse: () => ExerciseItem(id: '?', muscleGroupId: 'chest', nameAr: 'تمرين', nameEn: 'Exercise', equipment: 'Barbell'),
                    );

                    final setsForThisEx = session.sets.where((s) => s.exerciseId == ex.id).toList();
                    final previousLogs = workout.getPreviousLogs(ex.id);

                    return _buildExerciseLiveCard(context, workout, ex, rEx, setsForThisEx, previousLogs);
                  }),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildRestTimerInteractiveBanner(WorkoutProvider workout) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131D11),
        border: const Border(bottom: BorderSide(color: AppTheme.primaryNeon, width: 1.5)),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryNeon.withValues(alpha: 0.15), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppTheme.primaryNeon, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${workout.t('rest_timer_title')}: ${_formatTime(_restSeconds)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                workout.t('rest'),
                style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          // زر -15 ث
          InkWell(
            onTap: () => _subRestTime(15),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.surfaceHigher, borderRadius: BorderRadius.circular(6)),
              child: Text(workout.t('sub_15s'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 6),
          // زر +30 ث
          InkWell(
            onTap: () => _addRestTime(30),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.surfaceHigher, borderRadius: BorderRadius.circular(6)),
              child: Text(workout.t('add_30s'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 6),
          // زر تخطي الراحة
          InkWell(
            onTap: _skipRest,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
              child: Text(workout.t('skip_rest'), style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, {bool isNeon = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isNeon ? AppTheme.primaryNeon : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 30, color: AppTheme.border);
  }

  Widget _buildExerciseLiveCard(
    BuildContext context,
    WorkoutProvider workout,
    ExerciseItem ex,
    RoutineExerciseItem rEx,
    List<SetLogItem> currentSets,
    List<SetLogItem> previousLogs,
  ) {
    final weightCtrl = _weightControllers.putIfAbsent(ex.id, () => TextEditingController(text: previousLogs.isNotEmpty ? previousLogs.last.weightKg.toString() : '60'));
    final repsCtrl = _repsControllers.putIfAbsent(ex.id, () => TextEditingController(text: previousLogs.isNotEmpty ? previousLogs.last.reps.toString() : '8'));
    final currentSetType = _selectedSetTypes.putIfAbsent(ex.id, () => 'normal');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس التمرين
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.fitness_center, color: AppTheme.primaryNeon, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.isArabic ? ex.nameAr : ex.nameEn,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '${workout.isArabic ? ex.nameEn : ex.nameAr} · ${ex.equipment}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              // زر حاسبة البليتات المخصص لهذا التمرين
              IconButton(
                icon: const Icon(Icons.calculate_outlined, color: AppTheme.primaryNeon, size: 18),
                tooltip: workout.t('open_plate_calc'),
                onPressed: () {
                  final curW = double.tryParse(weightCtrl.text) ?? 60.0;
                  PlateCalculatorDialog.show(context, initialWeight: curW);
                },
              ),
              if (ex.personalBest > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPR.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PR: ${ex.personalBest} ${workout.t('kg_unit')}',
                    style: const TextStyle(color: AppTheme.goldPR, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 10),

          // السجل السابق المرجعي (Previous Session Comparison Reference)
          if (previousLogs.isNotEmpty) ...[
            Text(
              workout.t('last_time_lifted'),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: previousLogs.map((pSet) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${workout.t('sets_unit')} ${pSet.setNumber}: ${pSet.weightKg} ${workout.t('kg_unit')} × ${pSet.reps}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // الجولات المسجلة في الجلسة الحالية
          if (currentSets.isNotEmpty) ...[
            Text(
              workout.t('completed_sets_today'),
              style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...currentSets.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    // نوع الجولة (W, N, D, F)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _setTypeColor(s.setType).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _setTypeColor(s.setType), width: 1),
                      ),
                      child: Text(
                        _setTypeShort(s.setType),
                        style: TextStyle(color: _setTypeColor(s.setType), fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${workout.t('sets_unit')} 0${s.setNumber}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 14),
                    Text('${s.weightKg} ${workout.t('kg_unit')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    const Text('×', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text('${s.reps} ${workout.t('reps_label')}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    const Spacer(),
                    if (s.isPr)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.goldPR,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(workout.t('new_pr_badge'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9)),
                      )
                    else
                      const Icon(Icons.check_circle, color: AppTheme.primaryNeon, size: 16),
                    const SizedBox(width: 8),
                    // زر حذف الجولة
                    InkWell(
                      onTap: () => workout.deleteSet(s.id),
                      child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],

          // اختيار نوع الجولة التالية (Normal, Warmup, Dropset, Failure)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout.t('set_type_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _setTypeChip(ex.id, 'normal', workout.t('set_type_normal'), currentSetType),
                    const SizedBox(width: 6),
                    _setTypeChip(ex.id, 'warmup', workout.t('set_type_warmup'), currentSetType),
                    const SizedBox(width: 6),
                    _setTypeChip(ex.id, 'dropset', workout.t('set_type_dropset'), currentSetType),
                    const SizedBox(width: 6),
                    _setTypeChip(ex.id, 'failure', workout.t('set_type_failure'), currentSetType),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // إدخال جولة جديدة سريعة
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: workout.t('weight_kg_label'),
                    labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                    filled: true,
                    fillColor: AppTheme.surfaceHigher,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: repsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: workout.t('reps_label'),
                    labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                    filled: true,
                    fillColor: AppTheme.surfaceHigher,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final w = double.tryParse(weightCtrl.text) ?? 60.0;
                  final r = int.tryParse(repsCtrl.text) ?? 8;
                  workout.logSet(
                    exerciseId: ex.id,
                    weightKg: w,
                    reps: r,
                    setType: currentSetType,
                  );
                  _startRestTimer();
                },
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 16),
                    const SizedBox(width: 4),
                    Text(workout.t('log_set_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setTypeChip(String exId, String type, String label, String currentType) {
    final isSelected = currentType == type;
    final color = _setTypeColor(type);
    return InkWell(
      onTap: () => setState(() => _selectedSetTypes[exId] = type),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppTheme.surfaceHigher,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? color : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _setTypeColor(String type) {
    switch (type) {
      case 'warmup':
        return Colors.orangeAccent;
      case 'dropset':
        return Colors.cyanAccent;
      case 'failure':
        return Colors.redAccent;
      default:
        return AppTheme.primaryNeon;
    }
  }

  String _setTypeShort(String type) {
    switch (type) {
      case 'warmup':
        return 'W';
      case 'dropset':
        return 'D';
      case 'failure':
        return 'F';
      default:
        return 'N';
    }
  }
}
