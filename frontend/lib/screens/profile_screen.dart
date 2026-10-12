import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final emailController = TextEditingController(text: 'sam@ironlog.app');
  final passwordController = TextEditingController(text: '••••••••');
  bool isSignInTab = true;

  void _showEditNameDialog(BuildContext context, WorkoutProvider workout) {
    final nameController = TextEditingController(text: workout.athleteDisplayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
        title: Text(
          workout.t('edit_name_dialog_title'),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceHigher,
            labelText: workout.t('name_label'),
            labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNeon)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                workout.updateAthleteName(newName);
              }
              Navigator.pop(ctx);
            },
            child: Text(workout.t('save_name_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final isWide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workout.t('athlete_settings'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(workout.t('your_space_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(workout.t('athlete_desc'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 20),

          // كارت اللاعب وملخص الإنجازات (Athlete Card)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      workout.athleteAvatarLetter,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(workout.t('athlete_profile'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              workout.athleteDisplayName,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showEditNameDialog(context, workout),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceHighlight,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Icon(Icons.edit, size: 12, color: AppTheme.primaryNeon),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        workout.athletePhone.isNotEmpty
                            ? '${workout.athletePhone}${workout.athleteEmail.isNotEmpty ? " · ${workout.athleteEmail}" : ""}'
                            : (workout.athleteEmail.isNotEmpty ? workout.athleteEmail : workout.t('training_since')),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isWide) ...[
                  const Spacer(),
                  _statItem('${workout.streak}', workout.t('streak_stat')),
                  const SizedBox(width: 24),
                  _statItem('${workout.sessions.length}', workout.t('completed_stat')),
                  const SizedBox(width: 24),
                  _statItem('${workout.totalPersonalRecords}', workout.t('prs_stat')),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // شبكة الإعدادات والدخول
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAccountAccessCard(context, workout)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildPreferencesCard(workout),
                      const SizedBox(height: 20),
                      _buildAppSecurityCard(context, workout),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildPreferencesCard(workout),
            const SizedBox(height: 20),
            _buildAccountAccessCard(context, workout),
            const SizedBox(height: 20),
            _buildAppSecurityCard(context, workout),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPreferencesCard(WorkoutProvider workout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workout.t('preferences_title'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(workout.t('training_settings'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // اختيار لغة التطبيق (اللغة الافتراضية العربية والإنجليزية)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: AppTheme.primaryNeon, size: 16),
                      const SizedBox(width: 6),
                      Text(workout.t('app_language'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(workout.t('app_language_desc'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => workout.setLocale('ar'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: workout.isArabic ? AppTheme.primaryNeon.withValues(alpha: 0.15) : AppTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: workout.isArabic ? AppTheme.primaryNeon : AppTheme.border,
                        width: workout.isArabic ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (workout.isArabic)
                            const Icon(Icons.check_circle, size: 14, color: AppTheme.primaryNeon),
                          if (workout.isArabic) const SizedBox(width: 6),
                          Text(
                            workout.t('arabic_opt'),
                            style: TextStyle(
                              color: workout.isArabic ? AppTheme.primaryNeon : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => workout.setLocale('en'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !workout.isArabic ? AppTheme.primaryNeon.withValues(alpha: 0.15) : AppTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !workout.isArabic ? AppTheme.primaryNeon : AppTheme.border,
                        width: !workout.isArabic ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!workout.isArabic)
                            const Icon(Icons.check_circle, size: 14, color: AppTheme.primaryNeon),
                          if (!workout.isArabic) const SizedBox(width: 6),
                          Text(
                            workout.t('english_opt'),
                            style: TextStyle(
                              color: !workout.isArabic ? AppTheme.primaryNeon : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 14),

          // وحدة قياس الوزن
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.t('weight_units'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(workout.t('weight_units_desc'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigher,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(workout.t('unit_kg'), style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 12),

          // المدة الافتراضية لمؤقت الراحة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(workout.t('rest_timer_title'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${workout.restTimerDuration}s ${workout.t('rest')}', style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [45, 60, 90, 120, 180].map((sec) {
                    final isSel = workout.restTimerDuration == sec;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: InkWell(
                        onTap: () => workout.setRestTimerDuration(sec),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryNeon.withValues(alpha: 0.2) : AppTheme.surfaceHigher,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSel ? AppTheme.primaryNeon : AppTheme.border),
                          ),
                          child: Text(
                            '${sec}s',
                            style: TextStyle(
                              color: isSel ? AppTheme.primaryNeon : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 12),

          // تتبع وزن الجسم
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.t('body_weight_title'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(
                    workout.bodyWeights.isNotEmpty
                        ? '${workout.bodyWeights.first.weightKg} ${workout.t('kg_unit')}'
                        : (workout.isArabic ? 'لم يسجل بعد' : 'Not logged yet'),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceHigher,
                  foregroundColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.monitor_weight_outlined, size: 14),
                label: Text(workout.t('log_weight_btn'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                onPressed: () => _showBodyweightDialog(context, workout),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBodyweightDialog(BuildContext context, WorkoutProvider workout) {
    final ctrl = TextEditingController(text: workout.bodyWeights.isNotEmpty ? workout.bodyWeights.first.weightKg.toString() : '75.0');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(workout.t('body_weight_title'), style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: workout.t('body_weight_hint'),
                labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                suffixText: workout.t('kg_unit'),
                suffixStyle: const TextStyle(color: AppTheme.primaryNeon),
                filled: true,
                fillColor: AppTheme.surfaceHigher,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(workout.t('cancel_btn'), style: const TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNeon, foregroundColor: Colors.black),
            onPressed: () {
              final w = double.tryParse(ctrl.text);
              if (w != null && w > 0) {
                workout.logBodyWeight(w);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(workout.t('weight_logged'))),
                );
              }
            },
            child: Text(workout.t('confirm')),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountAccessCard(BuildContext context, WorkoutProvider workout) {
    if (workout.isLoggedIn) {
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
                Text(workout.t('account_access'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(workout.isArabic ? 'متصل بالسيرفر' : 'Connected to Server', style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(workout.athleteName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(
              workout.athletePhone.isNotEmpty
                  ? '${workout.athletePhone}${workout.athleteEmail.isNotEmpty ? " · ${workout.athleteEmail}" : ""}'
                  : workout.athleteEmail,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  workout.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(workout.isArabic ? 'تم تسجيل الخروج بنجاح' : 'Logged out successfully')),
                  );
                },
                icon: const Icon(Icons.logout, size: 16),
                label: Text(
                  workout.isArabic ? 'تسجيل الخروج من الحساب' : 'Sign Out of Account',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
              Text(workout.t('account_access'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.goldPR.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(workout.t('offline_ready'), style: const TextStyle(color: AppTheme.goldPR, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(workout.t('welcome_back'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(workout.t('login_sync_desc'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeon,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                workout.logout();
              },
              child: Text(workout.t('sign_in'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSecurityCard(BuildContext context, WorkoutProvider workout) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Text(workout.t('app_security'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.shield_outlined, color: AppTheme.primaryNeon.withValues(alpha: 0.8), size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(workout.t('app_security_title'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigher,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryNeon, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(workout.t('demo_unlocked'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        workout.t('local_db_status'),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceHighlight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Text(workout.t('lock_app'), style: const TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // زر تصدير البيانات والنسخ الاحتياطي
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.file_download_outlined, color: AppTheme.primaryNeon, size: 18),
              label: Text(
                workout.t('export_btn'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () {
                final csvData = workout.exportDataToCsv();
                Clipboard.setData(ClipboardData(text: csvData));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.surfaceHigher,
                    content: Text(
                      workout.t('export_success'),
                      style: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
