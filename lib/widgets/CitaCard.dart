import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'CustomCard.dart';

class CitaCard extends StatelessWidget {
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

  String formatearHora(String hora24) {
    try {
      final dateTime = DateFormat("HH:mm").parse(hora24);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (_) {
      return hora24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      colorBorde: colorFondo,
      icono: Icons.health_and_safety,
      titulo: especialidad,
      bordeIzquierdo: 6,
        contenido: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(nomMedico),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text("$fecha  ${formatearHora(hora)}"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    direccion,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ver detalles de la cita con $nomMedico')),
          );
        },
      );
  }
}