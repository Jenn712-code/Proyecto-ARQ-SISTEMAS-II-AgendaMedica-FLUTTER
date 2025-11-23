import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../controllers/crearMedicamentoModel.dart';
import '../theme/AppTheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../widgets/CustomTextField.dart';

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
        title: Text(
          "Crear Medicamento",
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
                minHeight: constraints.maxHeight, // ocupa toda la altura visible
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: model.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        'Nuevo Medicamento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Campos de texto
                      CustomTextField(
                        controller: model.nombreMedicamentoController,
                        label: 'Nombre',
                        icon: Icons.text_fields,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "El nombre del medicamento es obligatorio";
                          } else if (value.length > 30) {
                            return "El nombre del medicamento es demasiado largo";
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(40),
                        ],
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.dosisController,
                        label: 'Dosis',
                        icon: Icons.medication,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La dosis del medicamento es obligatoria";
                          } else if (value.length > 20) {
                            return "La dosis del medicamento es demasiado larga";
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(25),
                        ],
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.frecuenciaController,
                        label: 'Frecuencia',
                        icon: Icons.repeat,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La frecuencia del tratamiento es obligatoria";
                          }

                          final intValue = int.tryParse(value);
                          if (intValue == null) {
                            return "Ingrese un número válido";
                          } else if (intValue <= 0) {
                            return "Debe ser mayor a 1 hora";
                          } else if (intValue > 24) {
                            return "No puede ser mayor a 24 horas";
                          }
                          return null;
                        },
                        prefixText: 'Cada ',
                        suffixText: ' hora(s)',
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.duracionController,
                        label: 'Duración',
                        icon: Icons.hourglass_bottom,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La duración es obligatoria";
                          }

                          final intValue = int.tryParse(value);
                          if (intValue == null) {
                            return "Ingrese un número válido";
                          } else if (intValue <= 0) {
                            return "Debe ser al menos 1 día";
                          } else if (intValue > 31) {
                            return "No puede exceder un mes";
                          }
                          return null;
                        },
                        suffixText: ' día(s)',
                      ),
                      const SizedBox(height: 20),

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

                      // Campos visibles solo si el recordatorio está activo
                      if (model.recordatorio) ...[
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
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => model.guardarMedicamento(context),
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