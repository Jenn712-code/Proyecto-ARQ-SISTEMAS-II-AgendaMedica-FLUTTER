import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/AppTheme.dart';
import 'CustomCard.dart';
import 'ShowDialogCustom.dart';

class MedicamentoCard extends StatefulWidget {
  final String nombre;
  final String dosis;
  final String frecuencia;
  final String duracion;
  final String fecha;
  final Color colorFondo;

  const MedicamentoCard({
    super.key,
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    required this.duracion,
    required this.fecha,
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
    return GestureDetector(
      onTap: () => setState(() => mostrarAcciones = !mostrarAcciones),
      child: CustomCard(
        colorBorde: widget.colorFondo,
        icono: Icons.medical_services,
        titulo: widget.nombre,
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
                  Text('${widget.dosis} - Cada ${widget.frecuencia} hora(s)'),
                  const SizedBox(height: 4),
                  Text('Por ${widget.duracion} día(s)'),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                          Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        formatearFechaHora(widget.fecha),
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Eliminar medicamento",
                      onPressed: () {
                        DialogUtils.showDialogConfirm(
                          context: context,
                          title: "Confirmar",
                          message: "¿Desea eliminar este medicamento?",
                          onConfirm: () async {},
                        );
                      },
                    ),
                    /*IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: "Marcar como asistida",
                        onPressed: () {},
                      ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}