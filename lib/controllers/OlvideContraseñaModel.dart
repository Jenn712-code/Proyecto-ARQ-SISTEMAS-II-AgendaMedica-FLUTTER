import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../pages/Home.dart';
import '../theme/AppTheme.dart';
import 'package:google_fonts/google_fonts.dart';

class OlvideContrasenaModel {
  // Controladores y FocusNodes
  final TextEditingController correoController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController nuevaContrasenaController = TextEditingController();

  final FocusNode correoFocus = FocusNode();
  final FocusNode tokenFocus = FocusNode();
  final FocusNode nuevaContrasenaFocus = FocusNode();

  bool correoValidado = false;
  bool tokenValidado = false;
  bool procesando = false;
  bool mostrarContrasena = false;
  bool mostrarToken = false;

  final String urlBase = "${ApiConfig.baseUrl}/IniciarSesion";
  String recoveryToken = "";

  // === Validar correo ===
  Future<void> validarCorreo(BuildContext context, GlobalKey<FormState> formKey, Function setState) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => procesando = true);
    final correo = correoController.text.trim();

    final response = await http.post(
      Uri.parse("$urlBase/olvide_contrasena"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"pacCorreo": correo}),
    );

    setState(() => procesando = false);

    final data = jsonDecode(response.body);
    final mensaje = data['mensaje'] ?? "Error al validar el correo";

    if (response.statusCode == 200) {
      _showDialog(context, "Correo enviado", mensaje);
      // Guardar el JWT que viene del backend
      recoveryToken = data["token"] ?? "";
      setState(() => correoValidado = true);
      FocusScope.of(context).unfocus();
    } else {
      _showDialog(context, "Error", mensaje);
    }
  }

  // === Validar token (Código de 6 digitos)===
  Future<void> validarToken(BuildContext context, GlobalKey<FormState> formKey, Function setState) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => procesando = true);

    final response = await http.post(
      Uri.parse("$urlBase/restablecer_contrasena"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pacCorreo": correoController.text.trim(),
        "token": recoveryToken,
        "codigo": tokenController.text.trim(),
        "nuevaContrasena": "",
      }),
    );

    setState(() => procesando = false);

    final data = jsonDecode(response.body);
    final mensaje = data['mensaje'] ?? "Error al validar el código";

    if (response.statusCode == 200) {
      _showDialog(context, "Código validado", mensaje);
      setState(() => tokenValidado = true);
      FocusScope.of(context).unfocus();
    } else {
      _showDialog(context, "Error", mensaje);
    }
  }

  // === Restablecer contraseña ===
  Future<void> restablecerContrasena(BuildContext context, GlobalKey<FormState> formKey, Function setState) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => procesando = true);
    final correo = correoController.text.trim();
    final token = tokenController.text.trim();
    final nuevaContrasena = nuevaContrasenaController.text.trim();

    final response = await http.post(
      Uri.parse("$urlBase/restablecer_contrasena"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pacCorreo": correo,
        "token": recoveryToken,       // JWT largo
        "codigo": tokenController.text.trim(),
        "nuevaContrasena": nuevaContrasena,
      }),
    );

    setState(() => procesando = false);

    final data = jsonDecode(response.body);
    final mensaje = data['mensaje'] ?? "Error al restablecer contraseña";

    if (response.statusCode == 200) {
      _showDialog(context, "Éxito", mensaje);
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    } else {
      _showDialog(context, "Error", mensaje);
    }
  }

  // === Diálogo genérico ===
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        actionsAlignment: MainAxisAlignment.center,
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
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === Liberar recursos ===
  void dispose() {
    correoController.dispose();
    tokenController.dispose();
    nuevaContrasenaController.dispose();
    correoFocus.dispose();
    tokenFocus.dispose();
    nuevaContrasenaFocus.dispose();
  }
}
