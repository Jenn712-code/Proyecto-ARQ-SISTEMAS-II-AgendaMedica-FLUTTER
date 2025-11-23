import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/AppTheme.dart';
import 'CustomCard.dart';
import 'ShowDialogCustom.dart';

class CitaCard extends StatefulWidget {
  final String nomMedico;
  final String especialidad;
  final String fecha;
  final String hora;
  final String direccion;
  final Color colorFondo;

  const CitaCard({
    super.key,
    required this.nomMedico,
    required this.especialidad,
    required this.fecha,
    required this.hora,
    required this.direccion,
    required this.colorFondo,
  });

  @override
  State<CitaCard> createState() => _CitaCardState();
}

class _CitaCardState extends State<CitaCard> {
  bool mostrarAcciones = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          mostrarAcciones = !mostrarAcciones;
        });
      },
      child: CustomCard(
        colorBorde: widget.colorFondo,
        icono: Icons.health_and_safety,
        titulo: widget.especialidad,
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
                  Text('Dr(a) ${widget.nomMedico}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("${formatearFecha(widget.fecha)} - ${formatearHora(widget.hora)}"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.direccion,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botones que aparecen solo al tocar
            AnimatedOpacity(
              opacity: mostrarAcciones ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Visibility(
                visible: mostrarAcciones,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                        tooltip: "Editar cita",
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Eliminar cita",
                        onPressed: () {
                          DialogUtils.showDialogConfirm(
                            context: context,
                            title: "Confirmar",
                            message: "¿Desea eliminar esta cita?",
                            onConfirm: () async {},
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: "Marcar como asistida",
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
