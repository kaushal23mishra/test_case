import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_case/main.dart';

void main() {
  group('TradingDashboard Widget Tests', () {
    testWidgets('Dashboard renders correctly with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: TradingApp(),
        ),
      );

      expect(find.text('Trade Decision Framework'), findsOneWidget);
      expect(find.text('0 / 14'), findsOneWidget);
      expect(find.text('Low Probability (No Trade)'), findsOneWidget);
    });

    testWidgets('Score updates on UI when checkbox is clicked', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: TradingApp(),
        ),
      );

      // Verify initial score
      expect(find.text('0 / 14'), findsOneWidget);

      final finder = find.text('Trend Alignment');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.text('3 / 14'), findsOneWidget);
    });

    testWidgets('Decision text changes color/text when probability threshold is met', (WidgetTester tester) async {
      // Set a larger surface size to avoid scrolling issues in tests
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: TradingApp(),
        ),
      );

      // Initial state
      expect(find.text('Low Probability (No Trade)'), findsOneWidget);

      // Toggle items to reach Medium Probability (Score >= 8)
      final items = ['Trend Alignment', 'Risk-Reward Ratio', 'Support/Resistance'];
      for (final item in items) {
        final finder = find.text(item);
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      expect(find.text('8 / 14'), findsOneWidget);
      expect(find.text('Medium Probability (Half Size)'), findsOneWidget);
    });

    testWidgets('Reset button clears the UI selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: TradingApp(),
        ),
      );

      final finder = find.text('Trend Alignment');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      expect(find.text('3 / 14'), findsOneWidget);

      // Tap reset icon in AppBar
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(find.text('0 / 14'), findsOneWidget);
    });
  });
}
