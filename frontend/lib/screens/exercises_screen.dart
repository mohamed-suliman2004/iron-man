import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedMuscleKey = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final isWide = MediaQuery.of(context).size.width >= 750;

    final muscles = [
      {'key': 'all', 'label': workout.t('muscle_all')},
      {'key': 'chest', 'label': workout.t('muscle_chest')},
      {'key': 'back', 'label': workout.t('muscle_back')},
      {'key': 'shoulders', 'label': workout.t('muscle_shoulders')},
      {'key': 'legs', 'label': workout.t('muscle_legs')},
      {'key': 'arms', 'label': workout.t('muscle_arms')},
      {'key': 'core', 'label': workout.t('muscle_core')},
    ];

    final filtered = workout.exercises.where((e) {
      final matchesMuscle = _selectedMuscleKey == 'all' || e.muscleGroupId.toLowerCase() == _selectedMuscleKey.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          e.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.nameAr.contains(_searchQuery);
      return matchesMuscle && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.t('movement_catalog'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(workout.t('library_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(workout.t('library_desc'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text(workout.t('add_exercise_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => _showAddExerciseDialog(context, workout),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // كارت ملخص المكتبة
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: AppTheme.primaryNeon, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.t('movement_db'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${workout.exercises.length} ${workout.t('every_rep_counts')}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // شريط البحث
          Container(
            height: 42,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: workout.t('search_hint'),
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // فلاتر المجموعات العضلية في سطر مستقل مع شريط تمرير أفقي
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: muscles.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final m = muscles[idx];
                final isSel = _selectedMuscleKey == m['key'];
                return ChoiceChip(
                  label: Text(
                    m['label']!,
                    style: TextStyle(
                      color: isSel ? Colors.black : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: AppTheme.primaryNeon,
                  backgroundColor: AppTheme.surface,
                  side: BorderSide(color: isSel ? AppTheme.primaryNeon : AppTheme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  onSelected: (val) {
                    if (val) setState(() => _selectedMuscleKey = m['key']!);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // عرض التمارين (بطاقات ذكية للموبايل / جدول للشاشات الكبيرة)
          if (!isWide) ...[
            Column(
              children: filtered.map((ex) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNeon.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fitness_center, size: 16, color: AppTheme.primaryNeon),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              workout.isArabic ? ex.nameAr : ex.nameEn,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  ex.muscleGroupId.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '· ${ex.equipment}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHigher,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              workout.t('col_pr'),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ex.personalBest > 0 ? '${ex.personalBest} ${workout.t('kg_unit')}' : '--',
                              style: TextStyle(
                                color: ex.personalBest > 0 ? AppTheme.goldPR : AppTheme.textMuted,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  // رأس الجدول
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(workout.t('col_movement'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text(workout.t('col_muscle'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text(workout.t('col_equipment'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text(workout.t('col_pr'), textAlign: TextAlign.end, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  // صفوف التمارين
                  ...filtered.map((ex) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        // اسم التمرين
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              const Icon(Icons.fitness_center, size: 14, color: AppTheme.primaryNeon),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.isArabic ? ex.nameAr : ex.nameEn,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    workout.isArabic ? ex.nameEn : ex.nameAr,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // المجموعة العضلية
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(ex.muscleGroupId.toUpperCase(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                        // الأداة
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(ex.equipment, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                          ),
                        ),
                        // الرقم القياسي
                        Expanded(
                          flex: 2,
                          child: Text(
                            ex.personalBest > 0 ? '${ex.personalBest} ${workout.t('kg_unit')}' : '--',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: ex.personalBest > 0 ? Colors.white : AppTheme.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, WorkoutProvider workout) {
    final nameArCtrl = TextEditingController();
    final nameEnCtrl = TextEditingController();
    String muscle = 'chest';
    String equip = 'Barbell';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(workout.t('add_exercise_btn'), style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameArCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(labelText: 'الاسم بالعربية', labelStyle: TextStyle(color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameEnCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(labelText: 'Name in English', labelStyle: TextStyle(color: AppTheme.textMuted)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء / Cancel', style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNeon, foregroundColor: Colors.black),
            onPressed: () {
              if (nameArCtrl.text.isNotEmpty || nameEnCtrl.text.isNotEmpty) {
                workout.addCustomExercise(
                  nameAr: nameArCtrl.text.isEmpty ? nameEnCtrl.text : nameArCtrl.text,
                  nameEn: nameEnCtrl.text.isEmpty ? nameArCtrl.text : nameEnCtrl.text,
                  muscleGroupId: muscle,
                  equipment: equip,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ / Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
