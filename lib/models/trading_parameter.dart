class TradingParameter {
  final String title;
  final String description;
  final int weight;
  final bool isChecked;
  final bool isAutoDetected;
  final bool isHardFilter;

  const TradingParameter({
    required this.title,
    required this.description,
    required this.weight,
    this.isChecked = false,
    this.isAutoDetected = false,
    this.isHardFilter = false,
  });

  TradingParameter copyWith({bool? isChecked, bool? isAutoDetected}) {
    return TradingParameter(
      title: title,
      description: description,
      weight: weight,
      isChecked: isChecked ?? this.isChecked,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      isHardFilter: isHardFilter,
    );
  }
}

class TradingState {
  final List<TradingParameter> technicals;
  final List<TradingParameter> riskManagement;
  final List<TradingParameter> marketConditions;

  // Evaluation fields populated via controller/service
  final int totalScore;
  final String grade;
  final String action;
  final String positionSize;
  final double percentage;
  final bool isHardFilterTriggered;
  final String? hardFilterReason;

  const TradingState({
    required this.technicals,
    required this.riskManagement,
    required this.marketConditions,
    this.totalScore = 0,
    this.grade = "C",
    this.action = "block",
    this.positionSize = "none",
    this.percentage = 0.0,
    this.isHardFilterTriggered = false,
    this.hardFilterReason,
  });

  TradingState copyWith({
    List<TradingParameter>? technicals,
    List<TradingParameter>? riskManagement,
    List<TradingParameter>? marketConditions,
    int? totalScore,
    String? grade,
    String? action,
    String? positionSize,
    double? percentage,
    bool? isHardFilterTriggered,
    String? hardFilterReason,
  }) {
    return TradingState(
      technicals: technicals ?? this.technicals,
      riskManagement: riskManagement ?? this.riskManagement,
      marketConditions: marketConditions ?? this.marketConditions,
      totalScore: totalScore ?? this.totalScore,
      grade: grade ?? this.grade,
      action: action ?? this.action,
      positionSize: positionSize ?? this.positionSize,
      percentage: percentage ?? this.percentage,
      isHardFilterTriggered:
          isHardFilterTriggered ?? this.isHardFilterTriggered,
      hardFilterReason: hardFilterReason ?? this.hardFilterReason,
    );
  }
}
