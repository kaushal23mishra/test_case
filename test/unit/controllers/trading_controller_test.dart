import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_case/controllers/trading_controller.dart';

void main() {
  group('TradingController Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should have 0 score and default decision', () {
      final state = container.read(tradingProvider);
      expect(state.totalScore, 0);
      expect(state.decision, "Low Probability (No Trade)");
    });

    test('Score should update when a parameter is toggled', () {
      final notifier = container.read(tradingProvider.notifier);
      
      // Toggle 'Trend Alignment' (Weight: 3)
      notifier.toggleParameter('Trend Alignment');
      
      final state = container.read(tradingProvider);
      expect(state.totalScore, 3);
    });

    test('Probability decision should change based on score', () {
      final notifier = container.read(tradingProvider.notifier);
      
      // Add multiple parameters to reach > 8 score
      notifier.toggleParameter('Trend Alignment'); // 3
      notifier.toggleParameter('Risk-Reward Ratio'); // 3
      notifier.toggleParameter('Support/Resistance'); // 2
      
      var state = container.read(tradingProvider);
      expect(state.totalScore, 8);
      expect(state.decision, "Medium Probability (Half Size)");

      // Add more to reach > 12
      notifier.toggleParameter('Volume Confirmation'); // 2
      notifier.toggleParameter('Position Sizing'); // 2
      
      state = container.read(tradingProvider);
      expect(state.totalScore, 12);
      expect(state.decision, "High Probability (Trade Allowed)");
    });

    test('Reset should clear all parameters', () {
      final notifier = container.read(tradingProvider.notifier);
      notifier.toggleParameter('Trend Alignment');
      
      expect(container.read(tradingProvider).totalScore, 3);
      
      notifier.reset();
      expect(container.read(tradingProvider).totalScore, 0);
    });
  });
}
