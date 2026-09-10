import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_reach/main.dart';

void main() {
  testWidgets('RAPID REACH app loads successfully', (
    WidgetTester tester,
  ) async {
    // Start the RAPID REACH application.
    await tester.pumpWidget(const RapidReachApp());

    // Verify that the Flutter application is mounted successfully.
    expect(
      find.byType(RapidReachApp),
      findsOneWidget,
    );

    // Verify that the Material application is running.
    expect(
      find.byType(MaterialApp),
      findsOneWidget,
    );

    // Allow the asynchronous startup process to run.
    await tester.pump(const Duration(seconds: 1));

    // The application should still be running successfully.
    expect(
      find.byType(MaterialApp),
      findsOneWidget,
    );
  });
}