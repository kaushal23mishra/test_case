import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/main.dart';

void main() {
  testWidgets('Trading Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TradingApp());

    // Verify that the title is present.
    expect(find.text('Trade Decision Framework'), findsOneWidget);

    // Verify that score card exists
    expect(find.text('CURRENT TRADE SCORE'), findsOneWidget);
  });
}
