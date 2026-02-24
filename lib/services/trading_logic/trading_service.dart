import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/models/trading_parameter.dart';

/// Serializable result of a trade evaluation.
class TradeEvaluation {
  final int rawScore;
  final double percentage;
  final String grade;
  final String decision;
  final Map<String, bool> parameterSnapshots;

  TradeEvaluation({
    required this.rawScore,
    required this.percentage,
    required this.grade,
    required this.decision,
    required this.parameterSnapshots,
  });

  Map<String, dynamic> toJson() => {
    'rawScore': rawScore,
    'percentage': percentage,
    'grade': grade,
    'decision': decision,
    'parameterSnapshots': parameterSnapshots,
  };
}

class TradingService {
  /// Pure synchronous calculation of the trade score.
  /// No side effects allowed.
  int calculateScore(List<TradingParameter> technicals, 
                     List<TradingParameter> riskManagement, 
                     List<TradingParameter> marketConditions) {
    int score = 0;
    for (var p in technicals) { if (p.isChecked) score += p.weight; }
    for (var p in riskManagement) { if (p.isChecked) score += p.weight; }
    for (var p in marketConditions) { if (p.isChecked) score += p.weight; }
    return score;
  }

  /// Evaluates the decision parameters into a structured, serializable result.
  TradeEvaluation evaluate(int score, Map<String, bool> snapshots) {
    final percentage = (score / EngineConfig.totalPossibleScore * 100);
    
    String grade;
    String decision;

    if (score >= EngineConfig.gradeAThreshold) {
      grade = EngineConfig.gradeA;
      decision = "High Probability (Trade Allowed)";
    } else if (score >= EngineConfig.gradeBThreshold) {
      grade = EngineConfig.gradeB;
      decision = "Medium Probability (Half Size)";
    } else {
      grade = EngineConfig.gradeC;
      decision = "Low Probability (No Trade)";
    }

    return TradeEvaluation(
      rawScore: score,
      percentage: double.parse(percentage.toStringAsFixed(1)),
      grade: grade,
      decision: decision,
      parameterSnapshots: snapshots,
    );
  }
}
