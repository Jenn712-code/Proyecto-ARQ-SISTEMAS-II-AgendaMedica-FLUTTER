import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0046AA);
  static const Color secondaryColor = Color(0xFF47D6B9);
  static const Color backgroundColor = Color(0xFFE4F1EF);
  static const String fontFamily = "SnapITC";

  /// Helper para generar estilos con la fuente SnapITC
  static TextStyle snapStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black87,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      // Colores principales
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0046AA),   // Azul oscuro
        secondary: Color(0xFF47D6B9), // Verde agua
        background: Color(0xFFE4F1EF),
        error: Colors.redAccent,
      ),

      scaffoldBackgroundColor: const Color(0xFFE4F1EF),

      // Estilos de texto globales
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
          minimumSize: const Size(215, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.secondaryColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 18,
          color: AppTheme.primaryColor,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(215, 47)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16),
          ),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed)) {
              return AppTheme.primaryColor; // hover/focus en primary
            }
            return Colors.black87; // estado normal en negro
          }),
          side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed)) {
              return const BorderSide(color: AppTheme.primaryColor, width: 1);
            }
            return BorderSide.none; // sin borde normalmente
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          overlayColor: MaterialStateProperty.all(
            AppTheme.primaryColor.withOpacity(0.08), // efecto al presionar
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: secondaryColor,
        secondary: primaryColor,
        background: Color(0xFF121212),
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }
}

