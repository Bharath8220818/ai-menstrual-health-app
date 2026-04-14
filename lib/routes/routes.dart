import 'package:flutter/material.dart';

import 'package:femi_friendly/core/navigation/app_page_route.dart';
import 'package:femi_friendly/screens/auth/login_screen.dart';
import 'package:femi_friendly/screens/auth/onboarding_screen.dart';
import 'package:femi_friendly/screens/auth/register_screen.dart';
import 'package:femi_friendly/screens/home/home_shell_screen.dart';
import 'package:femi_friendly/screens/notification/notification_screen.dart';
import 'package:femi_friendly/screens/phase/phase_detail_screen.dart';
import 'package:femi_friendly/screens/setup/profile_setup_screen.dart';
import 'package:femi_friendly/screens/splash/splash_screen.dart';
import 'package:femi_friendly/screens/water/water_tracker_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';

  // Tab index shortcuts
  // Index: 0=Home 1=Cycle 2=Pregnancy 3=AI 4=Profile
  static const String dashboard = '/dashboard';
  static const String cycleTracker = '/cycle-tracker';
  static const String pregnancy = '/pregnancy';
  static const String aiInsights = '/ai-insights';
  static const String chatbot = '/chatbot';
  static const String profile = '/profile';

  // Feature screens
  static const String notifications = '/notifications';
  static const String waterTracker = '/water-tracker';
  static const String phaseDetail = '/phase-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    late final Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashScreen();
      case onboarding:
        page = const OnboardingScreen();
      case login:
        page = const LoginScreen();
      case register:
        page = const RegisterScreen();
      case profileSetup:
        page = const ProfileSetupScreen();
      case home:
        page = HomeShellScreen(
          initialIndex: _extractTabIndex(settings.arguments),
        );
      case dashboard:
        page = const HomeShellScreen(initialIndex: 0);
      case cycleTracker:
        page = const HomeShellScreen(initialIndex: 1);
      case pregnancy:
        page = const HomeShellScreen(initialIndex: 2);
      case aiInsights:
        page = const HomeShellScreen(initialIndex: 3);
      case chatbot:
        page = const HomeShellScreen(initialIndex: 3);
      case profile:
        page = const HomeShellScreen(initialIndex: 4);
      case notifications:
        page = const NotificationScreen();
      case waterTracker:
        page = const WaterTrackerScreen();
      case phaseDetail:
        final phase = settings.arguments is CyclePhase
            ? settings.arguments! as CyclePhase
            : CyclePhase.menstrual;
        page = PhaseDetailScreen(phase: phase);
      default:
        page = const SplashScreen();
    }

    return AppPageRoute.build(page: page, settings: settings);
  }

  static int _extractTabIndex(Object? arguments) {
    if (arguments is int) return arguments.clamp(0, 4);
    if (arguments is Map<String, Object?> && arguments['tab'] is int) {
      return (arguments['tab']! as int).clamp(0, 4);
    }
    return 0;
  }
}
