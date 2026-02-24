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
    testWidgets(
        'renders initial state with zero score and low probability grade',
        (WidgetTester tester) async {
      await _pumpDashboard(tester);

      expect(find.text('Trade Decision Framework'), findsOneWidget);
      expect(find.text('0 / ${EngineConfig.totalPossibleScore}'),
          findsOneWidget);
      expect(find.textContaining('Low Probability'), findsOneWidget);
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
          find.text(
              '${EngineConfig.trendAlignmentWeight} / ${EngineConfig.totalPossibleScore}'),
          findsOneWidget);
    });

    testWidgets(
        'updates decision UI when grade thresholds are crossed',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await _pumpDashboard(tester);

      // Toggle items to reach Grade B (score >= 8)
      final items = [
        'Trend Alignment',
        'Risk-Reward Ratio',
        'Support/Resistance'
      ];
      for (final item in items) {
        final finder = find.text(item);
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      expect(find.text('8 / ${EngineConfig.totalPossibleScore}'),
          findsOneWidget);
      expect(find.textContaining('Medium Probability'), findsOneWidget);
    });

    testWidgets('reset button clears all active selections in the UI',
        (WidgetTester tester) async {
      await _pumpDashboard(tester);

      final finder = find.text('Trend Alignment');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(
          find.text(
              '${EngineConfig.trendAlignmentWeight} / ${EngineConfig.totalPossibleScore}'),
          findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(find.text('0 / ${EngineConfig.totalPossibleScore}'),
          findsOneWidget);
    });
  });
}
