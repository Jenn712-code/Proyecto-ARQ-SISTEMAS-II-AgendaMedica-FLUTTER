import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../theme/AppTheme.dart';

class CrearMedicamentoModel {
  final formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController nombreMedicamentoController = TextEditingController();
  final TextEditingController frecuenciaController = TextEditingController();
  final TextEditingController dosisController = TextEditingController();
  final TextEditingController duracionController = TextEditingController();
  bool recordatorio = false;
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  /// Guardar medicamento
  Future<void> guardarMedicamento(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      await showDialogCustom(context, "Error", "Sesión no encontrada. Inicia sesión nuevamente.");
      return;
    }

    try {
      DateTime? fechaHoraCombinada;

      if (recordatorio) {
        final fechaTexto = fechaController.text.trim();
        final horaTexto = horaController.text.trim();

        if (fechaTexto.isEmpty || horaTexto.isEmpty) {
          await showDialogCustom(context, "Error", "Debes seleccionar fecha y hora para el recordatorio.");
          return;
        }

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

        DateTime fecha;
        if (fechaTexto.contains('/')) {
          fecha = DateFormat('yyyy/MM/dd').parse(fechaTexto);
        } else {
          fecha = DateFormat('yyyy-MM-dd').parse(fechaTexto);
        }

        fechaHoraCombinada = DateTime(fecha.year, fecha.month, fecha.day, hora24, minuto);
      }

      final medicamento = {
        "medNombre": nombreMedicamentoController.text.trim(),
        "medFrecuencia": int.parse(frecuenciaController.text),
        "medDosis": dosisController.text.trim(),
        "medDuracion": int.parse(duracionController.text),
        "medFecha": fechaHoraCombinada?.toIso8601String(),
        "medRecordatorio": recordatorio,
        "medEstado": "Pendiente",
      };

      final url = Uri.parse("${ApiConfig.baseUrl}/medicamentos/crearMedicamento");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(medicamento),
      );

      if (response.statusCode == 201) {
        await showDialogCustom(context, "Éxito", "Medicamento guardado con éxito");
        Navigator.pop(context);
      } else {
        await showDialogCustom(context, "Error", "Error al guardar medicamento: ${response.body}");
      }
    } catch (e) {
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