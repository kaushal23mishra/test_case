import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_case/ui/screens/trading_dashboard.dart';

void main() {
  testWidgets('TradingDashboard smoke test — renders core elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          ),
          home: const TradingDashboard(),
        ),
      ),
    );

    expect(find.text('Trade Decision Framework'), findsOneWidget);
    expect(find.text('CURRENT TRADE SCORE'), findsOneWidget);
  });
}
