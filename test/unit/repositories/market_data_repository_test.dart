import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test_case/repositories/market_data_repository.dart';

void main() {
  group('MarketDataRepository Tests', () {
    test('fetchOHLCV returns MarketDataSuccess on valid response', () async {
      final mockResponse = {
        "Time Series (Daily)": {
          "2026-02-24": {
            "1. open": "100.0",
            "2. high": "110.0",
            "3. low": "90.0",
            "4. close": "105.0",
            "5. volume": "1000",
          },
          "2026-02-23": {
            "1. open": "95.0",
            "2. high": "102.0",
            "3. low": "94.0",
            "4. close": "98.0",
            "5. volume": "800",
          },
        },
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final repository = MarketDataRepository(client: client);
      final result = await repository.fetchOHLCV('AAPL');

      expect(result, isA<MarketDataSuccess>());
      final data = (result as MarketDataSuccess).data;
      expect(data.symbol, 'AAPL');
      expect(data.bars.length, 2);
      expect(data.bars.first.close, 98.0); // Sorted oldest first
      expect(data.bars.last.close, 105.0);
    });

    test('fetchOHLCV returns MarketDataError on rate limit', () async {
      final mockResponse = {
        "Note":
            "Thank you for using Alpha Vantage! Our standard API rate limit is...",
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final repository = MarketDataRepository(client: client);
      final result = await repository.fetchOHLCV('AAPL');

      expect(result, isA<MarketDataError>());
      expect((result as MarketDataError).message, contains('rate limit'));
    });

    test('fetchOHLCV returns MarketDataError on invalid symbol', () async {
      final mockResponse = {
        "Error Message": "Invalid API call. Please retry...",
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final repository = MarketDataRepository(client: client);
      final result = await repository.fetchOHLCV('INVALID');

      expect(result, isA<MarketDataError>());
      expect((result as MarketDataError).message, contains('Invalid API call'));
    });

    test('fetchOHLCV handles HTTP errors', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository = MarketDataRepository(client: client);
      final result = await repository.fetchOHLCV('AAPL');

      expect(result, isA<MarketDataError>());
      expect((result as MarketDataError).message, contains('HTTP 404'));
    });

    test('Caching mechanism avoids redundant network calls', () async {
      int callCount = 0;
      final mockResponse = {
        "Time Series (Daily)": {
          "2026-02-24": {
            "1. open": "100.0",
            "2. high": "110.0",
            "3. low": "90.0",
            "4. close": "105.0",
            "5. volume": "1000",
          },
        },
      };

      final client = MockClient((request) async {
        callCount++;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final repository = MarketDataRepository(client: client);

      // First call
      await repository.fetchOHLCV('AAPL');
      expect(callCount, 1);

      // Second call (should be cached)
      await repository.fetchOHLCV('AAPL');
      expect(callCount, 1);

      // Different symbol
      await repository.fetchOHLCV('GOOG');
      expect(callCount, 2);
    });
    group('MarketDataRepository Caching Tests', () {
      test('clearCache removes existing entries', () async {
        final mockResponse = {
          "Time Series (Daily)": {
            "2026-02-24": {
              "1. open": "100",
              "2. high": "100",
              "3. low": "100",
              "4. close": "100",
              "5. volume": "100",
            },
          },
        };
        int callCount = 0;
        final client = MockClient((_) async {
          callCount++;
          return http.Response(jsonEncode(mockResponse), 200);
        });
        final repo = MarketDataRepository(client: client);

        await repo.fetchOHLCV('SYM');
        expect(callCount, 1);

        repo.clearCache();

        await repo.fetchOHLCV('SYM');
        expect(callCount, 2);
      });
    });
  });
}
