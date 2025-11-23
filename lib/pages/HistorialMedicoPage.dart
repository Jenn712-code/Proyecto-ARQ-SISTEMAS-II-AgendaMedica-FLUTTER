import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// 🎯 VERIFICA QUE LA RUTA A TU WIDGET SEA CORRECTA
import '../theme/AppTheme.dart';
import '../widgets/UploadFileModal.dart';

// MODELO DE DATOS
class ArchivoMedico {
  final String nombre;
  final DateTime fecha;
  final String path;
  final int sizeInKB;

  ArchivoMedico({
    required this.nombre,
    required this.fecha,
    required this.path,
    required this.sizeInKB,
  });
}

class HistorialMedicoPage extends StatefulWidget {
  const HistorialMedicoPage({super.key});

  @override
  State<HistorialMedicoPage> createState() => _HistorialMedicoPageState();
}

class _HistorialMedicoPageState extends State<HistorialMedicoPage> {
  // Lista de archivos del historial (datos de prueba)
  final List<ArchivoMedico> _historial = [
    ArchivoMedico(
      nombre: "Examen de Sangre",
      fecha: DateTime(2025, 10, 20),
      path: "temp/lab_20251020.pdf",
      sizeInKB: 450,
    ),
  ];

  void _agregarArchivo(ArchivoMedico archivo) {
    setState(() {
      _historial.add(archivo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial Médico",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _historial.isEmpty
          ? const Center(
        child: Text("No hay archivos en tu historial médico."),
      )
          : ListView.builder(
        itemCount: _historial.length,
        itemBuilder: (context, index) {
          final archivo = _historial[index];
          return ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(archivo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: RichText(
              text: TextSpan(
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(
                    text: 'Fecha: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  TextSpan(
                    text: DateFormat('dd MMM yyyy', 'es_ES').format(archivo.fecha),
                  ),
                  const TextSpan(text: '   |   '),
                  const TextSpan(
                    text: 'Tamaño: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  TextSpan(
                    text: '${(archivo.sizeInKB / 1024).toStringAsFixed(2)} MB',
                  ),
                ],
              ),
            ),
            onTap: () {
              // Acción para abrir o descargar el PDF
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Abriendo archivo: ${archivo.nombre}")),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mostrar el diálogo de subida de archivo
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => UploadFileModal(onFileUploaded: _agregarArchivo),
          );
        },
        label: const Text("Registrar Archivo"),
        icon: const Icon(Icons.cloud_upload),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}