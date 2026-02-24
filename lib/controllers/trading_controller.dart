import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trading_parameter.dart';
import '../services/trading_logic/trading_service.dart';
import '../core/utils/logger_utils.dart';

final tradingServiceProvider = Provider((ref) => TradingService());

final tradingProvider = NotifierProvider<TradingController, TradingState>(() {
  return TradingController();
});

class TradingController extends Notifier<TradingState> {
  late TradingService _service;

  @override
  TradingState build() {
    _service = ref.read(tradingServiceProvider);
    
    return const TradingState(
      technicals: [
        TradingParameter(
            title: 'Trend Alignment',
            description: 'Price is above 200 EMA and making Higher Highs.',
            weight: 3),
        TradingParameter(
            title: 'Support/Resistance',
            description: 'Trade is taken near a major key level or Fibonacci zone.',
            weight: 2),
        TradingParameter(
            title: 'Volume Confirmation',
            description: 'Breakout or bounce is supported by above-average volume.',
            weight: 2),
      ],
      riskManagement: [
        TradingParameter(
            title: 'Risk-Reward Ratio',
            description: 'The setup offers at least a 1:2 Risk-Reward ratio.',
            weight: 3),
        TradingParameter(
            title: 'Position Sizing',
            description: 'Calculated lot size aligns with 1% risk per trade.',
            weight: 2),
      ],
      marketConditions: [
        TradingParameter(
            title: 'Volatility (ATR)',
            description: 'Market volatility is within normal ranges for your SL.',
            weight: 1),
        TradingParameter(
            title: 'No Impact News',
            description: 'No major economic data release in the next 1 hour.',
            weight: 1),
      ],
    );
  }

  void toggleParameter(String title) {
    final newState = TradingState(
      technicals: state.technicals.map((p) => p.title == title ? p.copyWith(isChecked: !p.isChecked) : p).toList(),
      riskManagement: state.riskManagement.map((p) => p.title == title ? p.copyWith(isChecked: !p.isChecked) : p).toList(),
      marketConditions: state.marketConditions.map((p) => p.title == title ? p.copyWith(isChecked: !p.isChecked) : p).toList(),
    );

    final score = _service.calculateScore(newState.technicals, newState.riskManagement, newState.marketConditions);
    final decision = _service.evaluateDecision(score);

    log.info('Evaluation Update: Parameter "$title" toggled. New Score: $score, Decision: $decision');

    state = newState;
  }

  void reset() {
    log.info('Resetting evaluation dashboard.');
    state = TradingState(
      technicals: state.technicals.map((p) => p.copyWith(isChecked: false)).toList(),
      riskManagement: state.riskManagement.map((p) => p.copyWith(isChecked: false)).toList(),
      marketConditions: state.marketConditions.map((p) => p.copyWith(isChecked: false)).toList(),
    );
  }
}
