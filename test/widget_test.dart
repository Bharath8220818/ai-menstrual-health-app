import 'package:flutter_test/flutter_test.dart';

import 'package:femi_friendly/main.dart';

void main() {
  testWidgets('App navigates from splash to login', (WidgetTester tester) async {
    await tester.pumpWidget(const FemiFriendlyApp());
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back 💖'), findsOneWidget);
  });
}
