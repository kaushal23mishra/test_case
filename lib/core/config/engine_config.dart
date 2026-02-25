/// Centralized Configuration for the Trading Probability Engine.
/// Any changes here must trigger an Engine Version bump in docs.
class EngineConfig {
  // Weights for individual parameters
  static const int trendAlignmentWeight = 3;
  static const int supportResistanceWeight = 2;
  static const int volumeConfirmationWeight = 2;
  static const int riskRewardWeight = 3;
  static const int positionSizingWeight = 2;
  static const int volatilityAtrWeight = 1;
  static const int newsIntegrityWeight = 1;
  static const int liquidityTrapWeight = 3; // High weight for trap avoidance
  static const int topDownAlignmentWeight = 4; // Highest weight: all 3 timeframes must align

  // Derived denominator
  static const int totalPossibleScore =
      trendAlignmentWeight +
      supportResistanceWeight +
      volumeConfirmationWeight +
      riskRewardWeight +
      positionSizingWeight +
      volatilityAtrWeight +
      newsIntegrityWeight +
      liquidityTrapWeight +
      topDownAlignmentWeight;

  // Grade Thresholds (Percentages)
  static const double gradeAPercentThreshold = 85.0;
  static const double gradeBPercentThreshold = 55.0;

  // Grade Codes (Machine-Friendly)
  static const String gradeA = "A";
  static const String gradeB = "B";
  static const String gradeC = "C";

  // --- Indicator Calculation Periods ---
  static const int emaPeriod = 200;
  static const int rsiPeriod = 14;
  static const int atrPeriod = 14;
  static const int volumeAvgPeriod = 20;

  // --- Auto-Detection Thresholds ---
  /// Volume must exceed this multiplier of average to confirm
  static const double volumeAboveAvgMultiplier = 1.0;

  /// ATR as % of price — upper bound for "normal" volatility
  static const double atrNormalRangeMaxPercent = 0.05;

  /// ATR as % of price — lower bound (too low = no movement)
  static const double atrNormalRangeMinPercent = 0.003;

  /// Minimum bars required for a valid analysis
  static const int minimumBarsRequired = 250;
}
