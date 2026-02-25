import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/controllers/trading_controller.dart';

void main() {
  group('TradingController Behavioral Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state fulfills the default low probability setup', () {
      final state = container.read(tradingProvider);
      // Liquidity Trap is checked (3) by default
      expect(state.totalScore, 3);
      expect(state.action, "block");
    });

    test('increments total score when a weighted parameter is enabled', () {
      final notifier = container.read(tradingProvider.notifier);

      notifier.toggleParameter('Trend Alignment');

      final state = container.read(tradingProvider);
      // 3 (Default Trap Check) + 3 (Trend) = 6
      expect(state.totalScore, 6);
    });

    test(
      'transitions to higher probability grades as thresholds are crossed',
      () {
        final notifier = container.read(tradingProvider.notifier);

        // Reach Medium Probability (>= 55%)
        // Starting with 3 (Trap Check)
        notifier.toggleParameter('Trend Alignment'); // +3 = 6
        notifier.toggleParameter('Risk-Reward Ratio'); // +3 = 9
        notifier.toggleParameter('Support/Resistance'); // +2 = 11
        // Total = 11. 11/17 = 64.7%

        var state = container.read(tradingProvider);
        expect(state.percentage, greaterThanOrEqualTo(55.0));
        expect(state.action, "allow");
        expect(state.positionSize, "half");

        // Reach High Probability (>= 85%)
        notifier.toggleParameter('Volume Confirmation'); // +2 = 13
        notifier.toggleParameter('Position Sizing'); // +2 = 15
        // Total = 15. 15/17 = 88.2%

        state = container.read(tradingProvider);
        expect(state.percentage, greaterThanOrEqualTo(85.0));
        expect(state.action, "allow");
        expect(state.positionSize, "full");
      },
    );

    test('clears all user selections when reset is triggered', () {
      final notifier = container.read(tradingProvider.notifier);
      notifier.toggleParameter('Trend Alignment');

      expect(container.read(tradingProvider).totalScore, isPositive);

      notifier.reset();
      expect(container.read(tradingProvider).totalScore, 3);
      expect(container.read(tradingProvider).action, "block");
    });
  });
}
