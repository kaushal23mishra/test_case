import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_case/core/config/api_config.dart';
import 'package:test_case/models/market_data.dart';

/// Sealed result type for market data operations.
sealed class MarketDataResult {
  const MarketDataResult();
}

class MarketDataSuccess extends MarketDataResult {
  final MarketData data;
  const MarketDataSuccess(this.data);
}

class MarketDataError extends MarketDataResult {
  final String message;
  const MarketDataError(this.message);
}

/// Fetches OHLCV market data from Alpha Vantage.
/// Handles caching to respect API rate limits (25 req/day free tier).
class MarketDataRepository {
  final http.Client _client;
  final Map<String, _CacheEntry> _cache = {};
  static const _cacheDuration = Duration(minutes: 5);

  MarketDataRepository({required http.Client client}) : _client = client;

  Future<MarketDataResult> fetchOHLCV(
    String symbol, {
    String timeframe = 'daily',
  }) async {
    final cacheKey = '$symbol:$timeframe';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return MarketDataSuccess(cached.data);
    }

    try {
      final uri = Uri.https(ApiConfig.alphaVantageBaseUrl, '/query', {
        'function': 'TIME_SERIES_DAILY',
        'symbol': symbol,
        'outputsize': 'full',
        'apikey': ApiConfig.alphaVantageApiKey,
      });

      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        return MarketDataError('HTTP ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json.containsKey('Error Message')) {
        return MarketDataError(json['Error Message'] as String);
      }

      if (json.containsKey('Note')) {
        return const MarketDataError(
          'API rate limit reached. Please try again later.',
        );
      }

      final timeSeries = json['Time Series (Daily)'] as Map<String, dynamic>?;
      if (timeSeries == null || timeSeries.isEmpty) {
        return const MarketDataError('No data returned for this symbol.');
      }

      final bars =
          timeSeries.entries.map((e) {
              final values = e.value as Map<String, dynamic>;
              return OhlcvBar(
                timestamp: DateTime.parse(e.key),
                open: double.parse(values['1. open'] as String),
                high: double.parse(values['2. high'] as String),
                low: double.parse(values['3. low'] as String),
                close: double.parse(values['4. close'] as String),
                volume: double.parse(values['5. volume'] as String),
              );
            }).toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Keep only the most recent 300 bars (enough for 200 EMA + buffer)
      final trimmed =
          bars.length > 300 ? bars.sublist(bars.length - 300) : bars;

      final data = MarketData(
        symbol: symbol,
        timeframe: timeframe,
        bars: trimmed,
      );
      _cache[cacheKey] = _CacheEntry(data: data, fetchedAt: DateTime.now());

      return MarketDataSuccess(data);
    } on FormatException {
      return const MarketDataError('Invalid response format from API.');
    } on http.ClientException catch (e) {
      return MarketDataError('Network error: ${e.message}');
    } catch (e) {
      return MarketDataError('Unexpected error: $e');
    }
  }

  void clearCache() => _cache.clear();
}

class _CacheEntry {
  final MarketData data;
  final DateTime fetchedAt;

  _CacheEntry({required this.data, required this.fetchedAt});

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) >
      MarketDataRepository._cacheDuration;
}
