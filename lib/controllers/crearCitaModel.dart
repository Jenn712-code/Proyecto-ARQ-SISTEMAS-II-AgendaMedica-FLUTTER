import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../pages/Home.dart';
import '../theme/AppTheme.dart';

class crearCitaModel{
  final formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController nombreMedicoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  bool recordatorio = false; // valor por defecto
  List<Map<String, dynamic>> especialidades = [];
  int? especialidadSeleccionada;

  Future<void> cargarEspecialidades(VoidCallback onUpdate) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/especialidades/listarEspecialidades");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
        especialidades = data.map((e) => {
          "id": e["espId"],
          "nombre": e["espNombre"]
        }).toList();

        onUpdate();
    } else {
      throw Exception("Error al cargar especialidades");
    }
  }

  Future<void> guardarCita(BuildContext context) async {
    try{
      if (!formKey.currentState!.validate()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        await showDialogCustom(context, "Error", "Sesión no encontrada. Inicia sesión nuevamente.");
        return;
      }

      final fechaTexto = fechaController.text.trim();

      DateTime fecha;
      if (fechaTexto.contains('/')) {
        fecha = DateFormat('yyyy/MM/dd').parse(fechaTexto);
      } else {
        fecha = DateFormat('yyyy-MM-dd').parse(fechaTexto);
      }

      final horaTexto = horaController.text.trim();
      final partes = horaTexto.split(RegExp(r'[:\s]')); // e.g., ["2", "30", "PM"]
      final hora12 = int.parse(partes[0]);
      final minuto = int.parse(partes[1]);
      final periodo = partes[2].toUpperCase();

      int hora24;
      if (periodo == 'PM' && hora12 != 12) {
        hora24 = hora12 + 12;
      } else if (periodo == 'AM' && hora12 == 12) {
        hora24 = 0;
      } else {
        hora24 = hora12;
      }

      //String con formato HH:mm
      final horaFormateada = '${hora24.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

      final cita = {
        "citNomMedico": nombreMedicoController.text.trim(),
        "citFecha": DateFormat('yyyy-MM-dd').format(fecha),
        "citHora": horaFormateada,
        "citDireccion": direccionController.text.trim(),
        "citRecordatorio": recordatorio,
        "espId": especialidadSeleccionada
      };

      final url = Uri.parse("${ApiConfig.baseUrl}/citas/crearCita");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(cita),
      );

      if (response.statusCode == 201) {
        await showDialogCustom(context, "Éxito", "Cita guardada con éxito");
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        await showDialogCustom(context, "Sesión expirada", "Tu sesión ha caducado. Inicia sesión nuevamente.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        await showDialogCustom(context, "Error", "Error al guardar cita: ${response.body}");
      }
    }catch (e) {
      await showDialogCustom(context, "Error inesperado", "Ocurrió un error inesperado: $e");
    }
  }



  /// Diálogo personalizado
  Future<void> showDialogCustom(BuildContext context, String title, String message) async {
    return showDialog(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}