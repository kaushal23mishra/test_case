import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_case/core/config/engine_config.dart';
import 'package:test_case/controllers/trading_controller.dart';
import 'package:test_case/models/trading_parameter.dart';

class TradingDashboard extends ConsumerWidget {
  const TradingDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tradingProvider);
    final controller = ref.read(tradingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Decision Framework',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.reset(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(state),
            const SizedBox(height: 24),
            _buildSectionHeader('Technical Parameters'),
            ...state.technicals.map((p) => _buildCheckItem(p, controller)),
            const SizedBox(height: 16),
            _buildSectionHeader('Risk Management'),
            ...state.riskManagement.map((p) => _buildCheckItem(p, controller)),
            const SizedBox(height: 16),
            _buildSectionHeader('Market Conditions'),
            ...state.marketConditions.map((p) => _buildCheckItem(p, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(TradingState state) {
    final score = state.totalScore;
    final decision = state.decision;
    
    // Using Centralized Thresholds for Colors
    Color statusColor = score >= EngineConfig.gradeAThreshold
        ? Colors.greenAccent
        : (score >= EngineConfig.gradeBThreshold ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF334155).withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          const Text('CURRENT TRADE SCORE',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('$score / ${EngineConfig.totalPossibleScore}',
              style: TextStyle(
                  color: statusColor,
                  fontSize: 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(decision,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCheckItem(TradingParameter parameter, TradingController controller) {
    return Card(
      color: const Color(0xFF1E293B),
      key: ValueKey(parameter.title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(parameter.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(parameter.description,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        value: parameter.isChecked,
        activeColor: Colors.blueAccent,
        onChanged: (bool? value) {
          controller.toggleParameter(parameter.title);
        },
        secondary: CircleAvatar(
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
          child: Text('${parameter.weight}',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
        ),
      ),
    );
  }
}
