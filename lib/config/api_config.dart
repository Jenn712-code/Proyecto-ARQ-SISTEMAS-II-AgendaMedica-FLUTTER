import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:2025"; // navegador web
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:2025"; // emulador Android
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:2025"; // simulador iOS
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return "http://localhost:2025"; // apps de escritorio
    } else {
      return "http://localhost:2025"; // Otro entorno
    }
  }
}


