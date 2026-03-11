import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/models/trading_parameter.dart';
import 'package:test_case/services/trading_logic/trading_service.dart';

void main() {
  late TradingService service;

  setUp(() {
    service = TradingService();
  });

  group('TradingService Evaluation Tests', () {
    test('calculateScore should return sum of weighted checked parameters', () {
      final technicals = [
        const TradingParameter(
          title: 'T1',
          description: 'D1',
          weight: 3,
          isChecked: true,
        ),
        const TradingParameter(
          title: 'T2',
          description: 'D2',
          weight: 2,
          isChecked: false,
        ),
      ];
      final risk = [
        const TradingParameter(
          title: 'R1',
          description: 'D3',
          weight: 5,
          isChecked: true,
        ),
      ];

      final result = service.calculateScore(technicals, risk, []);
      expect(result.score, 8); // 3 + 5
      expect(result.hardFilterPassed, isTrue);
    });

    test('evaluate should return Grade A when percentage meets threshold', () {
      // Use totalPossibleScore as the raw score to guarantee Grade A (100%)
      final result = service.evaluate(
        CalculationResult(score: EngineConfig.totalPossibleScore),
        {},
      );
      expect(result.grade, EngineConfig.gradeA);
      expect(result.action, 'allow');
      expect(result.positionSize, 'full');
    });

    test('evaluate should return Grade C for zero score', () {
      final result = service.evaluate(CalculationResult(score: 0), {});
      expect(result.grade, EngineConfig.gradeC);
      expect(result.rawScore, 0);
      expect(result.percentage, 0.0);
      expect(result.action, 'block');
    });

    test('evaluate output should be serializable to JSON', () {
      final snapshots = {'Trend': true, 'Risk': false};
      final result = service.evaluate(CalculationResult(score: 10), snapshots);
      final json = result.toJson();

      expect(json['rawScore'], 10);
      expect(json['grade'], isA<String>());
      expect(json['action'], isA<String>());
      expect(json['parameterSnapshots'], snapshots);
    });

    test(
      'calculateScore should capture failure and evaluate should block if hard filter fails',
      () {
        final technicals = [
          const TradingParameter(
            title: 'Hard Filter',
            description: 'Must be true',
            weight: 1,
            isChecked: false,
            isHardFilter: true,
          ),
        ];

        final result = service.calculateScore(technicals, [], []);
        expect(result.hardFilterPassed, isFalse);
        expect(result.failedFilterTitle, 'Hard Filter');

        final evaluation = service.evaluate(result, {'Hard Filter': false});
        expect(evaluation.isHardFilterTriggered, isTrue);
        expect(evaluation.hardFilterReason, 'Hard Filter');
        expect(evaluation.grade, EngineConfig.gradeC);
        expect(evaluation.action, 'block');
      },
    );
  });
}
