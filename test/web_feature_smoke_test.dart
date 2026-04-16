import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:femi_friendly/main.dart';

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
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Quick Actions'), findsOneWidget);

    // Cycle
    await tester.tap(find.text('Cycle'));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Cycle Tracker'), findsOneWidget);

    // Pregnancy
    await tester.tap(find.text('Pregnancy'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('Pregnancy Mode'), findsWidgets);

    // AI Insights
    await tester.tap(find.text('AI'));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('AI Insights'), findsWidgets);

    // AI Chat and send message
    await tester.tap(find.text('AI Chat'));
    await tester.pump(const Duration(milliseconds: 700));
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);
    await tester.enterText(textFields.first, 'Can I get pregnant today?');
    await tester.tap(find.byIcon(Icons.send_rounded).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Can I get pregnant today?'), findsOneWidget);

    final hasModelReply = find.textContaining(
      'I can help with cycle health',
    ).evaluate().isNotEmpty;
    final hasFallbackReply = find.textContaining(
      'best time to conceive',
    ).evaluate().isNotEmpty;
    expect(hasModelReply || hasFallbackReply, isTrue);

    // Profile
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('App Settings'), findsOneWidget);

    // Back Home
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
