// Archivo: lib/widgets/MedicamentoCard.dart

import 'package:flutter/material.dart';

import 'CustomCard.dart';

class MedicamentoCard extends StatelessWidget {
  final String nombre;
  final String dosis;
  final String frecuencia;
  final Color colorFondo; // Para estado (Programado, Consumido, Omitido)
  final String siguienteToma; // Ejemplo: 08:00 AM

  const MedicamentoCard({
    super.key,
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    required this.colorFondo,
    required this.siguienteToma,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      colorBorde: colorFondo,
      icono: Icons.medical_services,
      titulo: nombre,
      bordeIzquierdo: 6,
      // estilo tipo franja lateral
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Dosis: $dosis - $frecuencia'),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text('Próxima toma: $siguienteToma',
                  style: TextStyle(color: colorFondo)),
            ],
          ),
        ],
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detalles o acción para $nombre')),
        );
      },
    );
  }
}