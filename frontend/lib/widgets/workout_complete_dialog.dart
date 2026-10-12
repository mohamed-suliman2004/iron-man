import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../services/audio_feedback.dart';
import '../theme/app_theme.dart';

class WorkoutCompleteDialog extends StatelessWidget {
  final WorkoutSessionItem session;

  const WorkoutCompleteDialog({super.key, required this.session});

  static void show(BuildContext context, WorkoutSessionItem session) {
    AudioFeedbackService.playPrCelebration();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WorkoutCompleteDialog(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final prSets = session.sets.where((s) => s.isPr).toList();
    final prExercises = prSets.map((s) => s.exerciseId).toSet().toList();
    final duration = session.durationMinutes;
    final totalVol = session.totalVolume;

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.primaryNeon, width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة الاحتفال والشعلة
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryNeon, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.emoji_events, color: AppTheme.goldPR, size: 36),
                ),
              ),
              const SizedBox(height: 16),

              // العنوان الرئيسي
              Text(
                workout.t('summary_headline'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${session.name} · ${workout.t('summary_subtitle')}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // شبكة الإحصائيات الثلاثية
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      icon: Icons.timer_outlined,
                      value: '$duration',
                      unit: workout.isArabic ? 'دقيقة' : 'min',
                      label: workout.t('workout_duration_stat'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statBox(
                      icon: Icons.fitness_center_outlined,
                      value: totalVol >= 1000 ? (totalVol / 1000).toStringAsFixed(1) : totalVol.toStringAsFixed(0),
                      unit: totalVol >= 1000 ? (workout.isArabic ? 'طن' : 'tons') : workout.t('kg_unit'),
                      label: workout.t('volume_lifted_stat'),
                      isNeon: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statBox(
                      icon: Icons.format_list_numbered,
                      value: '${session.totalSets}',
                      unit: workout.t('sets_unit'),
                      label: workout.t('sets_logged_stat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // كارت الأرقام القياسية المحطمة إن وجدت
              if (prSets.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPR.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.goldPR.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium, color: AppTheme.goldPR, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            workout.t('prs_broken_title'),
                            style: const TextStyle(color: AppTheme.goldPR, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...prExercises.map((exId) {
                        final ex = workout.exercises.firstWhere(
                          (e) => e.id == exId,
                          orElse: () => ExerciseItem(id: '', muscleGroupId: 'chest', nameAr: 'تمرين', nameEn: 'Exercise', equipment: 'Barbell'),
                        );
                        final maxPrSet = prSets.where((s) => s.exerciseId == exId).reduce((curr, next) => curr.weightKg > next.weightKg ? curr : next);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text('•  ${workout.isArabic ? ex.nameAr : ex.nameEn}:', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldPR,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${maxPrSet.weightKg} ${workout.t('kg_unit')} × ${maxPrSet.reps}',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigher,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppTheme.primaryNeon, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          workout.t('no_prs_today'),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // أزرار المشاركة والإنهاء
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 16),
                      label: Text(
                        workout.t('share_card_btn'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        final text = workout.generateWorkoutShareText(session);
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.surfaceHigher,
                            content: Text(
                              workout.t('share_copied'),
                              style: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNeon,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        workout.t('finish_and_close'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    bool isNeon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigher,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isNeon ? AppTheme.primaryNeon.withValues(alpha: 0.5) : AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: isNeon ? AppTheme.primaryNeon : AppTheme.textMuted),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isNeon ? AppTheme.primaryNeon : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
