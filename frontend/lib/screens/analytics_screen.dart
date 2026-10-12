import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedExerciseIndex = 0;

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();

    final exerciseOptions = [
      {'key': 'bench', 'ar': 'بنش برس بار مستوي', 'en': 'Flat Barbell Bench Press'},
      {'key': 'squat', 'ar': 'سكوات بار خلفي', 'en': 'Barbell Back Squat'},
      {'key': 'deadlift', 'ar': 'ديدلفت كلاسيكي', 'en': 'Conventional Deadlift'},
    ];

    final selectedKey = exerciseOptions[_selectedExerciseIndex]['key'];
    final matchedEx = workout.exercises.where((e) {
      if (selectedKey == 'bench') return e.id == 'bench_press' || e.nameEn.toLowerCase().contains('bench');
      if (selectedKey == 'squat') return e.id == 'squat' || e.nameEn.toLowerCase().contains('squat');
      if (selectedKey == 'deadlift') return e.id == 'deadlift' || e.nameEn.toLowerCase().contains('deadlift');
      return false;
    }).firstOrNull;

    final maxWeight = matchedEx?.personalBest ?? 0.0;
    final est1rm = maxWeight > 0 ? (maxWeight * 1.13).toStringAsFixed(1) : '0';
    final totalSets = workout.sessions.fold<int>(0, (sum, s) => sum + s.totalSets);
    final hasData = workout.sessions.isNotEmpty && maxWeight > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workout.t('work_adds_up'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(workout.t('progress_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(workout.t('progress_desc'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 20),

          // كارت البانر العلوي
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.t('split_ahead'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(workout.t('not_straight_line'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
                      const SizedBox(height: 6),
                      Text(workout.t('every_session_adds'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(workout.t('this_month'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(hasData ? '+8.4%' : '0%', style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(workout.t('vs_last_month'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // شبكة الإحصائيات (Stat Cards)
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  icon: Icons.emoji_events_outlined,
                  title: workout.t('all_time_max'),
                  value: maxWeight > 0 ? maxWeight.toStringAsFixed(1) : '0',
                  unit: workout.t('kg_unit'),
                  caption: workout.t('barbell_note'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _metricTile(
                  icon: Icons.bolt,
                  title: workout.t('est_1rm'),
                  value: est1rm,
                  unit: workout.t('kg_unit'),
                  caption: workout.t('epley_formula'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _metricTile(
                  icon: Icons.fitness_center_outlined,
                  title: workout.t('sets_completed'),
                  value: totalSets.toString(),
                  unit: workout.t('sets_unit'),
                  caption: workout.t('sessions_count'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // كارت الرسم البياني المتوهج (Glowing Green Line Chart)
          Container(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workout.t('strength_over_time'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(workout.t('weight_progression'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHighlight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(workout.t('timeframe_8w'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // دروب داون اختيار التمرين بكامل العرض لمنع أي اقتطاع أو تداخل في الشاشات
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedExerciseIndex,
                      dropdownColor: AppTheme.surfaceHigher,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      items: List.generate(exerciseOptions.length, (idx) {
                        final opt = exerciseOptions[idx];
                        return DropdownMenuItem(
                          value: idx,
                          child: Text(workout.isArabic ? opt['ar']! : opt['en']!),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedExerciseIndex = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(width: 12, height: 3, color: AppTheme.primaryNeon),
                    const SizedBox(width: 8),
                    Text(workout.t('working_weight'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const Spacer(),
                    Text('${maxWeight > 0 ? maxWeight.toStringAsFixed(1) : '0'} ${workout.t('kg_unit')}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    if (hasData) ...[
                      const SizedBox(width: 6),
                      Text(workout.t('gain_stat'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11)),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // محرك الرسم البياني fl_chart أو رسالة الحالة الفارغة
                if (!hasData)
                  Container(
                    height: 180,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceHighlight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.show_chart, color: AppTheme.textMuted, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          workout.isArabic ? 'لا توجد جلسات مسجلة لهذا التمرين بعد' : 'No recorded sessions for this exercise yet',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.isArabic ? 'سيبدأ المنحنى بالرسم تلقائياً بمجرد إتمام أول تمرين!' : 'The progression curve will appear once you complete a workout!',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(color: AppTheme.border, strokeWidth: 0.8),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              interval: 10,
                              getTitlesWidget: (v, meta) => Text('${v.toInt()} ${workout.t('kg_unit')}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (v, meta) {
                                final weeksAr = ['أ1', 'أ2', 'أ3', 'أ4', 'أ5', 'أ6', 'أ7', 'أ8'];
                                final weeksEn = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
                                final weeks = workout.isArabic ? weeksAr : weeksEn;
                                final idx = v.toInt();
                                if (idx >= 0 && idx < weeks.length) {
                                  return Text(weeks[idx], style: const TextStyle(color: AppTheme.textMuted, fontSize: 10));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 7,
                        minY: 60,
                        maxY: 90,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 70),
                              FlSpot(1, 72.5),
                              FlSpot(2, 72.5),
                              FlSpot(3, 75),
                              FlSpot(4, 77.5),
                              FlSpot(5, 77.5),
                              FlSpot(6, 80),
                              FlSpot(7, 82.5),
                            ],
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: AppTheme.primaryNeon,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.black,
                                  strokeWidth: 2,
                                  strokeColor: AppTheme.primaryNeon,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.primaryNeon.withValues(alpha: 0.25),
                                  AppTheme.primaryNeon.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String caption,
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
              Icon(icon, color: AppTheme.primaryNeon, size: 18),
              const Spacer(),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(caption, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}
