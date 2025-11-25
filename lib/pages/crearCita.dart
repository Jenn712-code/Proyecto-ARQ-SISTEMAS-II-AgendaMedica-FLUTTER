import 'package:flutter_agenda_medica/controllers/crearCitaModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/widgets/CustomTextField.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/AppTheme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../widgets/CustomDropDown.dart';
import '../widgets/DatePicker.dart';
import '../widgets/TimePicker.dart';


class crearCita extends StatefulWidget {
  const crearCita({super.key});

  @override
  State<crearCita> createState() => _CrearCitaState();
}

class _CrearCitaState extends State<crearCita> {

  final model = crearCitaModel();

  @override
  void initState() {
    super.initState();
    model.cargarEspecialidades(() => setState(() {}));
  }

  @override
  void dispose() {
    model.nombreMedicoController.dispose();
    model.fechaController.dispose();
    model.horaController.dispose();
    model.direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Crear Cita",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // ocupa toda la pantalla
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: model.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // centra verticalmente
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        'Nueva Cita',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontFamily: GoogleFonts
                              .roboto()
                              .fontFamily,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Campo Nombre
                      CustomTextField(
                        controller: model.nombreMedicoController,
                        label: 'Nombre del médico',
                        icon: Icons.person,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "El nombre del médico es obligatorio";
                          } else if (value.length > 30) {
                            return "El nombre del médico es demasiado largo";
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(40),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Campo Fecha
                      CustomTextField(
                        controller: model.fechaController,
                        label: "Fecha",
                        icon: Icons.calendar_today,
                        obscureText: false,
                        readOnly: true,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? "La fecha es obligatoria"
                            : null,
                        onTap: () async {
                          final fecha = await DatePickerUtils
                              .mostrarSelectorFecha(context);
                          if (fecha != null) {
                            model.fechaController.text =
                            "${fecha.year}-${fecha.month.toString().padLeft(
                                2, '0')}-${fecha.day.toString().padLeft(
                                2, '0')}";
                            setState(() {});
                          }
                        },
                      ),

                      const SizedBox(height: 15),

                      // Campo Hora
                      CustomTextField(
                        controller: model.horaController,
                        label: "Hora",
                        icon: Icons.access_time,
                        obscureText: false,
                        readOnly: true,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? "La hora es obligatoria"
                            : null,
                        onTap: () async {
                          final hora =
                          await TimePickerUtils.mostrarSelectorHora(context);
                          if (hora != null) model.horaController.text = hora;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Campo dirección
                      CustomTextField(
                        controller: model.direccionController,
                        label: 'Dirección',
                        icon: Icons.directions,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La dirección es obligatoria";
                          } else if (value.length > 40) {
                            return "La dirección es demasiado larga";
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(45),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Dropdown Especialidad
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: CustomDropdown<int>(
                            label: "Especialidad",
                            value: model.especialidadSeleccionada,
                            items: model.especialidades.map((esp) {
                              return DropdownMenuItem<int>(
                                value: esp["id"],
                                child: Text(
                                  esp["nombre"],
                                  style: AppTheme.subtitleText,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() =>
                                model.especialidadSeleccionada = value),
                            validator: (value) =>
                            value == null
                                ? "Seleccione una especialidad"
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Checkbox Recordatorio
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: CheckboxListTile(
                            title: Text(
                              "¿Desea activar recordatorio?",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            value: model.recordatorio,
                            onChanged: (bool? value) {
                              setState(() {
                                model.recordatorio = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.teal,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Botón Guardar
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => model.guardarCita(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(215, 47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          label: const Text("Guardar"),
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}