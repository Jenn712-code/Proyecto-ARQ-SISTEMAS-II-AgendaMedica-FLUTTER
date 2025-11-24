import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../widgets/ShowDialogCustom.dart';

class crearPacienteModel {
  final formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController fechaNacimientoController = TextEditingController();
  final TextEditingController epsController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  bool passwordVisible = false;
  String? epsSeleccionada;

  Future<void> guardarPaciente(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) return;

      // Convertir fecha
      final fechaTexto = fechaNacimientoController.text.trim();

      DateTime fecha;
      if (fechaTexto.contains('/')) {
        fecha = DateFormat('yyyy/MM/dd').parse(fechaTexto);
      } else {
        fecha = DateFormat('yyyy-MM-dd').parse(fechaTexto);
      }

      final data = {
        "pacCedula": int.parse(cedulaController.text.trim()),
        "pacNombre": nombreController.text.trim(),
        "pacFecNacimiento": DateFormat('yyyy-MM-dd').format(fecha),
        "pacEPS": epsController.text.trim(),
        "pacCelular": celularController.text.trim(),
        "pacCorreo": correoController.text.trim(),
        "pacContrasena": contrasenaController.text.trim(),
      };

      final url = Uri.parse("${ApiConfig.baseUrl}/pacientes/crear");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Éxito",
          message: "Paciente registrado con éxito.",
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 400) {
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Validación",
          message: response.body,
        );
      } else {
        await DialogUtils.showDialogCustom(
          context: context,
          title: "Error",
          message: "No se pudo guardar el paciente: ${response.body}",
        );
      }
    } catch (e) {
      DialogUtils.showDialogCustom(
        context: context,
        title: "Error inesperado",
        message: e.toString(),
      );
    }
  }
}