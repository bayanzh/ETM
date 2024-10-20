class Logger {
  static LogMode _logMode = LogMode.debug;

  static void init(LogMode mode) {
    Logger._logMode = mode;
  }

  static void _printRed(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void _printGreen(String text) {
    print('\x1B[32m$text\x1B[0m');
  }

  static void log(dynamic data, {StackTrace? stackTrace}) {
    if (_logMode == LogMode.debug) {
      _printGreen("Info: $data");
    }
  }
  
  static void logError(dynamic data, {StackTrace? stackTrace}) {
    if (_logMode == LogMode.debug) {
      _printRed("Error: $data");
    }
  }


}

enum LogMode { debug, live }
