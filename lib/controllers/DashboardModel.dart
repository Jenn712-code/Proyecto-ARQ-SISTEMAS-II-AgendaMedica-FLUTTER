// Archivo: lib/controllers/DashboardModel.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importa la librería http para hacer llamadas a la API
import 'package:http/http.dart' as http;
import 'dart:convert'; // Necesario para json.decode
import '../theme/AppTheme.dart';

// 🎯 CORRECCIÓN 1: EXTENDER ChangeNotifier para que los widgets puedan escuchar cambios
class DashboardModel extends ChangeNotifier {
  String? token;

  // 🎯 CORRECCIÓN 2: DEFINIR LAS PROPIEDADES DE USUARIO
  String? nombreUsuario;
  String? correoUsuario;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final String _baseUrl = "TU_BASE_URL_DEL_BACKEND"; // ⚠️ REEMPLAZAR con tu URL base de la API

  // 🎯 CORRECCIÓN 3: MODIFICAR cargarDatosUsuario para obtener el usuario de la API
  Future<void> cargarDatosUsuario() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // 💡 Asumimos que tienes un endpoint para obtener los datos del usuario logueado.
      // Puedes necesitar enviar el token en los headers para autenticar la solicitud.
      final response = await http.get(
        Uri.parse('$_baseUrl/api/usuario/perfil'), // ⚠️ Ajusta este endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Envía el token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // Asignar los datos obtenidos de la API (Ajusta las claves 'nombre' y 'email')
        nombreUsuario = data['nombre'];
        correoUsuario = data['email'];
      } else {
        // Manejar errores de API
        print('Error al cargar datos del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al cargar datos del usuario: $e');
      // Opcional: limpiar token si hay error de autenticación persistente
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a Perfil.dart para que se actualice
    }
  }

  // --- El resto de tus métodos se mantiene igual ---

  /// Muestra un diálogo de confirmación de cierre de sesión
  void showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Confirmar",
          textAlign: TextAlign.center,
          style: AppTheme.snapStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Text(
          "¿Deseas cerrar sesión?",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text("Cancelar"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await logout(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Sí",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Opcional: Limpiar los datos del perfil al cerrar sesión
    nombreUsuario = null;
    correoUsuario = null;
    notifyListeners();
  }
}