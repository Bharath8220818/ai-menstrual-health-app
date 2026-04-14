import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppPageRoute {
  const AppPageRoute._();

  static Route<T> build<T>({
    required Widget page,
    required RouteSettings settings,
  }) {
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CupertinoPageRoute<T>(
        builder: (_) => page,
        settings: settings,
      );
    }
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, animation, __) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: page,
        );
      },
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return SlideTransition(position: slide, child: child);
      },
    );
  }
}
