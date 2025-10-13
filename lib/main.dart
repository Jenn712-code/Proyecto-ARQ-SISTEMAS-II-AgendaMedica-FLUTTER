import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/pages/Home.dart';
import 'package:flutter_agenda_medica/theme/AppTheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda Médica',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
