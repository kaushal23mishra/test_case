/// Computed indicator values from market data analysis.
class IndicatorResult {
  final double currentPrice;
  final double ema200;
  final double rsi14;
  final double atr14;
  final double currentVolume;
  final double averageVolume;
  final bool isHigherHighs;
  final bool isLiquidityGrab;

  const IndicatorResult({
    required this.currentPrice,
    required this.ema200,
    required this.rsi14,
    required this.atr14,
    required this.currentVolume,
    required this.averageVolume,
    required this.isHigherHighs,
    required this.isLiquidityGrab,
  });

  Map<String, dynamic> toJson() => {
    'currentPrice': currentPrice,
    'ema200': ema200,
    'rsi14': rsi14,
    'atr14': atr14,
    'currentVolume': currentVolume,
    'averageVolume': averageVolume,
    'isHigherHighs': isHigherHighs,
    'isLiquidityGrab': isLiquidityGrab,
  };
}

/// Maps indicator analysis to trading parameter auto-detection decisions.
class AutoDetectionResult {
  final Map<String, bool> parameterDecisions;
  final IndicatorResult indicators;

  const AutoDetectionResult({
    required this.parameterDecisions,
    required this.indicators,
  });
}
