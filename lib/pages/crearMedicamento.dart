import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../controllers/crearMedicamentoModel.dart';
import '../theme/AppTheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class crearMedicamento extends StatefulWidget {
  const crearMedicamento({super.key});


  @override
  State<crearMedicamento> createState() => _CrearMedicamentoState();
}
enum IconAlignment { start, end }

class _CrearMedicamentoState extends State<crearMedicamento> {
  final model = CrearMedicamentoModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Medicamento",
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: model.formKey,
          child: Column(
            children: [
              // Título
              Text(
                'Nuevo Medicamento',
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
                controller: model.nombreMedicamentoController,
                label: 'Nombre',
                icon: Icons.text_fields,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El nombre del medicamento es obligatorio";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Campo dosis
              _buildTextField(
                controller: model.dosisController,
                label: 'Dosis',
                icon: Icons.medication,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La dosis del medicamento no puede estar vacía";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Campo frecuencia
              _buildTextField(
                controller: model.frecuenciaController,
                label: 'Frecuencia',
                icon: Icons.repeat,
                keyboardType: TextInputType.number, // <--- Solo números
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // <-- Solo permite números enteros
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La frecuencia del tratamiento no puede estar vacía";
                  }
                  return null;
                },
                prefixText: 'Cada ',
                suffixText: 'hora(s)', // <--- Texto al final del campo
              ),

              const SizedBox(height: 15),

              // Campo duración
              _buildTextField(
                controller: model.duracionController,
                label: 'Duración',
                icon: Icons.hourglass_bottom,
                keyboardType: TextInputType.number, // <--- Solo números
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // <-- Solo permite números enteros
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La duración del tratamiento no puede estar vacía";
                  }
                  return null;
                },
                suffixText: 'día(s)',
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
                        if (!model.recordatorio) {
                          // Si se desactiva, limpiar los campos
                          model.fechaController.clear();
                          model.horaController.clear();
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.teal,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Mostrar campos solo si el recordatorio está activado
              if (model.recordatorio) ...[
                _buildTextField(
                  controller: model.fechaController,
                  label: 'Fecha',
                  icon: Icons.calendar_today,
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

                _buildTextField(
                  controller: model.horaController,
                  label: 'Hora',
                  icon: Icons.access_time,
                  readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Localizations.override(
                            context: context,
                            locale: const Locale('en'), // mantiene formato AM/PM
                            delegates: const [
                              _CustomEnglishMaterialLocalizationsDelegate(),
                              GlobalWidgetsLocalizations.delegate,
                              GlobalCupertinoLocalizations.delegate,
                            ],
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
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
              ],

              const SizedBox(height: 30),

              // Botón Guardar
              ElevatedButton.icon(
                onPressed: () => model.guardarMedicamento(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(215, 47),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                label: const Text("Guardar Medicamento"),
                icon: const Icon(Icons.check),
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
    IconAlignment iconAlignment = IconAlignment.end,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return FractionallySizedBox(
        widthFactor: 0.80, // 80% del ancho del contenedor
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffixText,
            prefixText: prefixText,
            prefixIcon: iconAlignment == IconAlignment.start
                ? Icon(icon, color: AppTheme.primaryColor)
                : null,
            suffixIcon: iconAlignment == IconAlignment.end
                ? Icon(icon, color: AppTheme.primaryColor)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
    );
  }

  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    DateTime fechaSeleccionada = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
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

                    //Calendario
                    CalendarDatePicker(
                      initialDate: fechaSeleccionada,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      onDateChanged: (newDate) {
                        setState(() {
                          fechaSeleccionada = newDate;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    //Botones personalizados
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop(fechaSeleccionada);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                  ],
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