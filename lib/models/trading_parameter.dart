class TradingParameter {
  final String title;
  final String description;
  final int weight;
  final bool isChecked;

  const TradingParameter({
    required this.title,
    required this.description,
    required this.weight,
    this.isChecked = false,
  });

  TradingParameter copyWith({bool? isChecked}) {
    return TradingParameter(
      title: title,
      description: description,
      weight: weight,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class TradingState {
  final List<TradingParameter> technicals;
  final List<TradingParameter> riskManagement;
  final List<TradingParameter> marketConditions;

  const TradingState({
    required this.technicals,
    required this.riskManagement,
    required this.marketConditions,
  });

  int get totalScore {
    int score = 0;
    for (var p in technicals) { if (p.isChecked) score += p.weight; }
    for (var p in riskManagement) { if (p.isChecked) score += p.weight; }
    for (var p in marketConditions) { if (p.isChecked) score += p.weight; }
    return score;
  }

  String get decision {
    final score = totalScore;
    if (score >= 12) return "High Probability (Trade Allowed)";
    if (score >= 8) return "Medium Probability (Half Size)";
    return "Low Probability (No Trade)";
  }
}
