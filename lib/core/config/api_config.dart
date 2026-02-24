/// API configuration for external data sources.
/// Pass key at build time: --dart-define=ALPHA_VANTAGE_KEY=your_key
class ApiConfig {
  static const String alphaVantageApiKey = String.fromEnvironment(
    'ALPHA_VANTAGE_KEY',
    defaultValue: 'demo',
  );

  static const String alphaVantageBaseUrl = 'www.alphavantage.co';
}
