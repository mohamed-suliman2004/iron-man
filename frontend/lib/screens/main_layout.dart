import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'today_screen.dart';
import 'routines_screen.dart';
import 'exercises_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'live_workout_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TodayScreen(),
    RoutinesScreen(),
    ExercisesScreen(),
    HistoryScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Row(
          children: [
            if (isWide) _buildSidebar(workout),
            Expanded(
              child: Column(
                children: [
                  _buildTopHeader(isWide, workout),
                  if (workout.activeSession != null)
                    _buildActiveWorkoutTopBanner(context, workout),
                  Expanded(child: _pages[_currentIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNav(workout),
    );
  }

  Widget _buildTopHeader(bool isWide, WorkoutProvider workout) {
    return Container(
      height: isWide ? 60 : 54,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        children: [
          if (isWide) ...[
            Text(
              _getBreadcrumbText(workout),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ] else ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(Icons.fitness_center, size: 15, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getPageTitle(workout),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          // زر تبديل اللغة الأنيق
          InkWell(
            onTap: () => workout.toggleLanguage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 14, color: AppTheme.primaryNeon),
                  const SizedBox(width: 4),
                  Text(
                    workout.isArabic ? 'English' : 'العربية',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
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
                  Text(
                    workout.t('current_date'),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 20, color: AppTheme.textSecondary),
              onPressed: () {},
            ),
          ],
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 5),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryNeon,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  workout.athleteAvatarLetter,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(WorkoutProvider workout) {
    switch (_currentIndex) {
      case 0:
        return workout.isArabic ? 'اليوم' : 'Today';
      case 1:
        return workout.isArabic ? 'الجداول' : 'Routines';
      case 2:
        return workout.isArabic ? 'التمارين' : 'Exercises';
      case 3:
        return workout.isArabic ? 'السجل' : 'History';
      case 4:
        return workout.isArabic ? 'التقدم' : 'Progress';
      case 5:
        return workout.isArabic ? 'الملف الشخصي' : 'Profile';
      default:
        return 'IRONLOG';
    }
  }

  String _getBreadcrumbText(WorkoutProvider workout) {
    switch (_currentIndex) {
      case 0:
        return workout.t('breadcrumb_today');
      case 1:
        return workout.t('breadcrumb_routines');
      case 2:
        return workout.t('breadcrumb_exercises');
      case 3:
        return workout.t('breadcrumb_history');
      case 4:
        return workout.t('breadcrumb_progress');
      case 5:
        return workout.t('breadcrumb_profile');
      default:
        return 'IRONLOG';
    }
  }

  Widget _buildSidebar(WorkoutProvider workout) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF0D121C),
        border: Border(
          right: workout.isArabic ? BorderSide.none : const BorderSide(color: AppTheme.border, width: 1),
          left: workout.isArabic ? const BorderSide(color: AppTheme.border, width: 1) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الشعار
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fitness_center, color: AppTheme.primaryNeon, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'IRONLOG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Text(workout.t('workspace'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _sidebarItem(0, Icons.dashboard_outlined, workout.t('nav_today')),
          _sidebarItem(1, Icons.tune_outlined, workout.t('nav_routines')),
          _sidebarItem(2, Icons.fitness_center_outlined, workout.t('nav_exercises')),
          _sidebarItem(3, Icons.history_outlined, workout.t('nav_history')),
          _sidebarItem(4, Icons.show_chart_outlined, workout.t('nav_progress')),
          const SizedBox(height: 25),
          Text(workout.t('your_space'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _sidebarItem(5, Icons.person_outline, workout.t('nav_profile')),
          const Spacer(),
          // صندوق التحفيز أسفل القائمة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: AppTheme.primaryNeon, size: 16),
                    SizedBox(width: 6),
                    Text('Keep showing up.', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(workout.t('consistency_quote'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // بروفايل اللاعب
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.surfaceHighlight,
                child: Text(workout.isArabic ? 'س' : 'S', style: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.athleteName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(workout.t('free_athlete'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceHighlight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.primaryNeon : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNeon,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(WorkoutProvider workout) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D121C),
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryNeon,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), label: workout.isArabic ? 'اليوم' : 'Today'),
            BottomNavigationBarItem(icon: const Icon(Icons.tune_outlined), label: workout.isArabic ? 'الجداول' : 'Routines'),
            BottomNavigationBarItem(icon: const Icon(Icons.fitness_center_outlined), label: workout.isArabic ? 'التمارين' : 'Exercises'),
            BottomNavigationBarItem(icon: const Icon(Icons.history_outlined), label: workout.isArabic ? 'السجل' : 'History'),
            BottomNavigationBarItem(icon: const Icon(Icons.show_chart_outlined), label: workout.isArabic ? 'التقدم' : 'Progress'),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: workout.isArabic ? 'حسابي' : 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutTopBanner(BuildContext context, WorkoutProvider workout) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryNeon.withValues(alpha: 0.35), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryNeon,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.7),
                  blurRadius: 6,
                  spreadRadius: 1.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  workout.isArabic ? 'جلسة نشطة: ' : 'Active: ',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Text(
                    workout.activeSession?.name ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigher,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    '${workout.activeSession?.sets.length ?? 0} ${workout.isArabic ? 'جولات' : 'sets'}',
                    style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveWorkoutScreen()),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryNeon,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workout.isArabic ? 'متابعة' : 'Resume',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Icon(workout.isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 12, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
