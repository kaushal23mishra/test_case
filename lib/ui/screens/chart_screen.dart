import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_case/controllers/chart_controller.dart';
import 'package:test_case/models/indicator_result.dart';
import 'package:test_case/ui/widgets/symbol_search_bar.dart';
import 'package:test_case/ui/widgets/tradingview_widget.dart';

/// Chart analysis screen with TradingView embed and auto-detection.
class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Analysis',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          SymbolSearchBar(
            currentSymbol: chartState.symbol,
            onSymbolSubmitted: (symbol) {
              ref.read(chartProvider.notifier).analyzeSymbol(symbol);
            },
          ),
          Expanded(
            flex: 3,
            child: TradingViewChart(
              symbol: chartState.symbol,
              onChartLoaded: (_) {},
            ),
          ),
          Expanded(
            flex: 2,
            child: _AnalysisPanel(chartState: chartState),
          ),
        ],
      ),
    );
  }
}

class _AnalysisPanel extends ConsumerWidget {
  final ChartState chartState;

  const _AnalysisPanel({required this.chartState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            if (chartState.isLoading) _buildLoading(),
            if (chartState.errorMessage != null)
              _buildError(chartState.errorMessage!),
            if (chartState.indicators != null) ...[
              _buildIndicators(chartState.indicators!),
              const SizedBox(height: 12),
              if (chartState.autoDetection != null)
                _buildDetectionResults(chartState.autoDetection!),
              const SizedBox(height: 12),
              _buildApplyButton(ref),
            ],
            if (chartState.indicators == null && !chartState.isLoading)
              _buildPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.analytics, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          'Analysis: ${chartState.symbol}',
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 12),
            Text('Fetching market data...',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(message, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(IndicatorResult indicators) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _indicatorChip('Price', indicators.currentPrice.toStringAsFixed(2)),
        _indicatorChip('EMA 200', indicators.ema200.toStringAsFixed(2)),
        _indicatorChip('RSI 14', indicators.rsi14.toStringAsFixed(1)),
        _indicatorChip('ATR 14', indicators.atr14.toStringAsFixed(2)),
        _indicatorChip(
            'Volume',
            indicators.currentVolume > 1000000
                ? '${(indicators.currentVolume / 1000000).toStringAsFixed(1)}M'
                : '${(indicators.currentVolume / 1000).toStringAsFixed(0)}K'),
      ],
    );
  }

  Widget _indicatorChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDetectionResults(AutoDetectionResult detection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Auto-Detection',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...detection.parameterDecisions.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    e.value ? Icons.check_circle : Icons.cancel,
                    color: e.value ? Colors.greenAccent : Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(e.key,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildApplyButton(WidgetRef ref) {
    final hasApplied = chartState.hasApplied;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasApplied
            ? null
            : () => ref.read(chartProvider.notifier).applyAutoDetection(),
        icon: Icon(hasApplied ? Icons.check : Icons.auto_fix_high),
        label: Text(hasApplied
            ? 'Applied to Checklist'
            : 'Apply to Checklist'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasApplied ? Colors.grey.shade800 : Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPrompt() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Enter a symbol above and press send\nto analyze the chart automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }
}
