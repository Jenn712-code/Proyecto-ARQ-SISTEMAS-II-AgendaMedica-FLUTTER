import 'package:flutter_agenda_medica/controllers/crearCitaModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/widgets/CustomTextField.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/AppTheme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


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
                    mainAxisAlignment: MainAxisAlignment.center, // centra verticalmente
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
                          fontFamily: GoogleFonts.roboto().fontFamily,
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
                        label: 'Fecha',
                        icon: Icons.calendar_today,
                        obscureText: false,
                        readOnly: true,
                        onTap: () => _mostrarSelectorFecha(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La fecha es obligatoria";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Campo Hora
                      CustomTextField(
                        controller: model.horaController,
                        label: 'Hora',
                        icon: Icons.access_time,
                        obscureText: false,
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Localizations.override(
                                context: context,
                                locale: const Locale('en'),
                                delegates: const [
                                  _CustomEnglishMaterialLocalizationsDelegate(),
                                  GlobalWidgetsLocalizations.delegate,
                                  GlobalCupertinoLocalizations.delegate,
                                ],
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    alwaysUse24HourFormat: false,
                                  ),
                                  child: child!,
                                ),
                              );
                            },
                          );

                          if (pickedTime != null) {
                            final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
                            final minute = pickedTime.minute.toString().padLeft(2, '0');
                            final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
                            model.horaController.text = "$hour:$minute $period";
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La hora es obligatoria";
                          }
                          return null;
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
                          child: DropdownButtonFormField2<int>(
                            decoration: const InputDecoration(labelText: "Especialidad"),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              iconSize: 28,
                            ),
                            isExpanded: true,
                            value: model.especialidadSeleccionada,
                            // Estilo del menú desplegable
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor, // Fondo del menú desplegable
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.secondaryColor),
                              ),
                            ),

                            // Estilo de los ítems del menú
                            menuItemStyleData: const MenuItemStyleData(
                              overlayColor: WidgetStatePropertyAll(AppTheme.secondaryColor), // Color al pasar el dedo
                            ),
                            items: model.especialidades.map((esp) {
                              return DropdownMenuItem<int>(
                                value: esp["id"],
                                child: Text(
                                  esp["nombre"],
                                  style: AppTheme.subtitleText,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                model.especialidadSeleccionada = value;
                              });
                            },
                            validator: (value) =>
                            value == null ? "Seleccione una especialidad" : null,
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

  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    DateTime fechaSeleccionada = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Aseguramos que el contenido no desborde
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Seleccionar fecha",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Calendario adaptable
                      CalendarDatePicker(
                        initialDate: fechaSeleccionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        onDateChanged: (newDate) {
                          fechaSeleccionada = newDate;
                        },
                      ),

                    const SizedBox(height: 8),

                    // Botones personalizados
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(ctx).pop(fechaSeleccionada);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text("Aceptar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((fechaSeleccionadaFinal) {
      if (fechaSeleccionadaFinal != null) {
        model.fechaController.text =
            model.fechaController.text =
        "${fechaSeleccionadaFinal.year.toString().padLeft(4,'0')}/${fechaSeleccionadaFinal.month.toString().padLeft(2,'0')}/${fechaSeleccionadaFinal.day.toString().padLeft(2,'0')}";
        setState(() {}); // Refrescar UI
      }
    });
  }
}

// ------------------------
// 1) Localizations personalizadas
// ------------------------
class CustomEnglishMaterialLocalizations extends DefaultMaterialLocalizations {
  // título del diálogo
  @override
  String get timePickerDialHelpText => 'Seleccionar con reloj';

  @override
  String get dialModeButtonLabel => 'Modo reloj';

  // texto del botón OK / aceptar
  @override
  String get okButtonLabel => 'Aceptar';

  // texto del botón cancelar
  @override
  String get cancelButtonLabel => 'Cancelar';

  // tooltip / label para cambiar a entrada por texto
  @override
  String get inputTimeModeButtonLabel => 'Introducir hora';

  // texto usado en la cabecera cuando se está en modo input (teclado)
  @override
  String get timePickerInputHelpText => 'Introduzca la hora';

  // mensaje de error cuando la hora ingresada no es válida (Input mode)
  @override
  String get invalidTimeLabel => 'Introduce una hora válida';

  // abreviaciones AM/PM si quieres mostrarlas en español
  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get timePickerHourLabel => 'Hora';

  @override
  String get timePickerMinuteLabel => 'Minutos';
}

// ------------------------
// 2) Delegado para cargar la localización personalizada
// ------------------------
class _CustomEnglishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CustomEnglishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return Future.value(CustomEnglishMaterialLocalizations());
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}