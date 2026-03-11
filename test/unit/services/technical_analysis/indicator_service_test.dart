import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/models/indicator_result.dart';
import 'package:test_case/models/market_data.dart';
import 'package:test_case/services/technical_analysis/indicator_service.dart';

void main() {
  late IndicatorService service;

  setUp(() {
    service = IndicatorService();
  });

  group('calculateEMA', () {
    test('returns empty list when data is shorter than period', () {
      final result = service.calculateEMA([1, 2, 3], 5);
      expect(result, isEmpty);
    });

    test('first EMA value equals SMA of the first N closes', () {
      final closes = [10.0, 11.0, 12.0, 13.0, 14.0];
      final result = service.calculateEMA(closes, 5);
      // SMA of [10,11,12,13,14] = 60/5 = 12
      expect(result.first, closeTo(12.0, 0.001));
    });

    test('produces correct number of output values', () {
      final closes = List.generate(50, (i) => 100.0 + i);
      final result = service.calculateEMA(closes, 10);
      // EMA starts at index 9 (period-1), so length = 50 - 10 + 1 = 41
      expect(result.length, 41);
    });

    test('responds to price direction changes', () {
      // Rising prices → EMA should trend upward
      final rising = List.generate(30, (i) => 100.0 + i.toDouble());
      final emaRising = service.calculateEMA(rising, 10);
      expect(emaRising.last, greaterThan(emaRising.first));
    });
  });

  group('calculateRSI', () {
    test('returns empty list when data is too short', () {
      final result = service.calculateRSI([1, 2, 3], 14);
      expect(result, isEmpty);
    });

    test('returns RSI of 100 when all changes are positive', () {
      final closes = List.generate(20, (i) => 100.0 + i);
      final result = service.calculateRSI(closes, 14);
      expect(result.first, closeTo(100.0, 0.01));
    });

    test('returns RSI near 0 when all changes are negative', () {
      final closes = List.generate(20, (i) => 200.0 - i);
      final result = service.calculateRSI(closes, 14);
      expect(result.first, closeTo(0.0, 0.01));
    });

    test('RSI is bounded between 0 and 100 for mixed data', () {
      final closes = [
        44.0,
        44.34,
        44.09,
        43.61,
        44.33,
        44.83,
        45.10,
        45.42,
        45.84,
        46.08,
        45.89,
        46.03,
        45.61,
        46.28,
        46.28,
        46.00,
        46.03,
        46.41,
        46.22,
        45.64,
      ];
      final result = service.calculateRSI(closes, 14);
      for (final rsi in result) {
        expect(rsi, greaterThanOrEqualTo(0));
        expect(rsi, lessThanOrEqualTo(100));
      }
    });
  });

  group('calculateATR', () {
    test('returns empty when bars are insufficient', () {
      final bars = _generateBars(5, basePrice: 100);
      final result = service.calculateATR(bars, 14);
      expect(result, isEmpty);
    });

    test('returns positive ATR values for valid data', () {
      final bars = _generateBars(30, basePrice: 100, volatility: 2.0);
      final result = service.calculateATR(bars, 14);
      expect(result, isNotEmpty);
      for (final atr in result) {
        expect(atr, greaterThan(0));
      }
    });
  });

  group('calculateAverageVolume', () {
    test('returns average of all volumes when fewer than period', () {
      final volumes = [100.0, 200.0, 300.0];
      final result = service.calculateAverageVolume(volumes, 20);
      expect(result, closeTo(200.0, 0.01));
    });

    test('returns average of last N volumes', () {
      final volumes = [100.0, 200.0, 300.0, 400.0, 500.0];
      final result = service.calculateAverageVolume(volumes, 3);
      // Last 3: 300, 400, 500 → avg = 400
      expect(result, closeTo(400.0, 0.01));
    });

    test('returns 0 for empty list', () {
      expect(service.calculateAverageVolume([], 20), 0);
    });
  });

  group('detectHigherHighs', () {
    test('returns false when bars are insufficient', () {
      final bars = _generateBars(10, basePrice: 100);
      expect(service.detectHigherHighs(bars), false);
    });

    test('returns true for clearly ascending swing highs', () {
      // Create bars with ascending highs
      final bars = <OhlcvBar>[];
      for (int i = 0; i < 60; i++) {
        final base = 100.0 + i * 0.5;
        // Create swing high pattern every ~10 bars
        final isSwingHigh = (i % 10 == 5);
        bars.add(
          OhlcvBar(
            timestamp: DateTime(2024, 1, 1).add(Duration(days: i)),
            open: base,
            high: isSwingHigh ? base + 5 + (i * 0.2) : base + 1,
            low: base - 1,
            close: base + 0.5,
            volume: 1000,
          ),
        );
      }
      expect(service.detectHigherHighs(bars), true);
    });
  });

  group('detectLiquidityGrab', () {
    test('returns true for a clear bullish fakeout (trap)', () {
      final bars = [
        OhlcvBar(
          timestamp: DateTime(2024, 1, 1),
          open: 100,
          high: 105,
          low: 99,
          close: 101,
          volume: 1000,
        ),
        OhlcvBar(
          timestamp: DateTime(2024, 1, 2),
          open: 101,
          high: 106,
          low: 100,
          close: 102,
          volume: 1000,
        ),
        OhlcvBar(
          timestamp: DateTime(2024, 1, 3),
          open: 102,
          high: 105,
          low: 101,
          close: 103,
          volume: 1000,
        ),
        // Trap Bar: High > prev highs (106), Close < prev highs, Big Wick
        OhlcvBar(
          timestamp: DateTime(2024, 1, 4),
          open: 104,
          high: 110,
          low: 102,
          close: 103,
          volume: 5000,
        ),
      ];
      // prevMaxHigh = 106. TrapBar: High=110, Close=103. Wick=110-104=6. Body=1.
      expect(service.detectLiquidityGrab(bars), true);
    });

    test('returns false when price sustains above breakout level', () {
      final bars = [
        OhlcvBar(
          timestamp: DateTime(2024, 1, 1),
          open: 100,
          high: 105,
          low: 99,
          close: 101,
          volume: 1000,
        ),
        OhlcvBar(
          timestamp: DateTime(2024, 1, 2),
          open: 101,
          high: 106,
          low: 100,
          close: 102,
          volume: 1000,
        ),
        OhlcvBar(
          timestamp: DateTime(2024, 1, 3),
          open: 102,
          high: 105,
          low: 101,
          close: 103,
          volume: 1000,
        ),
        // Normal breakout
        OhlcvBar(
          timestamp: DateTime(2024, 1, 4),
          open: 104,
          high: 110,
          low: 104,
          close: 109,
          volume: 5000,
        ),
      ];
      expect(service.detectLiquidityGrab(bars), false);
    });
  });

  group('detectParameters', () {
    test('detects trend alignment when price > EMA and higher highs', () {
      final indicators = _makeIndicators(
        currentPrice: 150,
        ema200: 140,
        isHigherHighs: true,
      );
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['Trend Alignment'], true);
    });

    test('rejects trend alignment when price < EMA', () {
      final indicators = _makeIndicators(
        currentPrice: 130,
        ema200: 140,
        isHigherHighs: true,
      );
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['Trend Alignment'], false);
    });

    test('detects volume confirmation when above average', () {
      final indicators = _makeIndicators(
        currentVolume: 2000000,
        averageVolume: 1500000,
      );
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['Volume Confirmation'], true);
    });

    test('rejects volume confirmation when below average', () {
      final indicators = _makeIndicators(
        currentVolume: 500000,
        averageVolume: 1500000,
      );
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['Volume Confirmation'], false);
    });

    test('detects normal ATR volatility', () {
      // ATR/price = 3/150 = 0.02, within 0.003-0.05
      final indicators = _makeIndicators(currentPrice: 150, atr14: 3.0);
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['Volatility (ATR)'], true);
    });

    test('rejects ATR when volatility is too high', () {
      // ATR/price = 20/150 = 0.133, above 0.05
      final indicators = _makeIndicators(currentPrice: 150, atr14: 20.0);
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['Volatility (ATR)'], false);
    });

    test('No Liquidity Trap is true when no grab detected', () {
      final indicators = _makeIndicators(isLiquidityGrab: false);
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['No Liquidity Trap'], true);
    });

    test('No Liquidity Trap is false when grab detected', () {
      final indicators = _makeIndicators(isLiquidityGrab: true);
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions['No Liquidity Trap'], false);
    });

    test('returns exactly 4 parameter decisions', () {
      final indicators = _makeIndicators();
      final result = service.detectParameters(indicators);
      expect(result.parameterDecisions.length, 4);
      expect(result.parameterDecisions.containsKey('Trend Alignment'), true);
      expect(result.parameterDecisions.containsKey('No Liquidity Trap'), true);
      expect(
        result.parameterDecisions.containsKey('Volume Confirmation'),
        true,
      );
      expect(result.parameterDecisions.containsKey('Volatility (ATR)'), true);
    });
  });
}

/// Helper: generate OHLCV bars for testing.
List<OhlcvBar> _generateBars(
  int count, {
  double basePrice = 100,
  double volatility = 1.0,
}) {
  return List.generate(count, (i) {
    final price = basePrice + (i * 0.5);
    return OhlcvBar(
      timestamp: DateTime(2024, 1, 1).add(Duration(days: i)),
      open: price,
      high: price + volatility,
      low: price - volatility,
      close: price + 0.3,
      volume: 1000000 + (i * 10000),
    );
  });
}

/// Helper: create IndicatorResult with defaults.
IndicatorResult _makeIndicators({
  double currentPrice = 150,
  double ema200 = 140,
  double rsi14 = 55,
  double atr14 = 3.0,
  double currentVolume = 2000000,
  double averageVolume = 1500000,
  bool isHigherHighs = true,
  bool isLiquidityGrab = false,
}) {
  return IndicatorResult(
    currentPrice: currentPrice,
    ema200: ema200,
    rsi14: rsi14,
    atr14: atr14,
    currentVolume: currentVolume,
    averageVolume: averageVolume,
    isHigherHighs: isHigherHighs,
    isLiquidityGrab: isLiquidityGrab,
  );
}
