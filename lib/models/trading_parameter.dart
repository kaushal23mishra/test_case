
class TradingParameter {
  final String title;
  final String description;
  final int weight;
  final bool isChecked;
  final bool isAutoDetected;

  const TradingParameter({
    required this.title,
    required this.description,
    required this.weight,
    this.isChecked = false,
    this.isAutoDetected = false,
  });

  TradingParameter copyWith({bool? isChecked, bool? isAutoDetected}) {
    return TradingParameter(
      title: title,
      description: description,
      weight: weight,
      isChecked: isChecked ?? this.isChecked,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
    );
  }
}

class TradingState {
  final List<TradingParameter> technicals;
  final List<TradingParameter> riskManagement;
  final List<TradingParameter> marketConditions;
  
  // Evaluation fields populated via controller/service
  final int totalScore;
  final String decision;
  final String grade;
  final double percentage;

  const TradingState({
    required this.technicals,
    required this.riskManagement,
    required this.marketConditions,
    this.totalScore = 0,
    this.decision = "Low Probability (No Trade)",
    this.grade = "Grade C",
    this.percentage = 0.0,
  });

  TradingState copyWith({
    List<TradingParameter>? technicals,
    List<TradingParameter>? riskManagement,
    List<TradingParameter>? marketConditions,
    int? totalScore,
    String? decision,
    String? grade,
    double? percentage,
  }) {
    return TradingState(
      technicals: technicals ?? this.technicals,
      riskManagement: riskManagement ?? this.riskManagement,
      marketConditions: marketConditions ?? this.marketConditions,
      totalScore: totalScore ?? this.totalScore,
      decision: decision ?? this.decision,
      grade: grade ?? this.grade,
      percentage: percentage ?? this.percentage,
    );
  }
}
