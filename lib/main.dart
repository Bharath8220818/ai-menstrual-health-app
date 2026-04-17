import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:femi_friendly/firebase_options.dart';
import 'package:femi_friendly/core/theme/app_scroll_behavior.dart';
import 'package:femi_friendly/core/theme/app_theme.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/providers/chat_provider.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/hormonal_condition_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/routes/routes.dart';
import 'package:femi_friendly/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    debugPrint('Firebase initialized ✅');
  } catch (error) {
    debugPrint('Firebase init skipped: $error');
  }

  try {
    await NotificationService()
        .initNotifications()
        .timeout(const Duration(seconds: 5));
  } catch (error) {
    debugPrint('NotificationService init skipped: $error');
  }

  runApp(const FemiFriendlyApp());
}

class FemiFriendlyApp extends StatelessWidget {
  const FemiFriendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<CycleProvider>(create: (_) => CycleProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<HormonalConditionProvider>(
          create: (_) => HormonalConditionProvider(),
        ),
        ChangeNotifierProvider<PregnancyProvider>(
          create: (_) => PregnancyProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Femi-Friendly',
        theme: AppTheme.lightTheme,
        scrollBehavior: const AppScrollBehavior(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
