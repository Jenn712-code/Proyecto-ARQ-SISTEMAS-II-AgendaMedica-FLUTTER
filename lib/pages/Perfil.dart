import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/DashboardModel.dart';
import 'Home.dart';

// =======================================================
// WIDGET PRINCIPAL: PERFIL
// =======================================================

class Perfil extends StatelessWidget {
  final DashboardModel model;

  const Perfil({super.key, required this.model});

  // Widget auxiliar para recrear el título estilizado (color y tipografía)
  Widget _buildStyledTitle(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.getFont(
        'Pacifico',
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Widget auxiliar para la información del usuario
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
    const String nombreUsuario = "Ana Ramirez";
    const String correoUsuario = "ana@correo.com";
    final Color primaryColor = Colors.teal.shade400; // El color turquesa

    return Scaffold(
      /*appBar: AppBar(
        title: const SizedBox.shrink(), // Ocultar el título estándar
        backgroundColor: primaryColor,
      ),*/
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Barra Superior con Título Estilizado Único ---
            /*Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              color: primaryColor,
              child: Center(
                child: _buildStyledTitle("Perfil", Colors.white),
              ),
            ),*/

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
                      // TÍTULO PRINCIPAL: CONFIGURACIONES
                      title: const Text(
                        "Configuraciones",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      leading: Icon(Icons.settings, color: primaryColor),
                      initiallyExpanded: false,

                      children: <Widget>[
                        // --- 1. RECORDATORIOS (SEGUNDO EXPANSION TILE) ---
                        ExpansionTile(
                          title: const Text("Recordatorios"),
                          leading: const Icon(Icons.notifications, color: Colors.blueAccent),
                          initiallyExpanded: false,

                          children: [
                            // ITEM: Citas (Abre Pop-up con temporizador)
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 40, right: 16),
                              leading: const Icon(Icons.calendar_today, size: 20, color: Colors.green),
                              title: const Text("Citas"),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const ReminderConfigDialog(
                                      title: "Configuración de Recordatorio de Citas",
                                    );
                                  },
                                );
                              },
                            ),
                            // ITEM: Medicamentos (Abre Pop-up con temporizador)
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 40, right: 16),
                              leading: const Icon(Icons.medical_services, size: 20, color: Colors.red),
                              title: const Text("Medicamentos"),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const ReminderConfigDialog(
                                      title: "Configuración de Recordatorio de Medicamentos",
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // --- Botón de Cerrar Sesión ---
                  ElevatedButton.icon(
                    onPressed: () {
                      model.showLogoutDialog(context, () {
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
  const ReminderConfigDialog({super.key, required this.title});

  @override
  State<ReminderConfigDialog> createState() => _ReminderConfigDialogState();
}

class _ReminderConfigDialogState extends State<ReminderConfigDialog> {
  // Variables para manejar la configuración del temporizador
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;

  // Controladores de texto
  final TextEditingController _daysController = TextEditingController(text: '0');
  final TextEditingController _hoursController = TextEditingController(text: '0');
  final TextEditingController _minutesController = TextEditingController(text: '0');

  // Variables de estado para el mensaje de error de cada campo
  String? _daysError;
  String? _hoursError;
  String? _minutesError;

  // Mapa de límites estrictos
  final Map<String, int> _limits = {
    'Días': 3,    // Máximo 3 días
    'Horas': 23,  // Máximo 23 horas
    'Minutos': 30, // Máximo 30 minutos
  };

  @override
  void initState() {
    super.initState();
    _daysController.text = _days.toString();
    _hoursController.text = _hours.toString();
    _minutesController.text = _minutes.toString();
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

  // Método de validación de todos los campos al presionar Aceptar
  bool _validateFields() {
    bool isValid = true;
    setState(() {
      _daysError = _validateValue('Días', _daysController.text);
      _hoursError = _validateValue('Horas', _hoursController.text);
      _minutesError = _validateValue('Minutos', _minutesController.text);

      if (_daysError != null || _hoursError != null || _minutesError != null) {
        isValid = false;
      }
    });
    return isValid;
  }

  // Widget para construir un campo de entrada (Días, Horas, Minutos)
  Widget _buildTimeField(String label, TextEditingController controller, String? errorText, Function(int) onChanged) {
    int max = _limits[label]!;

    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(
          width: 70, // Espacio para el error
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              errorText: errorText, // Muestra el mensaje de error
            ),
            // Restringe la entrada solo a dígitos
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              int? numericValue = int.tryParse(value);
              // Si el valor es válido y está dentro del rango estricto, actualiza el estado local
              if (numericValue != null && numericValue >= 0 && numericValue <= max) {
                onChanged(numericValue);
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
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Configurar el recordatorio con anticipación:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeField("Días", _daysController, _daysError, (val) => setState(() => _days = val)),
                _buildTimeField("Horas", _hoursController, _hoursError, (val) => setState(() => _hours = val)),
                _buildTimeField("Minutos", _minutesController, _minutesError, (val) => setState(() => _minutes = val)),
              ],
            ),
            const SizedBox(height: 15),
            Text('Configuración: $_days días, $_hours horas, $_minutes minutos.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text('Aceptar'),
          onPressed: () {
            // Llama a la validación antes de cerrar
            if (_validateFields()) {
              print("Configuración ACEPTADA para ${widget.title}: ${_daysController.text} días, ${_hoursController.text} horas, ${_minutesController.text} minutos");
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}