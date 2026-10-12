import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/main_layout.dart';
import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: const IronLogApp(),
    ),
  );
}

class IronLogApp extends StatelessWidget {
  const IronLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();

    return MaterialApp(
      title: workout.isArabic
          ? 'IRONLOG - تتبع أوزان الجيم والزيادة التدريجية'
          : 'IRONLOG - Progressive Overload Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: workout.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: workout.isLoggedIn ? const MainLayout() : const AuthScreen(),
    );
  }
}
