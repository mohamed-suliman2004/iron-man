import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/plate_calculator_dialog.dart';
import 'live_workout_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final isWide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الصفحة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.t('current_date'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(workout.t('evening_greeting'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        Text('${workout.athleteDisplayName}.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.primaryNeon)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(workout.t('goal_step'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // بادج الحماس اليومي (Streak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: AppTheme.goldPR, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${workout.streak}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        Text(workout.t('day_streak'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // كارت تمرين اليوم الرئيسي (Today's Workout Card)
          _buildTodayWorkoutCard(context, workout),
          const SizedBox(height: 20),

          // شبكة الإحصائيات (Stat Cards)
          _buildStatGrid(context, workout, isWide),
          const SizedBox(height: 20),

          // المخطط الأسبوعي وقائمة الأرقام القياسية الأخيرة
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildWeeklyVolumeChart(workout)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildRecentBests(workout)),
              ],
            )
          else ...[
            _buildWeeklyVolumeChart(workout),
            const SizedBox(height: 20),
            _buildRecentBests(workout),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutCard(BuildContext context, WorkoutProvider workout) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNeon,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(workout.t('today_workout_badge'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.t('push_day_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(workout.t('push_muscles'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center_outlined, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(workout.t('exercises_count'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(workout.t('workout_duration'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNeon,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            workout.startWorkout();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LiveWorkoutScreen()),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow, size: 18),
                              const SizedBox(width: 8),
                              Text(workout.t('start_workout'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 6),
                              Icon(workout.isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 14),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.border),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.calculate_outlined, color: AppTheme.primaryNeon, size: 18),
                          label: Text(
                            workout.t('open_plate_calc'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          onPressed: () => PlateCalculatorDialog.show(context, initialWeight: 60.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // الجرافيك الدائري
              Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.3), width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: '01', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                            TextSpan(text: ' / 04', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(workout.t('built_quote'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(workout.t('up_next'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text(workout.t('incline_db'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, WorkoutProvider workout, bool isWide) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: workout.t('weekly_volume'),
            value: workout.weeklyVolumeKg == 0 ? '0' : workout.weeklyVolumeKg.toStringAsFixed(0),
            unit: workout.isArabic ? 'كجم' : 'kg',
            badgeText: workout.weeklyVolumeKg > 0 ? '+8.4%' : null,
            badgeColor: AppTheme.primaryNeon,
            icon: Icons.show_chart,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            title: workout.t('workouts_done'),
            value: workout.workoutsDoneThisWeek.toString().padLeft(2, '0'),
            unit: '/ ${workout.totalWorkoutsGoal.toString().padLeft(2, '0')}',
            progress: workout.totalWorkoutsGoal > 0 ? (workout.workoutsDoneThisWeek / workout.totalWorkoutsGoal).clamp(0.0, 1.0) : 0.0,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            title: workout.t('personal_records'),
            value: workout.totalPersonalRecords.toString().padLeft(2, '0'),
            actionText: '${workout.t('view_all')} ↗',
            icon: Icons.emoji_events_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    String? unit,
    String? badgeText,
    Color? badgeColor,
    double? progress,
    String? actionText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textMuted, size: 16),
              const Spacer(),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppTheme.primaryNeon).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badgeText, style: TextStyle(color: badgeColor ?? AppTheme.primaryNeon, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              if (actionText != null)
                Text(actionText, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                if (unit != null)
                  TextSpan(text: ' $unit', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceHighlight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyVolumeChart(WorkoutProvider workout) {
    final days = workout.isArabic
        ? ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final heights = workout.sessions.isEmpty
        ? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        : [0.4, 0.7, 0.9, 0.6, 0.85, 0.2, 0.0];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.t('progression_rate'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(workout.t('week_at_glance'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(workout.t('this_week'), style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(workout.weeklyVolumeKg == 0 ? '0' : workout.weeklyVolumeKg.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(workout.isArabic ? ' كجم' : ' kg', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 8),
              if (workout.weeklyVolumeKg > 0)
                Text(workout.t('volume_increase'), style: TextStyle(color: AppTheme.primaryNeon.withValues(alpha: 0.9), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 25),
          // أعمدة الرسم البياني للـ 7 أيام
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final h = heights[index];
              final hasWorkout = h > 0;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 100 * h + 8,
                    decoration: BoxDecoration(
                      color: hasWorkout ? AppTheme.primaryNeon : AppTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[index], style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBests(WorkoutProvider workout) {
    final exercisesWithBests = workout.exercises.where((e) => e.personalBest > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workout.t('earned_records'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(workout.t('recent_bests'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (exercisesWithBests.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.fitness_center, color: AppTheme.textMuted, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    workout.t('no_prs_yet'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...exercisesWithBests.take(3).map((ex) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPR.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.emoji_events, color: AppTheme.goldPR, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name(workout.isArabic), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${ex.targetMuscle} · PR', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text('${ex.personalBest.toStringAsFixed(1)} ${workout.isArabic ? 'كجم' : 'kg'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
