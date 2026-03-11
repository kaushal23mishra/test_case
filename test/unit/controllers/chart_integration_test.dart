import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/controllers/trading_controller.dart';

void main() {
  group('Chart to Trading Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'TradingController must implement applyAutoDetection for Chart integration',
      () {
        final tradingController = container.read(tradingProvider.notifier);
        final decisions = {'Trend Alignment': true};

        // Verify the method exists and handles inputs without throwing
        expect(
          () => tradingController.applyAutoDetection(decisions),
          returnsNormally,
        );

        final tradingState = container.read(tradingProvider);
        final trendParam = tradingState.technicals.firstWhere(
          (p) => p.title == 'Trend Alignment',
        );

        expect(
          trendParam.isChecked,
          true,
          reason: 'Parameter should be checked after auto-detection',
        );
        expect(
          trendParam.isAutoDetected,
          true,
          reason: 'isAutoDetected flag should be set to true',
        );
      },
    );

    test(
      'applyAutoDetection re-calculates the score and decision correctly',
      () {
        final tradingController = container.read(tradingProvider.notifier);

        // Select multiple items via auto-detection to trigger a decision change
        // totalPossibleScore is now 21, so we need >= 55% = 11.55 → 12 pts for Grade B
        // Default trap = 3. Adding: TopDown(4) + Trend(3) + RR(3) + SR(2) = 15 total
        final decisions = {
          'Top-Down Alignment': true,
          'Trend Alignment': true,
          'Risk-Reward Ratio': true,
          'Support/Resistance': true,
        };

        tradingController.applyAutoDetection(decisions);

        final state = container.read(tradingProvider);
        // 3 (Default Trap) + 4 (TopDown) + 3 (Trend) + 3 (RR) + 2 (SR) = 15
        expect(state.totalScore, 15);
        expect(state.action, 'allow'); // 15/21 = 71.4% → Grade B
        expect(state.positionSize, 'half');
      },
    );
  });
}
