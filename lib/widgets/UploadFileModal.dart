import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../pages/HistorialMedicoPage.dart';

// Constantes de validación
const double MAX_FILE_SIZE_MB = 5.0;

// 🎯 CORRECCIÓN APLICADA: Se usa 'final' en lugar de 'const'
// para permitir la invocación del método 'toInt()' en tiempo de ejecución.
final int MAX_FILE_SIZE_BYTES = (MAX_FILE_SIZE_MB * 1024 * 1024).toInt();

class UploadFileModal extends StatefulWidget {
  final Function(ArchivoMedico) onFileUploaded;

  const UploadFileModal({super.key, required this.onFileUploaded});

  @override
  State<UploadFileModal> createState() => _UploadFileModalState();
}

class _UploadFileModalState extends State<UploadFileModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  DateTime? _fechaSeleccionada;
  PlatformFile? _archivoSeleccionado;
  String _errorArchivo = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    // Permite al usuario seleccionar archivos con la extensión .pdf
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = result.files.first;
      setState(() {
        _archivoSeleccionado = file;
        _errorArchivo = ''; // Limpiar errores previos
      });
      _validarArchivo(file);
    }
  }

  void _validarArchivo(PlatformFile file) {
    if (file.size > MAX_FILE_SIZE_BYTES) {
      setState(() {
        _errorArchivo = 'El archivo es demasiado grande (Máx. ${MAX_FILE_SIZE_MB.toStringAsFixed(0)} MB)';
      });
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _registrarArchivo() {
    // 1. Validar nombre y fecha
    if (!_formKey.currentState!.validate() || _fechaSeleccionada == null) {
      if (_fechaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debe seleccionar una fecha para el documento.")),
        );
      }
      return;
    }

    // 2. Validar selección de archivo y tamaño
    if (_archivoSeleccionado == null) {
      setState(() => _errorArchivo = 'Debe seleccionar un archivo PDF.');
      return;
    }
    if (_errorArchivo.isNotEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    // 💡 Lógica de subida (simulación)
    Future.delayed(const Duration(seconds: 2), () {
      final nuevoArchivo = ArchivoMedico(
        nombre: _nombreController.text,
        fecha: _fechaSeleccionada!,
        path: _archivoSeleccionado!.name,
        // El tamaño se convierte de bytes a KB
        sizeInKB: (_archivoSeleccionado!.size / 1024).toInt(),
      );

      widget.onFileUploaded(nuevoArchivo); // Agrega a la lista

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Archivo registrado exitosamente."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Cerrar el modal
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text("Registrar Archivo Médico", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),

              // 1. Nombre del archivo
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre del archivo (Ej: Radiografía de tórax)",
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre para el archivo' : null,
              ),
              const SizedBox(height: 15),

              // 2. Fecha del archivo
              InkWell(
                onTap: () => _seleccionarFecha(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha del documento',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_fechaSeleccionada == null
                      ? 'Seleccionar fecha'
                      : DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Selección y validación del archivo
              ElevatedButton.icon(
                onPressed: _seleccionarArchivo,
                icon: const Icon(Icons.attach_file),
                label: Text(_archivoSeleccionado == null
                    ? "Seleccionar Archivo PDF"
                    : "Archivo Seleccionado: ${_archivoSeleccionado!.name}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Mostrar error de validación
              if (_errorArchivo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_errorArchivo, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 20),

              // 4. Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _registrarArchivo,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrar Archivo", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}