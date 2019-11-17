import 'package:date_format/date_format.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

Logger log = new Logger();

class Logger {
  static List<String> _log = [];

  static String getLog() {
    String res = '';
    _log.forEach((line) {
      res += "$line\n";
    });
    return res;
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;

    assert(inDebugMode = true);

    return inDebugMode;
  }

  void e(String message) {
    String dateString = DateTime.now().toString().substring(11, 22);
    _writeToLog("ERROR $dateString", message);
    // print("ERROR $dateString $message");
  }

  void w(String message) {
    String dateString = DateTime.now().toString().substring(11, 22);
    _writeToLog("WARN $dateString", message);
    // print("WARN $dateString $message");
  }

  void d(String message) {
    String dateString = DateTime.now().toString().substring(11, 22);
    _writeToLog("DEBUG $dateString", message);
    // print("DEBUG $dateString $message");
  }

  static void _writeToLog(String level, String message) {
    if (isInDebugMode) {
      debugPrint('$level $message');
    }
    DateTime t = DateTime.now();
    _log.add("${formatDate(t, [
      "mm",
      "dd",
      " ",
      "HH",
      ":",
      "nn",
      ":",
      "ss"
    ])} [$level] :  $message");
    if (_log.length > 100) {
      _log.removeAt(0);
    }
  }
}
