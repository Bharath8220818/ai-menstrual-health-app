import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:femi_friendly/core/theme/app_scroll_behavior.dart';
import 'package:femi_friendly/core/theme/app_theme.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/providers/chat_provider.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/insights_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/providers/ai_provider.dart';
import 'package:femi_friendly/routes/routes.dart';
import 'package:femi_friendly/services/api_client.dart';
import 'package:femi_friendly/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint('Firebase init skipped: $error');
  }
  
  // Initialize notifications
  await NotificationService().initNotifications();
  
  runApp(const FemiFriendlyApp());
}

class FemiFriendlyApp extends StatelessWidget {
  const FemiFriendlyApp({super.key});

  static final ApiClient _apiClient = ApiClient();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final auth = AuthProvider();
            auth.loadFromPrefs();
            return auth;
          },
        ),
        ChangeNotifierProvider<CycleProvider>(create: (_) => CycleProvider()),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(apiClient: _apiClient),
        ),
        ChangeNotifierProvider<InsightsProvider>(
          create: (_) => InsightsProvider(apiClient: _apiClient),
        ),
        ChangeNotifierProvider<PregnancyProvider>(
          create: (_) => PregnancyProvider(),
        ),
        ChangeNotifierProvider<AIProvider>(create: (_) => AIProvider()),
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
