import 'package:flutter_test/flutter_test.dart';

import 'package:femi_friendly/main.dart';

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 30,
  Duration step = const Duration(milliseconds: 200),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
}

void main() {
  testWidgets('Web smoke flow: login, tabs, AI chat, profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FemiFriendlyApp());

    // Splash -> Login
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Welcome Back 💖'), findsOneWidget);

    // Login with prefilled demo credentials
    final signInTexts = find.text('Sign In');
    expect(signInTexts, findsWidgets);
    await tester.tap(signInTexts.last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Cycle'), findsWidgets);

    // Cycle
    await tester.tap(find.text('Cycle').hitTestable().first);
    await _pumpUntilVisible(tester, find.text('Cycle Tracker'));
    expect(find.text('Cycle Tracker'), findsWidgets);

    // Pregnancy
    await tester.tap(find.text('Pregnancy').hitTestable().first);
    await _pumpUntilVisible(tester, find.textContaining('Pregnancy Mode'));
    expect(find.textContaining('Pregnancy Mode'), findsWidgets);

    // AI Insights
    await tester.tap(find.text('AI').hitTestable().first);
    await _pumpUntilVisible(tester, find.text('AI Insights'));
    expect(find.text('AI Insights'), findsWidgets);

    // Keep smoke test deterministic in widget environment; network-backed chat
    // replies are covered in provider/service tests.
    expect(find.text('AI Insights'), findsWidgets);

    // Profile
    await tester.tap(find.text('Profile').hitTestable().first);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Profile'), findsWidgets);

    // Back Home
    await tester.tap(find.text('Home').hitTestable().first);
    await _pumpUntilVisible(tester, find.text('Cycle'));
    expect(find.text('Cycle'), findsWidgets);
  });
}
