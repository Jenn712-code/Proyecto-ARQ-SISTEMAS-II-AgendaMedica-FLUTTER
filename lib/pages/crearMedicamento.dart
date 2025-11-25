import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../controllers/crearMedicamentoModel.dart';
import '../theme/AppTheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../widgets/CustomTextField.dart';
import '../widgets/DatePicker.dart';
import '../widgets/TimePicker.dart';

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
}