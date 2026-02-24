import '../../models/trading_parameter.dart';

class TradingService {
  int calculateScore(List<TradingParameter> technicals, 
                     List<TradingParameter> riskManagement, 
                     List<TradingParameter> marketConditions) {
    int score = 0;
    for (var p in technicals) { if (p.isChecked) score += p.weight; }
    for (var p in riskManagement) { if (p.isChecked) score += p.weight; }
    for (var p in marketConditions) { if (p.isChecked) score += p.weight; }
    return score;
  }

  String evaluateDecision(int score) {
    if (score >= 12) return "High Probability (Trade Allowed)";
    if (score >= 8) return "Medium Probability (Half Size)";
    return "Low Probability (No Trade)";
  }
}
