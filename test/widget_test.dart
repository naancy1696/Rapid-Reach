import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_reach/main.dart';

void main() {
  testWidgets('RAPID REACH app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const RapidReachApp());

    // Splash screen.
    expect(
      find.text('AI POWERED. HUMAN FOCUSED.'),
      findsOneWidget,
    );

    expect(
      find.text('Your intelligent emergency\nresponse companion.'),
      findsOneWidget,
    );

    // Wait for the 2-second splash transition.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Welcome screen.
    expect(find.text('Welcome to'), findsOneWidget);
    expect(
      find.text('Your intelligent emergency\nresponse companion.'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
  });
}