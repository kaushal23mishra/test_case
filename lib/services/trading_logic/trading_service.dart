import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/models/trade_evaluation.dart';
import 'package:test_case/models/trading_parameter.dart';

class CalculationResult {
  final int score;
  final bool hardFilterPassed;
  final String? failedFilterTitle;

  CalculationResult({
    required this.score,
    this.hardFilterPassed = true,
    this.failedFilterTitle,
  });
}

class TradingService {
  /// Pure synchronous calculation of the trade score.
  /// No side effects allowed.
  CalculationResult calculateScore(
    List<TradingParameter> technicals,
    List<TradingParameter> riskManagement,
    List<TradingParameter> marketConditions,
  ) {
    // 1. Evaluate Hard Filters first (short-circuit)
    final allParams = [...technicals, ...riskManagement, ...marketConditions];
    for (var p in allParams) {
      if (p.isHardFilter && !p.isChecked) {
        return CalculationResult(
          score: 0,
          hardFilterPassed: false,
          failedFilterTitle: p.title,
        );
      }
    }

    // 2. Normal weighted scoring
    int score = 0;
    for (var p in allParams) {
      if (p.isChecked) score += p.weight;
    }

    return CalculationResult(score: score);
  }

  /// Evaluates the decision parameters into a structured, serializable result.
  TradeEvaluation evaluate(
    CalculationResult result,
    Map<String, bool> snapshots,
  ) {
    if (!result.hardFilterPassed) {
      return TradeEvaluation(
        rawScore: 0,
        percentage: 0.0,
        grade: EngineConfig.gradeC,
        action: "block",
        positionSize: "none",
        parameterSnapshots: snapshots,
        isHardFilterTriggered: true,
        hardFilterReason: result.failedFilterTitle,
      );
    }

    final percentage = (result.score / EngineConfig.totalPossibleScore * 100);

    String grade;
    String action;
    String positionSize;

    if (percentage >= EngineConfig.gradeAPercentThreshold) {
      grade = EngineConfig.gradeA;
      action = "allow";
      positionSize = "full";
    } else if (percentage >= EngineConfig.gradeBPercentThreshold) {
      grade = EngineConfig.gradeB;
      action = "allow";
      positionSize = "half";
    } else {
      grade = EngineConfig.gradeC;
      action = "block";
      positionSize = "none";
    }

    return TradeEvaluation(
      rawScore: result.score,
      percentage: double.parse(percentage.toStringAsFixed(1)),
      grade: grade,
      action: action,
      positionSize: positionSize,
      parameterSnapshots: snapshots,
      isHardFilterTriggered: false,
    );
  }
}
