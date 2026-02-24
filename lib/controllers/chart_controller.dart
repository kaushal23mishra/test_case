import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:test_case/controllers/trading_controller.dart';
import 'package:test_case/core/utils/logger_utils.dart';
import 'package:test_case/models/indicator_result.dart';
import 'package:test_case/repositories/market_data_repository.dart';
import 'package:test_case/services/technical_analysis/indicator_service.dart';

/// State for the chart analysis screen.
class ChartState {
  final String symbol;
  final bool isLoading;
  final String? errorMessage;
  final IndicatorResult? indicators;
  final AutoDetectionResult? autoDetection;
  final bool hasApplied;

  const ChartState({
    this.symbol = 'AAPL',
    this.isLoading = false,
    this.errorMessage,
    this.indicators,
    this.autoDetection,
    this.hasApplied = false,
  });

  ChartState copyWith({
    String? symbol,
    bool? isLoading,
    String? errorMessage,
    IndicatorResult? indicators,
    AutoDetectionResult? autoDetection,
    bool? hasApplied,
    bool clearError = false,
  }) {
    return ChartState(
      symbol: symbol ?? this.symbol,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      indicators: indicators ?? this.indicators,
      autoDetection: autoDetection ?? this.autoDetection,
      hasApplied: hasApplied ?? this.hasApplied,
    );
  }
}

// --- Providers ---

final marketDataRepositoryProvider = Provider(
  (ref) => MarketDataRepository(client: http.Client()),
);

final indicatorServiceProvider = Provider((ref) => IndicatorService());

final chartProvider = NotifierProvider<ChartController, ChartState>(
  () => ChartController(),
);

/// Orchestrates chart analysis: fetches data → calculates indicators → stores results.
class ChartController extends Notifier<ChartState> {
  @override
  ChartState build() => const ChartState();

  /// Fetch market data for [symbol] and run indicator analysis.
  Future<void> analyzeSymbol(String symbol) async {
    state = state.copyWith(
      symbol: symbol,
      isLoading: true,
      clearError: true,
      hasApplied: false,
    );

    final repo = ref.read(marketDataRepositoryProvider);
    final indicatorService = ref.read(indicatorServiceProvider);

    final result = await repo.fetchOHLCV(symbol);

    switch (result) {
      case MarketDataSuccess(:final data):
        final indicators = indicatorService.analyzeMarketData(data);
        final autoDetection = indicatorService.detectParameters(indicators);

        log.info('Analysis complete for $symbol: '
            '${autoDetection.parameterDecisions}');
        log.fine('Indicator values: ${indicators.toJson()}');

        state = state.copyWith(
          isLoading: false,
          indicators: indicators,
          autoDetection: autoDetection,
        );

      case MarketDataError(:final message):
        log.warning('Failed to fetch data for $symbol: $message');
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  /// Apply auto-detection results to the trading checklist.
  void applyAutoDetection() {
    final autoDetection = state.autoDetection;
    if (autoDetection == null) return;

    ref
        .read(tradingProvider.notifier)
        .applyAutoDetection(autoDetection.parameterDecisions);

    state = state.copyWith(hasApplied: true);
    log.info('Auto-detection applied to checklist.');
  }
}
