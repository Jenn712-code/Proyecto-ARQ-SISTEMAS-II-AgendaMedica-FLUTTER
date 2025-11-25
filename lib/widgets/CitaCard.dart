import 'dart:convert';
import '../theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/services/listarCitasService.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../controllers/crearCitaModel.dart';
import '../controllers/listarCitas.dart';
import 'CustomCard.dart';
import 'CustomDropDown.dart';
import 'CustomTextField.dart';
import 'DatePicker.dart';
import 'ShowDialogCustom.dart';
import 'TimePicker.dart';
import 'package:flutter/services.dart';

class CitaCard extends StatefulWidget {
  final Cita cita;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;
  final Color colorFondo;

  const CitaCard({
    super.key,
    required this.cita,
    this.onDelete,
    this.onUpdate,
    required this.colorFondo,
  });

  @override
  State<CitaCard> createState() => _CitaCardState();
}

class _CitaCardState extends State<CitaCard> {
  bool mostrarAcciones = false;
  final model = crearCitaModel();
  List<Map<String, dynamic>> especialidades = [];

  String formatearHora(String hora24) {
    try {
      final dateTime = DateFormat("HH:mm").parse(hora24);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (_) {
      return hora24;
    }
  }

  String formatearFecha(String fecha) {
    try {
      final dateTime = DateFormat("yyyy-MM-dd").parse(fecha);
      return DateFormat("EEE d MMM yyyy", 'es_ES').format(dateTime);
    } catch (_) {
      return fecha;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;

    return GestureDetector(
      onTap: () {
        setState(() => mostrarAcciones = !mostrarAcciones);
      },
      child: CustomCard(
        colorBorde: widget.colorFondo,
        icono: Icons.health_and_safety,
        titulo: cita.especialidad,
        bordeIzquierdo: 6,
        contenido: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Dr(a) ${cita.nomMedico}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                          Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("${formatearFecha(cita.fecha)} - ${formatearHora(
                          cita.hora)}"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                          Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          cita.direccion,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Acciones
            AnimatedOpacity(
              opacity: mostrarAcciones ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Visibility(
                visible: mostrarAcciones,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                      tooltip: "Editar cita",
                      onPressed: () async {
                        await cargarEspecialidades(() {});
                        mostrarPopupEditar(context, cita, () {
                          setState(() {});
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Eliminar cita",
                      onPressed: () {
                        DialogUtils.showDialogConfirm(
                          context: context,
                          title: "Confirmar",
                          message: "¿Desea eliminar esta cita?",
                          onConfirm: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');
                            final ok =
                            await CitaService.eliminarCita(cita.id, token!);

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
  // CARGAR ESPECIALIDADES
  // ==============================
  Future<void> cargarEspecialidades(VoidCallback onUpdate) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/especialidades/listarEspecialidades");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      especialidades = data
          .map((e) => {"id": e["espId"], "nombre": e["espNombre"]})
          .toList();
      especialidades.sort((a, b) =>
          a["nombre"].toLowerCase().compareTo(b["nombre"].toLowerCase()));
      onUpdate();
    }
  }

  // ==============================
  // POPUP DE EDITAR CITA
  // ==============================
  void mostrarPopupEditar(BuildContext parentContext, Cita cita,
      Function onUpdated) async {
    final TextEditingController medicoCtrl = TextEditingController(text: cita.nomMedico ?? '');
    final TextEditingController fechaCtrl = TextEditingController(text: cita.fecha ?? '');
    final TextEditingController horaCtrl = TextEditingController(text: cita.hora ?? '');
    final TextEditingController direccionCtrl = TextEditingController(text: cita.direccion ?? '');

    int? espSeleccionada = cita.espId;
    String estadoSeleccionado = cita.estado ?? "Pendiente";

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "Editar Cita",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
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
                        // NOMBRE DEL MÉDICO
                        CustomTextField(
                          controller: medicoCtrl,
                          label: "Nombre del médico",
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

                        // FECHA
                        CustomTextField(
                          controller: fechaCtrl,
                          label: "Fecha",
                          icon: Icons.calendar_today,
                          obscureText: false,
                          readOnly: true,
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? "La fecha es obligatoria"
                              : null,
                          onTap: () async {
                            final fecha =
                            await DatePickerUtils.mostrarSelectorFecha(context);
                            if (fecha != null) {
                              fechaCtrl.text =
                              "${fecha.year}-${fecha.month.toString().padLeft(
                                  2, '0')}-${fecha.day.toString().padLeft(
                                  2, '0')}";
                              setState(() {});
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        // HORA
                        CustomTextField(
                          controller: horaCtrl,
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
                            if (hora != null) horaCtrl.text = hora;
                          },
                        ),

                        const SizedBox(height: 15),

                        // DIRECCIÓN
                        CustomTextField(
                          controller: direccionCtrl,
                          label: "Dirección",
                          icon: Icons.location_on,
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

                        // ESPECIALIDAD
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child:CustomDropdown<int>(
                              label: "Especialidad",
                              value: espSeleccionada,
                              items: especialidades.map((esp) {
                                return DropdownMenuItem<int>(
                                  value: esp["id"],
                                  child: Text(
                                    esp["nombre"],
                                    style: AppTheme.subtitleText,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => espSeleccionada = value),
                              validator: (value) =>
                              value == null ? "Seleccione una especialidad" : null,
                          ),
                        ),
                      ),

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
                                  value: "Asistida", child: Text("Asistida")),
                              DropdownMenuItem(
                                  value: "No asistida",
                                  child: Text("No asistida")),
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
                              value: cita.recordatorio,
                              onChanged: (bool? v) =>
                                  setState(() =>
                                  cita.recordatorio = v ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Colors.teal,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            Row(
              children: [
                // Botón CANCELAR (ocupa la mitad)
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ),

                const SizedBox(width: 10),

                // Botón GUARDAR (ocupa la otra mitad)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString("token") ?? "";

                      if (token.isEmpty) {
                        DialogUtils.showDialogCustom(
                          context: context,
                          title: "Error",
                          message: "No se encontró el token del usuario",
                        );
                        return;
                      }

                      final pacCedula = obtenerCedulaDesdeToken(token);
                      if (pacCedula == null) {
                        DialogUtils.showDialogCustom(
                          context: context,
                          title: "Error",
                          message: "No se pudo obtener la cédula desde el token",
                        );
                        return;
                      }

                      final citaActualizada = {
                        "citId": cita.id,
                        "citNomMedico": medicoCtrl.text.trim(),
                        "citFecha": fechaCtrl.text.trim(),
                        "citHora": horaCtrl.text.trim(),
                        "citDireccion": direccionCtrl.text.trim(),
                        "citEstado": estadoSeleccionado,
                        "pacCedula": pacCedula,
                        "espId": espSeleccionada,
                        "citRecordatorio": cita.recordatorio,
                      };

                      final ok = await CitaService.actualizarCita(citaActualizada, token);

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
                          message: "Cita actualizada correctamente",
                        );
                      } else {
                        if (!mounted) return;
                        await DialogUtils.showDialogCustom(
                          context: context,
                          title: "Error",
                          message: "Error al actualizar la cita",
                        );
                      }
                    },
                    child: const Text("Guardar"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}