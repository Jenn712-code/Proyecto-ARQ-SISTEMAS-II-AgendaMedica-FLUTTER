import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/controllers/DashboardModel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../pages/Home.dart';
import '../pages/Perfil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../widgets/ShowDialogCustom.dart';

class crearCitaModel {
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
    try {
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

      // ─────── VERIFICAR CONFIGURACIÓN DE RECORDATORIO ───────
      if (recordatorio) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final cedula = decodedToken['cedula']?.toString() ?? '';

        final configurado = await verificarRecordatorioConfigurado(
          context, "Cita", cedula, token,
        );

        if (!configurado) {
          bool deseaConfigurar =
          await mostrarPopupConfiguracionFaltante(context, "Cita");

          if (deseaConfigurar) {
            // Redirigir al perfil con el popup de configuración abierto
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Perfil(
                      model: DashboardModel(),
                      abrirConfiguracion: true,
                      volverACrearCita: true,
                      abrirConfigCita: true,
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
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Éxito",
          message: "Cita guardada con éxito.",
        );
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Sesión expirada",
          message: "Tu sesión ha caducado. Inicia sesión nuevamente.",
        );
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Error",
          message: "Error al guardar cita: ${response.body}",
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

  Future<bool> verificarRecordatorioConfigurado(BuildContext context, String tipoServicio,
      String cedula, String token) async {
    try {
      final tipoServicioId = tipoServicio == "Cita" ? 1 : 2;

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