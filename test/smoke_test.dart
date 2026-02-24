import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/main.dart';
import 'package:test_case/ui/screens/trading_dashboard.dart';

void main() {
  group('Automated Project Smoke Test', () {
    testWidgets('Initialization Smoke Test: App builds and renders Shell without crashing', (WidgetTester tester) async {
      // We skip the WebView mock here because the widget handles it internally now
      await tester.pumpWidget(
        const ProviderScope(
          child: TradingApp(),
        ),
      );

      // Verify no exceptions were thrown during first frame
      expect(tester.takeException(), isNull);
      
      // Verify MainShell is rendered
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('Runtime Bridge Smoke Test: Switching tabs and loading dashboard does not throw errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: TradingApp(),
        ),
      );

      // Verify initial screen (Chart)
      expect(find.byIcon(Icons.candlestick_chart), findsOneWidget);

      // Switch to Checklist tab (TradingDashboard)
      final checklistTab = find.byIcon(Icons.checklist);
      expect(checklistTab, findsOneWidget);

      await tester.tap(checklistTab);
      await tester.pumpAndSettle();

      // Verify TradingDashboard is now visible and rendered correctly
      expect(find.byType(TradingDashboard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
