import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/controllers/listarMedicamentos.dart';
import 'package:flutter_agenda_medica/services/listarMedicamentosService.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/AppTheme.dart';
import 'CustomCard.dart';
import 'CustomDropDown.dart';
import 'CustomTextField.dart';
import 'DatePicker.dart';
import 'ShowDialogCustom.dart';
import 'package:flutter/services.dart';
import 'TimePicker.dart';

class MedicamentoCard extends StatefulWidget {
  final Medicamento medicamento;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;
  final Color colorFondo;

  const MedicamentoCard({
    super.key,
    required this.medicamento,
    this.onDelete,
    this.onUpdate,
    required this.colorFondo,
  });

  @override
  State<MedicamentoCard> createState() => _MedicamentoCardState();
}

class _MedicamentoCardState extends State<MedicamentoCard> {
  bool mostrarAcciones = false;

  String formatearFechaHora(String fechaHoraIso) {
    try {
      final dateTime = DateTime.parse(fechaHoraIso);

      final base = DateFormat("EEE d MMM yyyy - hh:mm", 'es_ES').format(
          dateTime);
      final ampm = DateFormat("a", 'en_US').format(dateTime).toUpperCase();

      return "$base $ampm";
    } catch (_) {
      return fechaHoraIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicamento = widget.medicamento;

    return GestureDetector(
      onTap: () => setState(() => mostrarAcciones = !mostrarAcciones),
      child: CustomCard(
        colorBorde: widget.colorFondo,
        icono: Icons.medical_services,
        titulo: medicamento.nombre,
        bordeIzquierdo: 6,

        contenido: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// --- INFORMACIÓN DEL MEDICAMENTO (Flexible, no Expanded) ---
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${medicamento.dosis} - Cada ${medicamento.frecuencia} hora(s)'),
                  const SizedBox(height: 4),
                  Text('Por ${medicamento.duracion} día(s)'),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                          Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        formatearFechaHora(medicamento.fecha),
                        style: TextStyle(color: widget.colorFondo),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// --- BOTONES AL MISMO NIVEL ---
            AnimatedOpacity(
              opacity: mostrarAcciones ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Visibility(
                visible: mostrarAcciones,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                      tooltip: "Editar medicamiento",
                      onPressed: () async {
                        mostrarPopupEditar(context, medicamento, () {
                          setState(() {});
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Eliminar medicamento",
                      onPressed: () {
                        DialogUtils.showDialogConfirm(
                          context: context,
                          title: "Confirmar",
                          message: "¿Desea eliminar este medicamento?",
                          onConfirm: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');
                            final ok =
                            await MedicamentosService.eliminarMedicamento(medicamento.id, token!);

                            if (ok) {
                              widget.onDelete?.call(); // si existe, se ejecuta
                              await Future.delayed(
                                  const Duration(milliseconds: 200));

                              if (mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // POPUP DE EDITAR MEDICAMENTO
  // ==============================
  void mostrarPopupEditar(BuildContext parentContext, Medicamento medicamento, Function onUpdated) async {
    final TextEditingController nombreCtrl = TextEditingController(text: medicamento.nombre ?? '');
    final TextEditingController dosisCtrl = TextEditingController(text: medicamento.dosis ?? '');
    final TextEditingController frecuenciaCtrl = TextEditingController(text: medicamento.frecuencia.toString() ?? '');
    final TextEditingController duracionCtrl = TextEditingController(text: medicamento.duracion.toString() ?? '');
    final TextEditingController fechaCtrl = TextEditingController();
    final TextEditingController horaCtrl = TextEditingController();
    String estadoSeleccionado = medicamento.estado ?? "Pendiente";

    final _formKey = GlobalKey<FormState>();

    int? obtenerCedulaDesdeToken(String token) {
      try {
        final parts = token.split('.');
        if (parts.length != 3) return null;

        final payload = parts[1];
        // Decodificar Base64URL
        var normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payloadMap = jsonDecode(decoded);

        // Retorna la cédula como int
        return payloadMap['cedula'];
      } catch (e) {
        print("Error al decodificar token: $e");
        return null;
      }
    }

    // -----------------------------
    // Parsear fecha del backend si existe
    // -----------------------------
    DateTime? fechaHoraCombinada;
    if (medicamento.recordatorio && medicamento.fecha.isNotEmpty) {
      final fechaHora = DateTime.tryParse(medicamento.fecha);
      if (fechaHora != null) {
        fechaHoraCombinada = fechaHora;

        // Fecha para fechaCtrl
        fechaCtrl.text =
        "${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')}";

        // Hora para horaCtrl en formato hh:mm AM/PM
        final hour = fechaHora.hour;
        final minute = fechaHora.minute.toString().padLeft(2, '0');
        final periodo = hour >= 12 ? "PM" : "AM";
        final hour12 = hour % 12 == 0 ? 12 : hour % 12;
        horaCtrl.text = "$hour12:$minute $periodo";
      }
    }

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "Editar Medicamento",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.80,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // NOMBRE
                        CustomTextField(
                          controller: nombreCtrl,
                          label: 'Nombre',
                          icon: Icons.text_fields,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "El nombre del medicamento es obligatorio";
                            if (value.length > 30)
                              return "El nombre es demasiado largo";
                            return null;
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40)
                          ],
                        ),
                        const SizedBox(height: 15),

                        // DOSIS
                        CustomTextField(
                          controller: dosisCtrl,
                          label: 'Dosis',
                          icon: Icons.medication,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "La dosis del medicamento es obligatoria";
                            if (value.length > 20)
                              return "La dosis es demasiado larga";
                            return null;
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(25)
                          ],
                        ),
                        const SizedBox(height: 15),

                        // FRECUENCIA
                        CustomTextField(
                          controller: frecuenciaCtrl,
                          label: 'Frecuencia',
                          icon: Icons.repeat,
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "La frecuencia del tratamiento es obligatoria";
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue <= 0 ||
                                intValue > 24)
                              return "Ingrese un número válido entre 1 y 24";
                            return null;
                          },
                          prefixText: 'Cada ',
                          suffixText: ' hora(s)',
                        ),
                        const SizedBox(height: 15),

                        // DURACIÓN
                        CustomTextField(
                          controller: duracionCtrl,
                          label: 'Duración',
                          icon: Icons.hourglass_bottom,
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "La duración es obligatoria";
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue <= 0 ||
                                intValue > 31)
                              return "Ingrese un número válido entre 1 y 31 días";
                            return null;
                          },
                          suffixText: ' día(s)',
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 15),

                        // ESTADO
                        Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            child:CustomDropdown<String>(
                              label: "Estado",
                              value: estadoSeleccionado,
                              items: const [
                                DropdownMenuItem(
                                    value: "Pendiente", child: Text("Pendiente")),
                                DropdownMenuItem(
                                    value: "Consumido", child: Text("Consumido")),
                                DropdownMenuItem(
                                    value: "No consumido",
                                    child: Text("No consumido")),
                              ],
                              onChanged: (v) =>
                                  setState(() => estadoSeleccionado = v!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // RECORDATORIO
                        Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            child: CheckboxListTile(
                              title: Text(
                                "¿Desea activar recordatorio?",
                                style: AppTheme.subtitleText,
                              ),
                              value: medicamento.recordatorio,
                              onChanged: (bool? value) {
                                setState(() {
                                  medicamento.recordatorio = value ?? false;
                                  if (!medicamento.recordatorio) {
                                    fechaCtrl.clear();
                                    horaCtrl.clear();
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading,
                              activeColor: Colors.teal,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        if (medicamento.recordatorio) ...[
                          // FECHA
                          CustomTextField(
                            controller: fechaCtrl,
                            label: "Fecha",
                            icon: Icons.calendar_today,
                            readOnly: true,
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? "La fecha es obligatoria"
                                : null,
                            onTap: () async {
                              final fecha = await DatePickerUtils
                                  .mostrarSelectorFecha(context);
                              if (fecha != null) fechaCtrl.text =
                              "${fecha.year}-${fecha.month.toString().padLeft(
                                  2, '0')}-${fecha.day.toString().padLeft(
                                  2, '0')}";
                            },
                            obscureText: false,
                          ),
                          const SizedBox(height: 15),

                          // HORA
                          CustomTextField(
                            controller: horaCtrl,
                            label: "Hora",
                            icon: Icons.access_time,
                            readOnly: true,
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? "La hora es obligatoria"
                                : null,
                            onTap: () async {
                              final hora = await TimePickerUtils
                                  .mostrarSelectorHora(context);
                              if (hora != null) horaCtrl.text = hora;
                            },
                            obscureText: false,
                          ),
                        ],

                        const SizedBox(height: 15),

                        // ACCIONES
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;

                                  final prefs = await SharedPreferences.getInstance();
                                  final token = prefs.getString("token") ?? "";
                                  if (token.isEmpty) return;

                                  final pacCedula = obtenerCedulaDesdeToken(token);
                                  if (pacCedula == null) return;

                                  // Combinar fecha + hora
                                  DateTime? fechaCombinada;
                                  if (fechaCtrl.text.isNotEmpty && horaCtrl.text.isNotEmpty) {
                                    final partes = horaCtrl.text.split(RegExp(r'[:\s]'));
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

                                    final fechaPartes = fechaCtrl.text.split('-');
                                    fechaCombinada = DateTime(
                                      int.parse(fechaPartes[0]),
                                      int.parse(fechaPartes[1]),
                                      int.parse(fechaPartes[2]),
                                      hora24,
                                      minuto,
                                    );
                                  }

                                  final medicamentoActualizado = {
                                    "medId": medicamento.id,
                                    "medNombre": nombreCtrl.text.trim(),
                                    "medDosis": dosisCtrl.text.trim(),
                                    "medFrecuencia": int.tryParse(frecuenciaCtrl.text),
                                    "medDuracion": int.tryParse(duracionCtrl.text),
                                    "medRecordatorio": medicamento.recordatorio,
                                    "medFecha": fechaCombinada?.toIso8601String(),
                                    "pacCedula": pacCedula,
                                    "medEstado": estadoSeleccionado,
                                  };

                                  final ok = await MedicamentosService.actualizarMedicamento(
                                      medicamentoActualizado, token);

                                  if (ok) {
                                    // Cerrar el popup de editar
                                    if (mounted) Navigator.pop(context); // cierra el AlertDialog de editar

                                    await Future.delayed(const Duration(milliseconds: 200));
                                    widget.onUpdate?.call();

                                    // Mostrar diálogo de éxito en pantalla principal
                                    if (!mounted) return;
                                    await DialogUtils.showDialogCustom(
                                      context: parentContext,
                                      title: "Éxito",
                                      message: "Medicamento actualizado correctamente",
                                    );
                                  } else {
                                    if (!mounted) return;
                                    await DialogUtils.showDialogCustom(
                                      context: context,
                                      title: "Error",
                                      message: "Error al actualizar el medicamento",
                                    );
                                  }
                                },
                                child: const Text("Guardar"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}