import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/pages/Home.dart';
import 'package:flutter_agenda_medica/services/local_notifications.dart';
import 'package:flutter_agenda_medica/services/notificacionService.dart';
import 'package:flutter_agenda_medica/theme/AppTheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalNotifications();

  // Iniciar la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda Médica',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

