class TradeEvaluation {
  final int rawScore;
  final double percentage;
  final String grade;
  final String action;
  final String positionSize;
  final Map<String, bool> parameterSnapshots;
  final bool isHardFilterTriggered;
  final String? hardFilterReason;

  TradeEvaluation({
    required this.rawScore,
    required this.percentage,
    required this.grade,
    required this.action,
    required this.positionSize,
    required this.parameterSnapshots,
    this.isHardFilterTriggered = false,
    this.hardFilterReason,
  });

  Map<String, dynamic> toJson() => {
    'rawScore': rawScore,
    'percentage': percentage,
    'grade': grade,
    'action': action,
    'positionSize': positionSize,
    'isHardFilterTriggered': isHardFilterTriggered,
    'hardFilterReason': hardFilterReason,
    'parameterSnapshots': parameterSnapshots,
  };
}
