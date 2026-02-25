import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/ui/screens/trading_dashboard.dart';

/// Helper: renders TradingDashboard directly (avoids WebView in test env).
Future<void> _pumpDashboard(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          useMaterial3: true,
        ),
        home: const TradingDashboard(),
      ),
    ),
  );
}

void main() {
  group('TradingDashboard Widget Behavioral Tests', () {
    testWidgets('renders initial state with baseline trap check score', (
      WidgetTester tester,
    ) async {
      await _pumpDashboard(tester);

      expect(find.text('Trade Decision Framework'), findsOneWidget);
      expect(
        find.text('3 / ${EngineConfig.totalPossibleScore}'),
        findsOneWidget,
      );
      expect(find.textContaining('Block'), findsOneWidget);
    });

    testWidgets(
      'updates score display reactively when parameters are toggled',
      (WidgetTester tester) async {
        await _pumpDashboard(tester);

        final finder = find.text('Trend Alignment');
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();

        expect(
          find.text('6 / ${EngineConfig.totalPossibleScore}'),
          findsOneWidget,
        );
      },
    );

    testWidgets('updates decision UI when grade thresholds are crossed', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await _pumpDashboard(tester);

      // Starting with score 3 (Trap Check, default)
      // totalPossibleScore = 21. Grade B >= 55% => need 12+ pts.
      // Add: TopDown(+4=7), Trend(+3=10), RR(+3=13) => 13/21 = 61.9% = Grade B
      final items = [
        'Top-Down Alignment',
        'Trend Alignment',
        'Risk-Reward Ratio',
      ];
      for (final item in items) {
        final finder = find.text(item);
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      expect(
        find.text('13 / ${EngineConfig.totalPossibleScore}'),
        findsOneWidget,
      );
      expect(find.textContaining('Allow (Half Size)'), findsOneWidget);
    });

    testWidgets('reset button restores baseline trap check score', (
      WidgetTester tester,
    ) async {
      await _pumpDashboard(tester);

      final finder = find.text('Trend Alignment');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(
        find.text('6 / ${EngineConfig.totalPossibleScore}'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(
        find.text('3 / ${EngineConfig.totalPossibleScore}'),
        findsOneWidget,
      );
    });
  });
}
