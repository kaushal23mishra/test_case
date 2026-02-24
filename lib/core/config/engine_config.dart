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

  // Derived denominator
  static const int totalPossibleScore = trendAlignmentWeight +
      supportResistanceWeight +
      volumeConfirmationWeight +
      riskRewardWeight +
      positionSizingWeight +
      volatilityAtrWeight +
      newsIntegrityWeight;

  // Grade Thresholds (Points)
  static const int gradeAThreshold = 12;
  static const int gradeBThreshold = 8;
  
  // Grade Names
  static const String gradeA = "Grade A";
  static const String gradeB = "Grade B";
  static const String gradeC = "Grade C";

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
