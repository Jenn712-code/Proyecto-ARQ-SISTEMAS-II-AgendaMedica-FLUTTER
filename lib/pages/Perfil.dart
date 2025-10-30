import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../controllers/DashboardModel.dart';
import '../theme/AppTheme.dart';
import 'Home.dart';
import 'Notificaciones.dart';
import 'package:flutter/services.dart';

class Perfil extends StatefulWidget {
  final DashboardModel model;
  const Perfil({super.key, required this.model});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  String nombreUsuario = "Cargando...";
  String correoUsuario = "Cargando...";
  String _configMedicamento = "";
  String _configCita = "";
  final Color primaryColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    //_cargarRecordatorio(tipoServicioId, cedulaPaciente);
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      setState(() {
        nombreUsuario = decodedToken['name'] ?? decodedToken['nombre'] ?? 'Usuario';
        correoUsuario = decodedToken['email'] ?? decodedToken['upn'] ?? 'correo@desconocido.com';
      });
    }
  }

  /*Future<void> _cargarRecordatorio(int tipoServicioId, String cedula) async {
    try {
      final response = await http.get(
          Uri.parse("${ApiConfig.baseUrl}/recordatorios/buscar/$tipoServicioId/$cedula"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _daysController.text = data['dias'].toString();
          _hoursController.text = data['horas'].toString();
          _minutesController.text = data['minutos'].toString();

          // Mostrar texto del recordatorio configurado
          _configCita =
          '${data['dias']} días, ${data['horas']} horas, ${data['minutos']} minutos';
        });

      } else if (response.statusCode == 404) {
        // No hay recordatorio configurado
        setState(() {
          _daysController.clear();
          _hoursController.clear();
          _minutesController.clear();
          _configCita = "No Configurado";
        });
      } else {
        throw Exception('Error al obtener el recordatorio: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _configCita = "No Configurado";
      });
      print("Error: $e");
    }
  }*/


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
            onPressed: () => Navigator.pop(ctx),
            child: Text("OK", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  FutureOr<bool> guardarRecordatorio(BuildContext context, {
    required int dias,
    required int horas,
    required int minutos,
    required int tipoServicioId,
  }) async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        await showDialogCustom(context, "Error", "Sesión no encontrada. Inicia sesión nuevamente.");
        return false;
      }

      //Conversión
      final int totalMinutos = (dias * 24 * 60) + (horas * 60) + minutos;

      final recordatorio = {
        "tipoServicio": tipoServicioId,
        "recAnticipacion": totalMinutos,
        "recUnidadTiempo": "minutos" //siempre se envía "minutos"
      };

      final url = Uri.parse("${ApiConfig.baseUrl}/recordatorios/configurarRecordatorio");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(recordatorio),
      );

      if (response.statusCode == 201) {
        await showDialogCustom(context, "Éxito", "Recordatorio guardado con éxito");
        return true;
      } else if (response.statusCode == 401) {
        await showDialogCustom(context, "Sesión expirada", "Tu sesión ha caducado. Inicia sesión nuevamente.");
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return false;
      } else {
        await showDialogCustom(context, "Error", "Error al guardar recordatorio: ${response.body}");
        return false;
      }
    } catch (e) {
      await showDialogCustom(context, "Error inesperado", "Ocurrió un error inesperado: $e");
      return false;
    }
  }

  Widget _buildUserInfo(String nombre, String correo) {
    return Column(
      children: [
        const Icon(
          Icons.account_circle,
          size: 80,
          color: Colors.grey,
        ),
        const SizedBox(height: 10),
        Text(
          nombre,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          correo,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Contenido del Perfil ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  _buildUserInfo(nombreUsuario, correoUsuario),

                  // --- EXPANSION TILE ANIDADO: CONFIGURACIONES -> RECORDATORIOS ---
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ExpansionTile(
                      title: const Text(
                        "Configuraciones",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      leading: Icon(Icons.settings, color: primaryColor),
                      initiallyExpanded: false,

                      children: <Widget>[
                        // ---- RECORDATORIOS ----
                        ExpansionTile(
                          title: const Text("Recordatorios"),
                          leading: const Icon(Icons.notifications_active, color: Colors.blueAccent),
                          initiallyExpanded: false,

                          children: [
                            // Citas
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 40, right: 16),
                              leading: const Icon(Icons.calendar_today, size: 20, color: Colors.green),
                              title: const Text("Citas"),
                              trailing: Text(
                                _configCita.isEmpty ? "No configurado" : _configCita,
                                style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14),
                              ),
                              onTap: () async {
                                final result = await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const ReminderConfigDialog(
                                      title: "Recordatorio de Citas",
                                      tipo: 'Cita',
                                    );
                                  },
                                );

                                //Si el usuario presionó "Aceptar"
                                if (result != null) {
                                  final dias = result['dias'] ?? 0;
                                  final horas = result['horas'] ?? 0;
                                  final minutos = result['minutos'] ?? 0;
                                  final tipoServicioId = result['tipoServicioId'] ?? 2;

                                  bool success = await guardarRecordatorio(
                                    context,
                                    dias: dias,
                                    horas: horas,
                                    minutos: minutos,
                                    tipoServicioId: tipoServicioId,
                                  );

                                  if (success) {
                                    setState(() {
                                      String texto = "";
                                      if (dias > 0) texto += "$dias d ";
                                      if (horas > 0) texto += "$horas h ";
                                      if (minutos > 0) texto += "$minutos min";
                                      _configCita = texto.trim().isEmpty ? "No configurado" : texto.trim();
                                    });
                                  } else {
                                    setState(() {
                                      _configCita = "No configurado";
                                    });
                                  }
                                }
                              },
                            ),

                            // Medicamentos
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 40, right: 16),
                              leading: const Icon(Icons.medical_services, size: 20, color: Colors.red),
                              title: const Text("Medicamentos"),
                              trailing: Text(
                                _configMedicamento.isEmpty ? "No configurado" : _configMedicamento,
                                style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14),
                              ),
                              onTap: () async {
                                final result = await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const ReminderConfigDialog(
                                      title: "Recordatorio de Medicamentos",
                                      tipo: 'Medicamento',
                                    );
                                  },
                                );

                                if (result != null) {
                                  final dias = result['dias'] ?? 0;
                                  final horas = result['horas'] ?? 0;
                                  final minutos = result['minutos'] ?? 0;
                                  final tipoServicioId = result['tipoServicioId'] ?? 2;

                                  bool success = await guardarRecordatorio(
                                    context,
                                    dias: dias,
                                    horas: horas,
                                    minutos: minutos,
                                    tipoServicioId: tipoServicioId,
                                  );

                                  if (success) {
                                    setState(() {
                                      String texto = "";
                                      if (dias > 0) texto += "$dias d ";
                                      if (horas > 0) texto += "$horas h ";
                                      if (minutos > 0) texto += "$minutos min";
                                      _configMedicamento = texto.trim().isEmpty ? "No configurado" : texto.trim();
                                    });
                                  } else {
                                    setState(() {
                                      _configMedicamento = "No configurado";
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),

                        const Divider(height: 1, indent: 70, endIndent: 20),

                        // ---- NOTIFICACIONES ----
                        ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.blueGrey),
                          title: const Text("Notificaciones"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Notificaciones()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // --- Botón de Cerrar Sesión ---
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.model.showLogoutDialog(context, () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text(
                      "Cerrar sesión",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// WIDGET DEL POP-UP: TEMPORIZADOR (ReminderConfigDialog)
// =======================================================

class ReminderConfigDialog extends StatefulWidget {
  final String title;
  final String tipo;
  const ReminderConfigDialog({super.key, required this.title, required this.tipo  });

  @override
  State<ReminderConfigDialog> createState() => _ReminderConfigDialogState();
}

class _ReminderConfigDialogState extends State<ReminderConfigDialog> {
  // Variables para manejar la configuración del temporizador
  int _days = 0,
      _hours = 0,
      _minutes = 0;

  // Controladores de texto
  final TextEditingController _daysController = TextEditingController(text: '');
  final TextEditingController _hoursController = TextEditingController(text: '');
  final TextEditingController _minutesController = TextEditingController(text: '');

  // Variables de estado para el mensaje de error de cada campo
  String? _daysError, _hoursError, _minutesError;
  int? tipoServicioId;

  // Mapa de límites estrictos
  final Map<String, int> _limits = {
    'Días': 3, // Máximo 3 días
    'Horas': 23, // Máximo 23 horas
    'Minutos': 30, // Máximo 30 minutos
  };

  // Límites de dígitos por campo
  final Map<String, int> _maxDigits = {
    'Días': 1,
    'Horas': 2,
    'Minutos': 2,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // Método de validación de un campo individual
  String? _validateValue(String fieldName, String value) {
    if (value.isEmpty) return null;

    int? numericValue = int.tryParse(value);
    int max = _limits[fieldName]!;

    if (numericValue == null || numericValue < 0) {
      return 'Valor inválido.';
    }
    if (numericValue > max) {
      return 'Máx: $max';
    }
    return null;
  }

  String? _generalError;

  // Método de validación de todos los campos al presionar Aceptar
  bool _validateFields() {
    setState(() {
      // Limpia errores previos
      _daysError = null;
      _hoursError = null;
      _minutesError = null;
      _generalError = null;

      if (widget.tipo == "Cita") {
        // Obtiene los valores de los controladores y elimina espacios
        String d = _daysController.text.trim();
        String h = _hoursController.text.trim();
        String m = _minutesController.text.trim();

        // 🔹 Si todos están vacíos o en "0" → error general
        if ((d.isEmpty || d == "0") &&
            (h.isEmpty || h == "0") &&
            (m.isEmpty || m == "0")) {
          _generalError =
          "Por favor llena al menos un campo con un valor válido";
          return;
        }

        // 🔹 Valida solo los que tienen texto distinto de vacío y distinto de 0
        if (d.isNotEmpty && d != "0") {
          _daysError = _validateValue('Días', d);
        }
        if (h.isNotEmpty && h != "0") {
          _hoursError = _validateValue('Horas', h);
        }
        if (m.isNotEmpty && m != "0") {
          _minutesError = _validateValue('Minutos', m);
        }

      } else if (widget.tipo == "Medicamento") {
        String m = _minutesController.text.trim();

        // 🔹 Si está vacío o es "0" → error general
        if (m.isEmpty || m == "0") {
          _generalError =
          "Por favor ingresa un valor mayor que 0 en minutos.";
          return;
        }

        // 🔹 Si tiene valor, lo valida normalmente
        _minutesError = _validateValue('Minutos', m);
      }
    });

    // Retorna true solo si no hay errores
    return _generalError == null &&
        _daysError == null &&
        _hoursError == null &&
        _minutesError == null;
  }

  // Widget para construir un campo de entrada (Días, Horas, Minutos)
  Widget _buildTimeField(String label, TextEditingController controller,
    String? errorText, Function(int) onChanged) {
    int maxDigits = _maxDigits[label]!;

    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.primaryColor)),
        SizedBox(
          width: 70,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 4.0),
              errorText: errorText, // Solo muestra error si se excede
            ),
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(maxDigits),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isEmpty) {
                onChanged(0);
                return;
              }
              int? numericValue = int.tryParse(value);
              if (numericValue != null) {
                onChanged(numericValue);
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: AppTheme.snapStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.tipo == "Cita") ...[
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeField("Días", _daysController, _daysError, (val) => _days = val),
                  _buildTimeField("Horas", _hoursController, _hoursError, (val) => _hours = val),
                  _buildTimeField("Minutos", _minutesController, _minutesError, (val) => _minutes = val),
                ],
              ),

              if (_generalError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _generalError!,
                    style: GoogleFonts.roboto(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 25),
              Text(
                'Recordatorio: '
                    '${_daysController.text.isEmpty ? 0 : _days} días, '
                    '${_hoursController.text.isEmpty ? 0 : _hours} horas, '
                    '${_minutesController.text.isEmpty
                    ? 0
                    : _minutes} minutos',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ] else
              if (widget.tipo == "Medicamento") ...[
                _buildTimeField('Minutos', _minutesController, _minutesError, (v) =>
                _minutes = v),

                if (_generalError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _generalError!,
                      style: GoogleFonts.roboto(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 25),
                Text(
                  'Recordatorio: ${_minutesController.text.isEmpty
                      ? 0
                      : _minutes} minutos',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  bool isValid = false;

                  if (widget.tipo == "Cita") {
                    // Valida los tres campos
                    isValid = _validateFields();
                  } else if (widget.tipo == "Medicamento") {
                    // 🔹 Valida que el campo de minutos tenga valor
                    setState(() {
                      String minutosTexto = _minutesController.text.trim();

                      if (minutosTexto.isEmpty || minutosTexto == "0") {
                        _generalError = "Por favor ingresa un número válido";
                        _minutesError = null;
                        isValid = false;
                      } else {
                        _generalError = null;
                        _minutesError = _validateValue('Minutos', minutosTexto);
                        isValid = _minutesError == null;
                      }
                    });
                  }

                  if (isValid) {
                    // Cierra el diálogo y retorna los valores
                    Navigator.of(context).pop({
                      'dias': _daysController.text.isEmpty ? 0 : int.parse(_daysController.text),
                      'horas': _hoursController.text.isEmpty ? 0 : int.parse(_hoursController.text),
                      'minutos': _minutesController.text.isEmpty ? 0 : int.parse(_minutesController.text),
                      'tipoServicioId': widget.tipo == "Cita" ? 1 : 2,
                    });
                  }
                },
                child: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
