import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../pages/Perfil.dart';
import '../widgets/ShowDialogCustom.dart';
import 'DashboardModel.dart';

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
      DialogUtils.showDialogCustom(
        context: context,
        title: "Error",
        message: "Sesión no encontrada. Inicia sesión nuevamente.",
      );
      return;
    }

    try {
      DateTime? fechaHoraCombinada;

      if (recordatorio) {
        final fechaTexto = fechaController.text.trim();
        final horaTexto = horaController.text.trim();

        if (fechaTexto.isEmpty || horaTexto.isEmpty) {
          await DialogUtils.showDialogCustom(
            context: context,
            title: "Error",
            message: "Debe seleccionar fecha y hora para el recordatorio",
          );
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

      // ─────── VERIFICAR CONFIGURACIÓN DE RECORDATORIO ───────
      if (recordatorio) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final cedula = decodedToken['cedula']?.toString() ?? '';

        final configurado = await verificarRecordatorioConfigurado(
          context, "Medicamento", cedula, token,
        );

        if (!configurado) {
          bool deseaConfigurar =
          await mostrarPopupConfiguracionFaltante(context, "Medicamento");

          if (deseaConfigurar) {
            // Redirigir al perfil con el popup de configuración abierto
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Perfil(
                      model: DashboardModel(),
                      abrirConfiguracion: true,
                      volverACrearMedicamento: true,
                      abrirConfigMedicamento: true,
                    ),
              ),
            );
            return; // Detener aquí
          } else {
            // Usuario canceló → no guarda la cita
            return;
          }
        }
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
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Éxito",
          message: "Medicamento guardado con éxito",
        );
        Navigator.pop(context, true);
      } else {
        await DialogUtils.showDialogCustom(
            context: context,
            title: "Error",
            message: "Error al guardar medicamento: ${response.body}",
        );
      }
    } catch (e) {
      await DialogUtils.showDialogCustom(
        context: context,
        title: "Error inesperado",
        message: "Ocurrió un error inesperado: $e",
      );
    }
  }

  Future<bool> verificarRecordatorioConfigurado(BuildContext context,
      String tipoServicio, String cedula, String token) async {
    try {
      final tipoServicioId = tipoServicio == "Medicamento" ? 2 : 1;

      final response = await http.get(
        Uri.parse("${ApiConfig
            .baseUrl}/recordatorios/cargarRecordatorio/$tipoServicioId/$cedula"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        final minutos = data['minutos'] ?? 0;
        return minutos > 0; // Configurado
      } else {
        return false; //No configurado
      }
    } catch (e) {
      print("Error al verificar recordatorio: $e");
      return false;
    }
  }

  Future<bool> mostrarPopupConfiguracionFaltante(BuildContext context, String tipoServicio) async {
    bool confirmado = false;

    await DialogUtils.showDialogConfirm(
      context: context,
      title: "Configuración faltante",
      message: "No hay una configuración de recordatorio para tu $tipoServicio.\n¿Deseas configurarla ahora?",
      confirmText: "Sí",
      cancelText: "Cancelar",
      onConfirm: () {
        confirmado = true;
      },
      onCancel: () {
        confirmado = false;
      },
    );

    return confirmado;
  }
}