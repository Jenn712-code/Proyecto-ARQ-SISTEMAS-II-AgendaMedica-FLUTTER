import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:2025"; // navegador web
    }

    // Para móviles y desktop
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "http://10.0.2.2:2025"; // emulador Android
      case TargetPlatform.iOS:
        return "http://127.0.0.1:2025"; // simulador iOS
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return "http://localhost:2025"; // apps de escritorio
      default:
        return "http://localhost:2025"; // Otro entorno
    }
  }
}


