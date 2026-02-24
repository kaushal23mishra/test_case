import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/controllers/trading_controller.dart';
import 'package:test_case/core/config/engine_config.dart';

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
      expect(state.totalScore, 0);
      expect(state.decision, contains("Low Probability"));
    });

    test('increments total score when a weighted parameter is enabled', () {
      final notifier = container.read(tradingProvider.notifier);
      
      notifier.toggleParameter('Trend Alignment');
      
      final state = container.read(tradingProvider);
      expect(state.totalScore, EngineConfig.trendAlignmentWeight);
    });

    test('transitions to higher probability grades as thresholds are crossed', () {
      final notifier = container.read(tradingProvider.notifier);
      
      // Reach Medium Probability
      notifier.toggleParameter('Trend Alignment'); // 3
      notifier.toggleParameter('Risk-Reward Ratio'); // 3
      notifier.toggleParameter('Support/Resistance'); // 2
      
      var state = container.read(tradingProvider);
      expect(state.totalScore, EngineConfig.gradeBThreshold);
      expect(state.decision, contains("Medium Probability"));

      // Reach High Probability
      notifier.toggleParameter('Volume Confirmation'); // 2
      notifier.toggleParameter('Position Sizing'); // 2
      
      state = container.read(tradingProvider);
      expect(state.totalScore, EngineConfig.gradeAThreshold);
      expect(state.decision, contains("High Probability"));
    });

    test('clears all user selections when reset is triggered', () {
      final notifier = container.read(tradingProvider.notifier);
      notifier.toggleParameter('Trend Alignment');
      
      expect(container.read(tradingProvider).totalScore, isPositive);
      
      notifier.reset();
      expect(container.read(tradingProvider).totalScore, 0);
    });
  });
}
