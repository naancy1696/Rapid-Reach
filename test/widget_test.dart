import 'package:flutter_test/flutter_test.dart';

import 'package:rapid_reach/main.dart';

void main() {
  testWidgets('RAPID REACH app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const RapidReachApp());

    expect(find.text('RAPID REACH'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Welcome to RAPID REACH'), findsOneWidget);
  });
}