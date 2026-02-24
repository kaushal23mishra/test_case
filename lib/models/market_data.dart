/// Single OHLCV bar representing one time period.
class OhlcvBar {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const OhlcvBar({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

/// Collection of OHLCV bars for a symbol and timeframe.
class MarketData {
  final String symbol;
  final String timeframe;
  final List<OhlcvBar> bars; // ordered oldest-first

  const MarketData({
    required this.symbol,
    required this.timeframe,
    required this.bars,
  });
}
