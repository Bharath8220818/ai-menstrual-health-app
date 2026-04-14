import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = getPlatform(context);
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }

    return const ClampingScrollPhysics();
  }
}
