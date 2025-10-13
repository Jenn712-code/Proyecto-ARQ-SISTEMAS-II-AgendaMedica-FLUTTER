import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class crearCita extends StatefulWidget {
  const crearCita({super.key});

  @override
  State<crearCita> createState() => _CrearCitaState();
}

class _CrearCitaState extends State<crearCita> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _nombreMedicoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  bool _recordatorio = false; // valor por defecto
  List<Map<String, dynamic>> _especialidades = [];
  int? _especialidadSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarEspecialidades();
  }

  Future<void> _cargarEspecialidades() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/especialidades/listarEspecialidades");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        _especialidades = data.map((e) => {
          "id": e["id"],
          "nombre": e["nombre"]
        }).toList();
      });
    } else {
      throw Exception("Error al cargar especialidades");
    }
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;

    /*final pacienteId = await _obtenerPacienteId();

    if (pacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró la sesión del paciente")),
      );
      return;
    }*/

    final cita = {
      "citNomMedico": _nombreMedicoController,
      "citFecha": _fechaController.text,
      "citHora": _horaController.text,
      "citDireccion": _direccionController,
      "citRecordatorio": _recordatorio,
      //"pacCedula": pacCedula,
      "espId": _especialidadSeleccionada
    };

    final url = Uri.parse("${ApiConfig.baseUrl}/citas/crearCita");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(cita),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita guardada con éxito")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar cita: ${response.body}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cita"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Título
              Text(
                'Nueva Cita',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                ),
              ),

              const SizedBox(height: 30),

              // Campo Nombre
              _buildTextField(
                controller: _nombreMedicoController,
                label: 'Nombre del medico',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El nombre del médico es obligatorio";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Campo Fecha
              _buildTextField(
                controller: _fechaController,
                label: 'Fecha (DD/MM/AAAA)',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _fechaController.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La fecha es obligatoria";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Campo Hora
              _buildTextField(
                controller: _horaController,
                label: 'Hora',
                icon: Icons.access_time,
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _horaController.text =
                    "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La hora es obligatoria";
                  }
                  return null;
                },
              ),

              // Campo dirección
              _buildTextField(
                controller: _direccionController,
                label: 'Correo',
                icon: Icons.directions,
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return "La dirección no puede estar vacía";
                  }
                  return null;
                },
              ),

              // Dropdown especialidad
              DropdownButtonFormField<int>(
                value: _especialidadSeleccionada,
                decoration: const InputDecoration(labelText: "Especialidad"),
                items: _especialidades
                    .map((e) => DropdownMenuItem<int>(
                  value: e["id"],
                  child: Text(e["nombre"]),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _especialidadSeleccionada = value;
                  });
                },
                validator: (value) =>
                value == null ? "Seleccione una especialidad" : null,
              ),
              const SizedBox(height: 10),

              CheckboxListTile(
                title: const Text("¿Desea activar recordatorio?"),
                value: _recordatorio,
                onChanged: (bool? value) {
                  setState(() {
                    _recordatorio = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // checkbox a la izquierda
              ),


              const SizedBox(height: 30),

              // Botón Guardar
              ElevatedButton.icon(
                onPressed: _guardarCita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(215, 47),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text("Guardar Cita"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método reutilizable para crear campos
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

