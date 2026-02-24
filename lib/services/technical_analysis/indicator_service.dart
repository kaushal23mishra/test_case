import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/models/indicator_result.dart';
import 'package:test_case/models/market_data.dart';

/// Pure, synchronous technical indicator calculations.
/// No side effects, no async, no logging — deterministic input→output.
class IndicatorService {
  /// Exponential Moving Average.
  /// [closes] must be ordered oldest-first. Returns EMA values aligned to input.
  List<double> calculateEMA(List<double> closes, int period) {
    if (closes.length < period) return [];

    final multiplier = 2.0 / (period + 1);
    final emaValues = <double>[];

    // Seed with SMA of first [period] bars
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += closes[i];
    }
    double ema = sum / period;
    emaValues.add(ema);

    // Calculate remaining EMA values
    for (int i = period; i < closes.length; i++) {
      ema = (closes[i] - ema) * multiplier + ema;
      emaValues.add(ema);
    }

    return emaValues;
  }

  /// Relative Strength Index using Wilder's smoothing.
  /// Returns RSI values (0–100). First valid RSI appears after [period] bars.
  List<double> calculateRSI(List<double> closes, int period) {
    if (closes.length < period + 1) return [];

    final rsiValues = <double>[];
    double avgGain = 0;
    double avgLoss = 0;

    // Initial average gain/loss over first [period] changes
    for (int i = 1; i <= period; i++) {
      final change = closes[i] - closes[i - 1];
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }
    avgGain /= period;
    avgLoss /= period;

    // First RSI
    if (avgLoss == 0) {
      rsiValues.add(100.0);
    } else {
      final rs = avgGain / avgLoss;
      rsiValues.add(100.0 - (100.0 / (1.0 + rs)));
    }

    // Subsequent RSI using Wilder's smoothing
    for (int i = period + 1; i < closes.length; i++) {
      final change = closes[i] - closes[i - 1];
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? change.abs() : 0.0;

      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;

      if (avgLoss == 0) {
        rsiValues.add(100.0);
      } else {
        final rs = avgGain / avgLoss;
        rsiValues.add(100.0 - (100.0 / (1.0 + rs)));
      }
    }

    return rsiValues;
  }

  /// Average True Range using Wilder's smoothing.
  /// TR = max(H-L, |H-prevClose|, |L-prevClose|).
  List<double> calculateATR(List<OhlcvBar> bars, int period) {
    if (bars.length < period + 1) return [];

    final trValues = <double>[];

    // Calculate True Range for each bar (starting from index 1)
    for (int i = 1; i < bars.length; i++) {
      final high = bars[i].high;
      final low = bars[i].low;
      final prevClose = bars[i - 1].close;

      final tr = [
        high - low,
        (high - prevClose).abs(),
        (low - prevClose).abs(),
      ].reduce((a, b) => a > b ? a : b);

      trValues.add(tr);
    }

    if (trValues.length < period) return [];

    // Seed ATR with simple average of first [period] TR values
    double atr = 0;
    for (int i = 0; i < period; i++) {
      atr += trValues[i];
    }
    atr /= period;

    final atrValues = <double>[atr];

    // Wilder's smoothing for subsequent values
    for (int i = period; i < trValues.length; i++) {
      atr = (atr * (period - 1) + trValues[i]) / period;
      atrValues.add(atr);
    }

    return atrValues;
  }

  /// Simple moving average of volume over [period] bars.
  double calculateAverageVolume(List<double> volumes, int period) {
    if (volumes.length < period) {
      if (volumes.isEmpty) return 0;
      return volumes.reduce((a, b) => a + b) / volumes.length;
    }

    final recent = volumes.sublist(volumes.length - period);
    return recent.reduce((a, b) => a + b) / period;
  }

  /// Simplified higher-highs detection: compares last 3 local swing highs.
  /// Returns true if recent highs are ascending.
  bool detectHigherHighs(List<OhlcvBar> bars, {int lookback = 50}) {
    if (bars.length < lookback) return false;

    final recent = bars.sublist(bars.length - lookback);
    final swingHighs = <double>[];

    // Find local highs (bar higher than neighbors)
    for (int i = 2; i < recent.length - 2; i++) {
      if (recent[i].high > recent[i - 1].high &&
          recent[i].high > recent[i - 2].high &&
          recent[i].high > recent[i + 1].high &&
          recent[i].high > recent[i + 2].high) {
        swingHighs.add(recent[i].high);
      }
    }

    if (swingHighs.length < 2) return false;

    // Check if the last 2 swing highs are ascending
    final lastTwo = swingHighs.sublist(swingHighs.length - 2);
    return lastTwo[1] > lastTwo[0];
  }

  /// Master analysis: computes all indicators from raw market data.
  IndicatorResult analyzeMarketData(MarketData data) {
    final closes = data.bars.map((b) => b.close).toList();
    final volumes = data.bars.map((b) => b.volume).toList();

    final emaValues = calculateEMA(closes, EngineConfig.emaPeriod);
    final rsiValues = calculateRSI(closes, EngineConfig.rsiPeriod);
    final atrValues = calculateATR(data.bars, EngineConfig.atrPeriod);
    final avgVolume = calculateAverageVolume(
      volumes,
      EngineConfig.volumeAvgPeriod,
    );

    return IndicatorResult(
      currentPrice: closes.last,
      ema200: emaValues.isNotEmpty ? emaValues.last : closes.last,
      rsi14: rsiValues.isNotEmpty ? rsiValues.last : 50.0,
      atr14: atrValues.isNotEmpty ? atrValues.last : 0.0,
      currentVolume: volumes.last,
      averageVolume: avgVolume,
      isHigherHighs: detectHigherHighs(data.bars),
    );
  }

  /// Maps indicator results to parameter auto-detection decisions.
  AutoDetectionResult detectParameters(IndicatorResult indicators) {
    final decisions = <String, bool>{};

    // Trend Alignment: price above EMA200 AND making higher highs
    decisions['Trend Alignment'] =
        indicators.currentPrice > indicators.ema200 &&
            indicators.isHigherHighs;

    // Volume Confirmation: current volume above average * multiplier
    decisions['Volume Confirmation'] = indicators.currentVolume >
        (indicators.averageVolume * EngineConfig.volumeAboveAvgMultiplier);

    // Volatility (ATR): ATR as % of price within normal range
    final atrPercent = indicators.currentPrice > 0
        ? indicators.atr14 / indicators.currentPrice
        : 0.0;
    decisions['Volatility (ATR)'] =
        atrPercent <= EngineConfig.atrNormalRangeMaxPercent &&
            atrPercent >= EngineConfig.atrNormalRangeMinPercent;

    return AutoDetectionResult(
      parameterDecisions: decisions,
      indicators: indicators,
    );
  }
}
