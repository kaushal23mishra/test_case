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
        const TradingParameter(title: 'T1', description: 'D1', weight: 3, isChecked: true),
        const TradingParameter(title: 'T2', description: 'D2', weight: 2, isChecked: false),
      ];
      final risk = [
        const TradingParameter(title: 'R1', description: 'D3', weight: 5, isChecked: true),
      ];
      
      final score = service.calculateScore(technicals, risk, []);
      expect(score, 8); // 3 + 5
    });

    test('evaluate should return Grade A when score meets threshold', () {
      final result = service.evaluate(EngineConfig.gradeAThreshold, {});
      expect(result.grade, EngineConfig.gradeA);
      
      final expected = double.parse((EngineConfig.gradeAThreshold / EngineConfig.totalPossibleScore * 100).toStringAsFixed(1));
      expect(result.percentage, expected);
    });

    test('evaluate should return Grade C for zero score', () {
      final result = service.evaluate(0, {});
      expect(result.grade, EngineConfig.gradeC);
      expect(result.rawScore, 0);
      expect(result.percentage, 0.0);
    });

    test('evaluate output should be serializable to JSON', () {
      final snapshots = {'Trend': true, 'Risk': false};
      final result = service.evaluate(10, snapshots);
      final json = result.toJson();

      expect(json['rawScore'], 10);
      expect(json['grade'], isA<String>());
      expect(json['parameterSnapshots'], snapshots);
    });
  });
}
