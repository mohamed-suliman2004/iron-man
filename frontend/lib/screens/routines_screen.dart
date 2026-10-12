import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final activeRoutine = workout.activeRoutine;
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
                    Text(workout.t('blueprints'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(workout.t('routines_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(workout.t('routines_desc'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              // زر إنشاء جدول مخصص جديد
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(workout.t('create_custom_routine_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => _showCreateCustomRoutineDialog(context, workout),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // كارت التحفيز الترويجي
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
                      Text(workout.t('custom_rules'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(workout.t('build_week'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(workout.t('choose_split'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('01', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // قسم 1: شبكة الجداول (المعتمدة والمخصصة)
          Row(
            children: [
              Text(workout.t('proven_systems'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${workout.routines.length} ${workout.t('routines_title')}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text(workout.t('ready_splits'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isWide ? 1.45 : 1.15,
            ),
            itemCount: workout.routines.length + 1, // +1 for the "Create Custom" card
            itemBuilder: (context, index) {
              // الكارت الأخير: إضافة جدول مخصص جديد
              if (index == workout.routines.length) {
                return InkWell(
                  onTap: () => _showCreateCustomRoutineDialog(context, workout),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryNeon.withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppTheme.primaryNeon, size: 22),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            workout.t('make_yours'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workout.isArabic ? 'صمم جدولك بأيامك الخاصة' : 'Build your own split',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final r = workout.routines[index];
              final isSelected = activeRoutine?.id == r.id;

              return InkWell(
                onTap: () {
                  workout.setActiveRoutine(r);
                  setState(() {
                    _selectedDayIndex = 0;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryNeon : AppTheme.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('0${index + 1}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          if (!r.isSystem)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(workout.t('custom_badge'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 8, fontWeight: FontWeight.bold)),
                            )
                          else if (index == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceHighlight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(workout.t('most_used'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          if (!r.isSystem) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => workout.deleteRoutine(r.id),
                              child: const Icon(Icons.delete_outline, size: 14, color: AppTheme.textMuted),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Text(r.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('${r.daysCount} ${workout.t('days_per_week_label')}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                          const Spacer(),
                          if (isSelected)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryNeon,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // قسم 2: تفاصيل أيام وتمارين الجدول المختار
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.t('make_yours'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${workout.isArabic ? 'تمارين جدول:' : 'Routine Exercises:'} ${activeRoutine?.title ?? ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      if (activeRoutine != null && !activeRoutine.isSystem) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(workout.t('custom_badge'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (activeRoutine != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        '${activeRoutine.days.length} ${workout.t('days_count_unit')}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // تابز الأيام (Day Tabs)
                if (activeRoutine != null && activeRoutine.days.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(activeRoutine.days.length, (i) {
                        final d = activeRoutine.days[i];
                        final isSel = _selectedDayIndex == i;
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedDayIndex = i);
                            workout.selectDay(d);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: EdgeInsets.only(left: workout.isArabic ? 10 : 0, right: !workout.isArabic ? 10 : 0),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.surfaceHighlight : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? AppTheme.primaryNeon : AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Text('${workout.t('day_label')} 0${d.dayNumber}  ', style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold)),
                                Text(d.dayName, style: TextStyle(color: isSel ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${d.exercises.length} ${workout.t('exercises_label')}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // تمارين اليوم المختار وترتيبها
                  if (_selectedDayIndex < activeRoutine.days.length)
                    _buildDayExerciseOrder(activeRoutine.days[_selectedDayIndex], workout),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.fitness_center, color: AppTheme.textMuted, size: 36),
                          const SizedBox(height: 10),
                          Text(
                            workout.isArabic ? 'لا توجد أيام مضافة لهذا الجدول بعد' : 'No training days in this routine yet',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDayExerciseOrder(RoutineDayItem day, WorkoutProvider workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${workout.t('exercise_order')} (${day.exercises.length})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16, color: AppTheme.primaryNeon),
              label: Text(workout.t('add_exercise_to_day'), style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                _showAddExerciseDialog(context, day, workout);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (day.exercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHighlight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.add_circle_outline, color: AppTheme.primaryNeon, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    workout.t('empty_custom_day_hint'),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(day.exercises.length, (idx) {
            final rEx = day.exercises[idx];
            final ex = workout.exercises.firstWhere(
              (e) => e.id == rEx.exerciseId,
              orElse: () => ExerciseItem(id: '?', muscleGroupId: 'chest', nameAr: 'تمرين', nameEn: 'Exercise', equipment: 'Barbell'),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        color: AppTheme.primaryNeon,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          workout.isArabic ? ex.nameAr : ex.nameEn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${workout.isArabic ? ex.nameEn : ex.nameAr} · ${ex.equipment}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      '${rEx.targetSets} ${workout.t('sets_count')}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      setState(() {
                        day.exercises.removeAt(idx);
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close, color: AppTheme.textMuted, size: 16),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showCreateCustomRoutineDialog(BuildContext context, WorkoutProvider workout) {
    final titleCtrl = TextEditingController(text: workout.isArabic ? 'جدولي المخصص الجديد' : 'My Custom Split');
    final descCtrl = TextEditingController();
    int daysCount = 4;
    final List<TextEditingController> dayControllers = List.generate(
      7,
      (i) => TextEditingController(text: workout.isArabic ? 'اليوم 0${i + 1}' : 'Day 0${i + 1}'),
    );

    // مقترحات أسماء للأيام حسب العدد
    void updateDefaultDayNames(int count) {
      if (workout.isArabic) {
        if (count == 3) {
          dayControllers[0].text = 'يوم الدفع (Push: صدر، كتف، تراي)';
          dayControllers[1].text = 'يوم السحب (Pull: ظهر، باي)';
          dayControllers[2].text = 'يوم الأرجل والبطن (Legs & Abs)';
        } else if (count == 4) {
          dayControllers[0].text = 'عضلة علوية أ (Upper A)';
          dayControllers[1].text = 'عضلة سفلية أ (Lower A)';
          dayControllers[2].text = 'عضلة علوية ب (Upper B)';
          dayControllers[3].text = 'عضلة سفلية ب (Lower B)';
        } else if (count == 5) {
          dayControllers[0].text = 'يوم الصدر (Chest)';
          dayControllers[1].text = 'يوم الظهر (Back)';
          dayControllers[2].text = 'يوم الأكتاف (Shoulders)';
          dayControllers[3].text = 'يوم الأرجل (Legs)';
          dayControllers[4].text = 'يوم الأذرع (Arms)';
        }
      }
    }

    updateDefaultDayNames(daysCount);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.fitness_center, color: AppTheme.primaryNeon, size: 20),
              const SizedBox(width: 8),
              Text(
                workout.t('custom_routine_modal_title'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الجدول
                  Text(workout.t('routine_name_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surfaceHigher,
                      hintText: workout.t('routine_name_hint'),
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // وصف الجدول
                  Text(workout.t('routine_desc_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surfaceHigher,
                      hintText: workout.t('routine_desc_hint'),
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // اختيار عدد الأيام
                  Text(workout.t('days_count_selection'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [2, 3, 4, 5, 6].map((n) {
                      final isSel = daysCount == n;
                      return ChoiceChip(
                        label: Text('$n ${workout.t('days_count_unit')}'),
                        selected: isSel,
                        selectedColor: AppTheme.primaryNeon,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: AppTheme.surfaceHigher,
                        side: BorderSide(color: isSel ? AppTheme.primaryNeon : AppTheme.border),
                        onSelected: (val) {
                          if (val) {
                            setDialogState(() {
                              daysCount = n;
                              updateDefaultDayNames(n);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // تسمية كل يوم
                  Text(workout.t('day_names_title'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(daysCount, (idx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${workout.t('day_label')} 0${idx + 1}',
                              style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: dayControllers[idx],
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.surfaceHigher,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.border)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(workout.t('cancel_btn'), style: const TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeon,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final dayNames = List.generate(daysCount, (i) => dayControllers[i].text.trim());
                  workout.createCustomRoutine(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    daysCount: daysCount,
                    dayNames: dayNames,
                  );
                  setState(() => _selectedDayIndex = 0);
                  Navigator.pop(ctx);
                }
              },
              child: Text(workout.t('save_custom_routine'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, RoutineDayItem day, WorkoutProvider workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout.t('select_exercise_dialog'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: workout.exercises.length,
                  itemBuilder: (c, i) {
                    final ex = workout.exercises[i];
                    return ListTile(
                      title: Text(workout.isArabic ? ex.nameAr : ex.nameEn, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(workout.isArabic ? ex.nameEn : ex.nameAr, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      trailing: const Icon(Icons.add_circle_outline, color: AppTheme.primaryNeon, size: 20),
                      onTap: () {
                        setState(() {
                          day.exercises.add(RoutineExerciseItem(
                            id: UniqueKey().toString(),
                            exerciseId: ex.id,
                            orderIndex: day.exercises.length + 1,
                            targetSets: 3,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
