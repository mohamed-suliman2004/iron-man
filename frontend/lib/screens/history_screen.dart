import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'live_workout_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  final Set<String> _expandedSessionIds = {};

  String _formatDate(DateTime dt, bool isArabic) {
    final now = DateTime.now();
    final diffDays = now.difference(dt).inDays;
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (diffDays == 0 && now.day == dt.day) {
      return '${isArabic ? 'اليوم' : 'Today'}, $timeStr';
    } else if (diffDays <= 1 && now.day - dt.day == 1) {
      return '${isArabic ? 'أمس' : 'Yesterday'}, $timeStr';
    } else {
      final monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      final monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final m = isArabic ? monthsAr[dt.month - 1] : monthsEn[dt.month - 1];
      return '${dt.day} $m ${dt.year} · $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final sessions = workout.sessions;

    final filteredSessions = sessions.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الصفحة
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.t('breadcrumb_history'),
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.t('history_header_title'),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.t('history_header_desc'),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (sessions.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(
                    workout.t('start_workout'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () {
                    workout.startWorkout();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveWorkoutScreen()));
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // كارت إجمالي الحجم والجلسات
          if (sessions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  _statSummaryItem(
                    label: workout.t('workouts_done'),
                    value: '${sessions.length}',
                    icon: Icons.history,
                  ),
                  _vDivider(),
                  _statSummaryItem(
                    label: workout.t('total_volume'),
                    value: '${workout.weeklyVolumeKg.toStringAsFixed(0)} ${workout.t('kg_unit')}',
                    icon: Icons.fitness_center,
                    isNeon: true,
                  ),
                  _vDivider(),
                  _statSummaryItem(
                    label: workout.t('personal_records'),
                    value: '${workout.totalPersonalRecords}',
                    icon: Icons.emoji_events,
                    isGold: true,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // شريط البحث
          if (sessions.isNotEmpty) ...[
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: workout.t('search_hint'),
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),
          ],

          // قائمة التمارين أو الحالة الفارغة
          if (sessions.isEmpty)
            _buildEmptyHistory(context, workout)
          else if (filteredSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  workout.isArabic ? 'لم يتم العثور على تمارين مطابقة لبحثك' : 'No workouts match your query',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSessions.length,
              itemBuilder: (context, index) {
                final session = filteredSessions[index];
                final isExpanded = _expandedSessionIds.contains(session.id);
                return _buildSessionCard(context, workout, session, isExpanded);
              },
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context, WorkoutProvider workout) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeon.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_toggle_off, color: AppTheme.primaryNeon, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            workout.t('empty_history_title'),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            workout.t('empty_history_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeon,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.play_arrow),
            label: Text(
              workout.t('start_workout'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () {
              workout.startWorkout();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveWorkoutScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    WorkoutProvider workout,
    WorkoutSessionItem session,
    bool isExpanded,
  ) {
    final prsCount = session.sets.where((s) => s.isPr).length;
    final duration = session.durationMinutes;

    // استخراج التمارين الفريدة في هذه الجلسة
    final Map<String, List<SetLogItem>> exerciseSetsMap = {};
    for (var s in session.sets) {
      exerciseSetsMap.putIfAbsent(s.exerciseId, () => []).add(s);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isExpanded ? AppTheme.primaryNeon.withValues(alpha: 0.6) : AppTheme.border),
      ),
      child: Column(
        children: [
          // رأس الكارت الرئيسي
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSessionIds.remove(session.id);
                } else {
                  _expandedSessionIds.add(session.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.fitness_center, color: AppTheme.primaryNeon, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(session.startedAt, workout.isArabic),
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        // إحصائيات الجلسة
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _badge(
                              icon: Icons.timer_outlined,
                              label: '$duration ${workout.isArabic ? 'دقيقة' : 'min'}',
                            ),
                            _badge(
                              icon: Icons.bolt,
                              label: '${session.totalVolume.toStringAsFixed(0)} ${workout.t('kg_unit')}',
                              isNeon: true,
                            ),
                            _badge(
                              icon: Icons.format_list_numbered,
                              label: '${session.totalSets} ${workout.t('sets_unit')}',
                            ),
                            if (prsCount > 0)
                              _badge(
                                icon: Icons.emoji_events,
                                label: '$prsCount PRs 🏆',
                                isGold: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // أزرار سريعة ومثلث الفتح
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18, color: AppTheme.textSecondary),
                        tooltip: workout.t('share_card_btn'),
                        onPressed: () {
                          final text = workout.generateWorkoutShareText(session);
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(workout.t('share_copied'))),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        tooltip: workout.t('delete_session_btn'),
                        onPressed: () => _confirmDeleteSession(context, workout, session.id),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppTheme.textMuted,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // التفاصيل الموسعة
          if (isExpanded) ...[
            const Divider(color: AppTheme.border, height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: AppTheme.background.withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...exerciseSetsMap.entries.map((entry) {
                    final exId = entry.key;
                    final sets = entry.value;
                    final ex = workout.exercises.firstWhere(
                      (e) => e.id == exId,
                      orElse: () => ExerciseItem(id: '', muscleGroupId: 'chest', nameAr: 'تمرين', nameEn: 'Exercise', equipment: 'Barbell'),
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigher,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                workout.isArabic ? ex.nameAr : ex.nameEn,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${sets.length} ${workout.t('sets_unit')}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: sets.map((st) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: st.isPr ? AppTheme.goldPR : AppTheme.border,
                                    width: st.isPr ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${st.setType != 'normal' ? '[${st.setType[0].toUpperCase()}] ' : ''}#${st.setNumber}: ',
                                      style: TextStyle(
                                        color: st.setType == 'warmup' ? Colors.orangeAccent : AppTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${st.weightKg} ${workout.t('kg_unit')} × ${st.reps}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    if (st.isPr) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.star, color: AppTheme.goldPR, size: 12),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, WorkoutProvider workout, String sessionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(workout.t('delete_session_btn'), style: const TextStyle(color: Colors.white)),
        content: Text(workout.t('delete_session_confirm'), style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(workout.t('cancel_btn'), style: const TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              workout.deleteSession(sessionId);
              Navigator.pop(context);
            },
            child: Text(workout.t('confirm')),
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    bool isNeon = false,
    bool isGold = false,
  }) {
    Color color = Colors.white;
    Color bg = AppTheme.surfaceHighlight;
    if (isNeon) {
      color = AppTheme.primaryNeon;
      bg = AppTheme.primaryNeon.withValues(alpha: 0.12);
    } else if (isGold) {
      color = AppTheme.goldPR;
      bg = AppTheme.goldPR.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    bool isNeon = false,
    bool isGold = false,
  }) {
    Color col = isNeon ? AppTheme.primaryNeon : (isGold ? AppTheme.goldPR : Colors.white);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: col),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: col, fontSize: 16, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 35, color: AppTheme.border);
  }
}
