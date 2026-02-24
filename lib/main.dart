import 'package:flutter/material.dart';
import 'trading_model.dart';

void main() {
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro Trader Decision System',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Navy
        useMaterial3: true,
      ),
      home: const TradingDashboard(),
    );
  }
}

class TradingDashboard extends StatefulWidget {
  const TradingDashboard({super.key});

  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> {
  final TradingFramework _framework = TradingFramework();

  void _reset() {
    setState(() {
      for (var p in _framework.technicals) {
        p.isChecked = false;
      }
      for (var p in _framework.riskManagement) {
        p.isChecked = false;
      }
      for (var p in _framework.marketConditions) {
        p.isChecked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentScore = _framework.calculateTotalScore();
    String decision = _framework.getDecision(currentScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Decision Framework', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(currentScore, decision),
            const SizedBox(height: 24),
            _buildSectionHeader('Technical Parameters'),
            ..._framework.technicals.map((p) => _buildCheckItem(p)),
            const SizedBox(height: 16),
            _buildSectionHeader('Risk Management'),
            ..._framework.riskManagement.map((p) => _buildCheckItem(p)),
            const SizedBox(height: 16),
            _buildSectionHeader('Market Conditions'),
            ..._framework.marketConditions.map((p) => _buildCheckItem(p)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(int score, String decision) {
    // bool isAllowed = score >= 8;
    Color statusColor = score >= 12 ? Colors.greenAccent : (score >= 8 ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF334155).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          const Text('CURRENT TRADE SCORE', 
            style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('$score / 14', 
            style: TextStyle(color: statusColor, fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(decision, 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, 
        style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCheckItem(TradingParameter parameter) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(parameter.title, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(parameter.description, 
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
        value: parameter.isChecked,
        activeColor: Colors.blueAccent,
        onChanged: (bool? value) {
          setState(() {
            parameter.isChecked = value ?? false;
          });
        },
        secondary: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Text('${parameter.weight}', style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
        ),
      ),
    );
  }
}
