// Archivo: lib/widgets/CitaCard.dart

import 'package:flutter/material.dart';

class CitaCard extends StatelessWidget {
  final String especialidad;
  final String medico;
  final String fechaHora;
  final String direccion;
  final Color colorBorde;

  const CitaCard({
    super.key,
    required this.especialidad,
    required this.medico,
    required this.fechaHora,
    required this.direccion,
    required this.colorBorde,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorBorde, width: 3),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Icon(
          Icons.health_and_safety, // Puedes cambiar el ícono
          color: colorBorde,
          size: 30,
        ),
        title: Text(
          especialidad,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorBorde,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(medico, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(fechaHora),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                // Limita el texto de la dirección para que no desborde
                Expanded(child: Text(direccion, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
        onTap: () {
          // Acción al tocar la tarjeta, ej.: ver detalles de la cita
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ver detalles de la cita con $medico')),
          );
        },
      ),
    );
  }
}