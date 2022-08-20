import 'dart:convert';
import 'dart:io';

class Utils {
  static String pathSep = Platform.isWindows ? '\\' : '/';

  static const String jsonIndent = '    ';

  static String formatJson(Map<String, dynamic> map) {
    return  const JsonEncoder.withIndent(jsonIndent).convert(map);
  }
}

