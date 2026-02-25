import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/main.dart';
import 'package:test_case/ui/screens/trading_dashboard.dart';

void main() {
  group('Automated Project Smoke Test', () {
    testWidgets(
      'Initialization Smoke Test: App builds and renders TradingDashboard without crashing',
      (WidgetTester tester) async {
        await tester.pumpWidget(const ProviderScope(child: TradingApp()));

        // Verify no exceptions were thrown during first frame
        expect(tester.takeException(), isNull);

        // Verify TradingDashboard is rendered as home screen
        expect(find.byType(TradingDashboard), findsOneWidget);
      },
    );
  });
}
