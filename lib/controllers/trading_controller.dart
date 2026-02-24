import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/core/utils/logger_utils.dart';
import 'package:test_case/models/trading_parameter.dart';
import 'package:test_case/services/trading_logic/trading_service.dart';

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
            weight: EngineConfig.trendAlignmentWeight),
        TradingParameter(
            title: 'Support/Resistance',
            description: 'Trade is taken near a major key level or Fibonacci zone.',
            weight: EngineConfig.supportResistanceWeight),
        TradingParameter(
            title: 'Volume Confirmation',
            description: 'Breakout or bounce is supported by above-average volume.',
            weight: EngineConfig.volumeConfirmationWeight),
      ],
      riskManagement: [
        TradingParameter(
            title: 'Risk-Reward Ratio',
            description: 'The setup offers at least a 1:2 Risk-Reward ratio.',
            weight: EngineConfig.riskRewardWeight),
        TradingParameter(
            title: 'Position Sizing',
            description: 'Calculated lot size aligns with 1% risk per trade.',
            weight: EngineConfig.positionSizingWeight),
      ],
      marketConditions: [
        TradingParameter(
            title: 'Volatility (ATR)',
            description: 'Market volatility is within normal ranges for your SL.',
            weight: EngineConfig.volatilityAtrWeight),
        TradingParameter(
            title: 'No Impact News',
            description: 'No major economic data release in the next 1 hour.',
            weight: EngineConfig.newsIntegrityWeight),
      ],
    );
  }

  void toggleParameter(String title) {
    var newState = state.copyWith(
      technicals: state.technicals.map((p) => p.title == title ? p.copyWith(isChecked: !p.isChecked) : p).toList(),
      riskManagement: state.riskManagement.map((p) => p.title == title ? p.copyWith(isChecked: !p.isChecked) : p).toList(),
      marketConditions: state.marketConditions.map((p) => p.title == title ? p.copyWith(isChecked: !p.isChecked) : p).toList(),
    );

    // Update evaluation metrics using service
    final score = _service.calculateScore(newState.technicals, newState.riskManagement, newState.marketConditions);
    
    final snapshots = {
      for (final p in [...newState.technicals, ...newState.riskManagement, ...newState.marketConditions])
        p.title: p.isChecked
    };

    final evaluation = _service.evaluate(score, snapshots);

    // Update state with evaluation results
    newState = newState.copyWith(
      totalScore: evaluation.rawScore,
      decision: evaluation.decision,
      grade: evaluation.grade,
      percentage: evaluation.percentage,
    );

    log.info('Evaluation Decision: ${evaluation.grade} -> ${evaluation.decision}');
    log.fine('Evaluation Breakdown: ${evaluation.toJson()}');

    state = newState;
  }

  /// Updates multiple parameters at once from an auto-detection map.
  void applyAutoDetection(Map<String, bool> decisions) {
    final newState = state.copyWith(
      technicals: state.technicals.map((p) => decisions.containsKey(p.title) ? p.copyWith(isChecked: decisions[p.title], isAutoDetected: true) : p).toList(),
      riskManagement: state.riskManagement.map((p) => decisions.containsKey(p.title) ? p.copyWith(isChecked: decisions[p.title], isAutoDetected: true) : p).toList(),
      marketConditions: state.marketConditions.map((p) => decisions.containsKey(p.title) ? p.copyWith(isChecked: decisions[p.title], isAutoDetected: true) : p).toList(),
    );

    // Re-evaluate
    final score = _service.calculateScore(newState.technicals, newState.riskManagement, newState.marketConditions);
    final snapshots = {
      for (final p in [...newState.technicals, ...newState.riskManagement, ...newState.marketConditions])
        p.title: p.isChecked
    };
    final evaluation = _service.evaluate(score, snapshots);

    state = newState.copyWith(
      totalScore: evaluation.rawScore,
      decision: evaluation.decision,
      grade: evaluation.grade,
      percentage: evaluation.percentage,
    );

    log.info('Auto-detection applied. Final Score: ${evaluation.rawScore}');
  }

  void reset() {
    log.info('Resetting evaluation dashboard.');
    final newState = TradingState(
      technicals: state.technicals.map((p) => p.copyWith(isChecked: false)).toList(),
      riskManagement: state.riskManagement.map((p) => p.copyWith(isChecked: false)).toList(),
      marketConditions: state.marketConditions.map((p) => p.copyWith(isChecked: false)).toList(),
      totalScore: 0,
      decision: "Low Probability (No Trade)",
      grade: "Grade C",
      percentage: 0.0,
    );
    state = newState;
  }
}
