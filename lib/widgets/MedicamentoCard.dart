// Archivo: lib/widgets/MedicamentoCard.dart

import 'package:flutter/material.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          // Usamos el color para el borde de la tarjeta y un fondo ligero
          border: Border(left: BorderSide(color: colorFondo, width: 6)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: Icon(Icons.medical_services, color: colorFondo, size: 30),
          title: Text(
            nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Dosis: $dosis - $frecuencia'),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  // Muestra la próxima hora para los Programados, o el estado para otros
                  Text('Próxima toma: $siguienteToma', style: TextStyle(color: colorFondo)),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Acción al tocar la tarjeta, ej.: marcar como consumido o ver detalles
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Detalles o acción para $nombre')),
            );
          },
        ),
      ),
    );
  }
}