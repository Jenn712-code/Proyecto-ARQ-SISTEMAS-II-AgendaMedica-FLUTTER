import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../theme/AppTheme.dart';

class HomePageModel {
  // Controladores y FocusNodes
  final TextEditingController txtCorreoController = TextEditingController();
  final FocusNode txtCorreoFocus = FocusNode();

  final TextEditingController txtContrasenaController = TextEditingController();
  final FocusNode txtContrasenaFocus = FocusNode();

  bool passwordVisible = false;

  void dispose() {
    txtCorreoController.dispose();
    txtCorreoFocus.dispose();
    txtContrasenaController.dispose();
    txtContrasenaFocus.dispose();
  }

  Future<bool> iniciarSesion(BuildContext context) async {
    final correo = txtCorreoController.text.trim();
    final contrasena = txtContrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      _showDialog(context, "Error", "El correo y la contraseña no pueden estar vacíos.");
      return false;
    }
    if (!correo.contains('@')) {
      _showDialog(context, "Error", "El correo debe contener un '@'.");
      return false;
    }

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/IniciarSesion/autenticacion");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacCorreo": correo,
          "pacContrasena": contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('correo', data['correo']);
        await prefs.setString('nombre', data['nombre']);

        print("Token guardado correctamente");
        return true;

      } else if (response.statusCode == 401) {
        final error = jsonDecode(response.body);
        _showDialog(context, "Error", error["mensaje"] ?? "Credenciales inválidas.");
        return false;
      } else {
        _showDialog(context, "Error", "Error inesperado: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      _showDialog(context, "Error", "No se pudo conectar al servidor: $e");
      return false;
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // evita que se cierre al tocar fuera
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.snapStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center, // centra el botón
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

