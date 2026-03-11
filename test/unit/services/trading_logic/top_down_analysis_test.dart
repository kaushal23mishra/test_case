// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/models/trading_parameter.dart';
import 'package:test_case/services/trading_logic/trading_service.dart';

// ---------------------------------------------------------------------------
// Top-Down Multi-Timeframe Analysis — Unit Tests
//
// Standard Reference: docs/PROJECT_STANDARDS.md § 4.4
//
// The 3-Layer Rule:
//   L1 (Long TF):   Daily/Weekly  → macro trend direction
//   L2 (Medium TF): 4H/1H         → entry zone / pullback level
//   L3 (Short TF):  15m/5m        → exact timing + signal confirmation
//
// Rule: ALL three layers must align BEFORE a trade is taken.
// ---------------------------------------------------------------------------

void main() {
  late TradingService service;

  setUp(() {
    service = TradingService();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 1: EngineConfig Contract Validation
  // ─────────────────────────────────────────────────────────────────────────
  group('EngineConfig — Top-Down Weight Contract', () {
    test(
      'topDownAlignmentWeight is defined and greater than zero',
      () {
        expect(EngineConfig.topDownAlignmentWeight, greaterThan(0));
      },
    );

    test(
      'topDownAlignmentWeight is the HIGHEST single-parameter weight (§ 4.4)',
      () {
        final allWeights = [
          EngineConfig.trendAlignmentWeight,
          EngineConfig.supportResistanceWeight,
          EngineConfig.volumeConfirmationWeight,
          EngineConfig.riskRewardWeight,
          EngineConfig.positionSizingWeight,
          EngineConfig.volatilityAtrWeight,
          EngineConfig.newsIntegrityWeight,
          EngineConfig.liquidityTrapWeight,
        ];
        for (final w in allWeights) {
          expect(
            EngineConfig.topDownAlignmentWeight,
            greaterThanOrEqualTo(w),
            reason:
                'topDownAlignmentWeight (${EngineConfig.topDownAlignmentWeight}) '
                'must be >= $w to enforce it as the primary rule',
          );
        }
      },
    );

    test(
      'totalPossibleScore includes topDownAlignmentWeight',
      () {
        // Verify totalPossibleScore is the sum including topDownAlignmentWeight
        const expectedWithoutTopDown =
            EngineConfig.trendAlignmentWeight +
            EngineConfig.supportResistanceWeight +
            EngineConfig.volumeConfirmationWeight +
            EngineConfig.riskRewardWeight +
            EngineConfig.positionSizingWeight +
            EngineConfig.volatilityAtrWeight +
            EngineConfig.newsIntegrityWeight +
            EngineConfig.liquidityTrapWeight;

        expect(
          EngineConfig.totalPossibleScore,
          expectedWithoutTopDown + EngineConfig.topDownAlignmentWeight,
        );
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 2: Top-Down Parameter Score Impact
  // ─────────────────────────────────────────────────────────────────────────
  group('TradingService — Top-Down Alignment Score Impact', () {
    TradingParameter _makeTopDown({required bool isChecked}) =>
        TradingParameter(
          title: 'Top-Down Alignment',
          description:
              'Long TF trend + Medium TF zone + Short TF signal — all aligned.',
          weight: EngineConfig.topDownAlignmentWeight,
          isChecked: isChecked,
        );

    test(
      'score is 0 when Top-Down Alignment is the only parameter and unchecked',
      () {
        final result = service.calculateScore(
          [_makeTopDown(isChecked: false)],
          [],
          [],
        );
        expect(result.score, 0);
        expect(result.hardFilterPassed, isTrue);
      },
    );

    test(
      'score equals topDownAlignmentWeight when only Top-Down is checked',
      () {
        final result = service.calculateScore(
          [_makeTopDown(isChecked: true)],
          [],
          [],
        );
        expect(result.score, EngineConfig.topDownAlignmentWeight);
      },
    );

    test(
      'Top-Down adds maximum single-parameter contribution to final score',
      () {
        final baseParams = [
          const TradingParameter(
            title: 'Trend Alignment',
            description: 'EMA + HH',
            weight: EngineConfig.trendAlignmentWeight,
            isChecked: true,
          ),
        ];

        final withoutTopDown = service.calculateScore(baseParams, [], []);

        final withTopDown = service.calculateScore(
          [...baseParams, _makeTopDown(isChecked: true)],
          [],
          [],
        );

        expect(
          withTopDown.score - withoutTopDown.score,
          EngineConfig.topDownAlignmentWeight,
        );
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 3: The 3-Layer Alignment Rule — All-or-Nothing Logic
  // ─────────────────────────────────────────────────────────────────────────
  group('3-Layer Rule — Alignment Combinations', () {
    // Helper: build a mini-set of params representing each layer's confirmation
    List<TradingParameter> _buildLayerParams({
      required bool l1Trend, // Long TF: macro trend confirmed
      required bool l2Zone, // Medium TF: entry zone reached
      required bool l3Signal, // Short TF: timing signal fired
      required bool noTrap, // Hard filter: no liquidity grab
    }) {
      return [
        TradingParameter(
          title: 'Top-Down Alignment',
          description: 'All 3 TF aligned',
          weight: EngineConfig.topDownAlignmentWeight,
          // Top-Down is only marked true when ALL 3 layers align
          isChecked: l1Trend && l2Zone && l3Signal,
        ),
        TradingParameter(
          title: 'Trend Alignment',
          description: 'L1: Daily/Weekly trend',
          weight: EngineConfig.trendAlignmentWeight,
          isChecked: l1Trend,
        ),
        TradingParameter(
          title: 'Support/Resistance',
          description: 'L2: 4H/1H entry zone',
          weight: EngineConfig.supportResistanceWeight,
          isChecked: l2Zone,
        ),
        TradingParameter(
          title: 'Volume Confirmation',
          description: 'L3: 15m/5m signal volume',
          weight: EngineConfig.volumeConfirmationWeight,
          isChecked: l3Signal,
        ),
        TradingParameter(
          title: 'No Liquidity Trap',
          description: 'No fakeout detected',
          weight: EngineConfig.liquidityTrapWeight,
          isHardFilter: true,
          isChecked: noTrap,
        ),
      ];
    }

    test(
      'PERFECT SETUP: all 3 layers aligned → Top-Down checked → highest score',
      () {
        final params = _buildLayerParams(
          l1Trend: true,
          l2Zone: true,
          l3Signal: true,
          noTrap: true,
        );
        final result = service.calculateScore(params, [], []);
        expect(result.hardFilterPassed, isTrue);

        // Score = topDown(4) + trend(3) + sr(2) + volume(2) + trap(3) = 14
        final expectedScore =
            EngineConfig.topDownAlignmentWeight +
            EngineConfig.trendAlignmentWeight +
            EngineConfig.supportResistanceWeight +
            EngineConfig.volumeConfirmationWeight +
            EngineConfig.liquidityTrapWeight;
        expect(result.score, expectedScore);
      },
    );

    test(
      'PARTIAL: L1 + L2 aligned but L3 missing → Top-Down NOT checked',
      () {
        final params = _buildLayerParams(
          l1Trend: true,
          l2Zone: true,
          l3Signal: false, // No short TF confirmation
          noTrap: true,
        );
        final result = service.calculateScore(params, [], []);
        expect(result.hardFilterPassed, isTrue);

        // Top-Down is false because l3Signal is false
        // Score = trend(3) + sr(2) + trap(3) = 8 (no topDown, no volume)
        final expectedScore =
            EngineConfig.trendAlignmentWeight +
            EngineConfig.supportResistanceWeight +
            EngineConfig.liquidityTrapWeight;
        expect(result.score, expectedScore);
      },
    );

    test(
      'COUNTER-TREND: L1 bearish (trend false), L2+L3 bullish → Top-Down NOT checked',
      () {
        final params = _buildLayerParams(
          l1Trend: false, // Counter-trend vs. long TF → never trade
          l2Zone: true,
          l3Signal: true,
          noTrap: true,
        );
        final result = service.calculateScore(params, [], []);
        expect(result.hardFilterPassed, isTrue);

        // Top-Down = false (l1 missing). Score = sr(2) + volume(2) + trap(3) = 7
        final expectedScore =
            EngineConfig.supportResistanceWeight +
            EngineConfig.volumeConfirmationWeight +
            EngineConfig.liquidityTrapWeight;
        expect(result.score, expectedScore);
      },
    );

    test(
      'TRAP DETECTED: hard filter fails → score is 0 regardless of alignment',
      () {
        final params = _buildLayerParams(
          l1Trend: true,
          l2Zone: true,
          l3Signal: true,
          noTrap: false, // Liquidity grab detected!
        );
        final result = service.calculateScore(params, [], []);
        expect(result.hardFilterPassed, isFalse);
        expect(result.score, 0);
        expect(result.failedFilterTitle, 'No Liquidity Trap');
      },
    );

    test(
      'NO LAYERS aligned → score is only the hard filter baseline',
      () {
        final params = _buildLayerParams(
          l1Trend: false,
          l2Zone: false,
          l3Signal: false,
          noTrap: true,
        );
        final result = service.calculateScore(params, [], []);
        expect(result.hardFilterPassed, isTrue);
        // Only the hard filter (trap=true) contributes: trap(3)
        expect(result.score, EngineConfig.liquidityTrapWeight);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 4: Grade A Requires Top-Down Alignment (§ 4.4 Code Contract)
  // ─────────────────────────────────────────────────────────────────────────
  group('Grade A Enforcement — Top-Down Is Required', () {
    test(
      'Grade A is NOT achievable without Top-Down Alignment checked',
      () {
        // All other params checked, but Top-Down = false
        // Max score without topDown = totalPossible - topDownWeight
        final maxScoreWithoutTopDown =
            EngineConfig.totalPossibleScore - EngineConfig.topDownAlignmentWeight;
        final percentageWithoutTopDown =
            maxScoreWithoutTopDown / EngineConfig.totalPossibleScore * 100;

        expect(
          percentageWithoutTopDown,
          lessThan(EngineConfig.gradeAPercentThreshold),
          reason:
              'Without Top-Down Alignment, Grade A threshold (${EngineConfig.gradeAPercentThreshold}%) '
              'must be unreachable. Got: ${percentageWithoutTopDown.toStringAsFixed(1)}%',
        );
      },
    );

    test(
      'Grade A IS achievable when Top-Down Alignment is checked along with other high-weight params',
      () {
        // totalPossibleScore with everything = Grade A
        final evaluation = service.evaluate(
          CalculationResult(score: EngineConfig.totalPossibleScore),
          {'Top-Down Alignment': true},
        );
        expect(evaluation.grade, EngineConfig.gradeA);
        expect(evaluation.action, 'allow');
        expect(evaluation.positionSize, 'full');
      },
    );

    test(
      'evaluate serializes Top-Down Alignment decision into parameterSnapshots',
      () {
        final snapshots = {
          'Top-Down Alignment': true,
          'Trend Alignment': true,
          'No Liquidity Trap': true,
        };
        final result = service.evaluate(
          CalculationResult(
            score:
                EngineConfig.topDownAlignmentWeight +
                EngineConfig.trendAlignmentWeight +
                EngineConfig.liquidityTrapWeight,
          ),
          snapshots,
        );
        final json = result.toJson();

        expect(
          (json['parameterSnapshots'] as Map<String, bool>)['Top-Down Alignment'],
          isTrue,
        );
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GROUP 5: Grade B Boundary — Partial Alignment
  // ─────────────────────────────────────────────────────────────────────────
  group('Grade B — Partial Alignment Scoring', () {
    test(
      'setup with Top-Down + No Liquidity Trap only yields Grade C (insufficient)',
      () {
        final score =
            EngineConfig.topDownAlignmentWeight +
            EngineConfig.liquidityTrapWeight;
        final evaluation = service.evaluate(
          CalculationResult(score: score),
          {'Top-Down Alignment': true, 'No Liquidity Trap': true},
        );
        // score = 4+3 = 7 out of 21 = ~33.3% → Grade C
        expect(evaluation.grade, EngineConfig.gradeC);
        expect(evaluation.action, 'block');
      },
    );

    test(
      'setup crossing Grade B threshold allows half-size position',
      () {
        // Grade B needs >= 55% of totalPossibleScore
        final minGradeB =
            (EngineConfig.gradeBPercentThreshold / 100 * EngineConfig.totalPossibleScore)
                .ceil();
        final evaluation = service.evaluate(
          CalculationResult(score: minGradeB),
          {},
        );
        expect(evaluation.grade, EngineConfig.gradeB);
        expect(evaluation.positionSize, 'half');
        expect(evaluation.action, 'allow');
      },
    );
  });
}
