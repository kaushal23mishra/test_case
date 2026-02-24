class TradingParameter {
  final String title;
  final String description;
  final int weight;
  bool isChecked;

  TradingParameter({
    required this.title,
    required this.description,
    required this.weight,
    this.isChecked = false,
  });
}

class TradingFramework {
  final List<TradingParameter> technicals = [
    TradingParameter(
      title: 'Trend Alignment',
      description: 'Price is above 200 EMA and making Higher Highs.',
      weight: 3,
    ),
    TradingParameter(
      title: 'Support/Resistance',
      description: 'Trade is taken near a major key level or Fibonacci zone.',
      weight: 2,
    ),
    TradingParameter(
      title: 'Volume Confirmation',
      description: 'Breakout or bounce is supported by above-average volume.',
      weight: 2,
    ),
  ];

  final List<TradingParameter> riskManagement = [
    TradingParameter(
      title: 'Risk-Reward Ratio',
      description: 'The setup offers at least a 1:2 Risk-Reward ratio.',
      weight: 3,
    ),
    TradingParameter(
      title: 'Position Sizing',
      description: 'Calculated lot size aligns with 1% risk per trade.',
      weight: 2,
    ),
  ];

  final List<TradingParameter> marketConditions = [
    TradingParameter(
      title: 'Volatility (ATR)',
      description: 'Market volatility is within normal ranges for your SL.',
      weight: 1,
    ),
    TradingParameter(
      title: 'No Impact News',
      description: 'No major economic data release in the next 1 hour.',
      weight: 1,
    ),
  ];

  int calculateTotalScore() {
    int score = 0;
    for (var p in technicals) { if (p.isChecked) score += p.weight; }
    for (var p in riskManagement) { if (p.isChecked) score += p.weight; }
    for (var p in marketConditions) { if (p.isChecked) score += p.weight; }
    return score;
  }

  String getDecision(int score) {
    if (score >= 12) return "High Probability (Trade Allowed)";
    if (score >= 8) return "Medium Probability (Half Size)";
    return "Low Probability (No Trade)";
  }
}
