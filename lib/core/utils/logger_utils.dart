import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

final log = Logger('TradingApp');

void setupLogging() {
  Logger.root.level = Level.ALL; 
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    }
  });
}
