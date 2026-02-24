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
}
