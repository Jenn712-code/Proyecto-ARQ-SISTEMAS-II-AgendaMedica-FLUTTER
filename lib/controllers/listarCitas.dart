class Cita {
  final int? id;
  final String? nomMedico;
  final String? especialidad;
  final String? fecha;
  final String? hora;
  final String? direccion;
  final String? estado;

  Cita({
    required this.id,
    required this.nomMedico,
    required this.especialidad,
    required this.fecha,
    required this.hora,
    required this.direccion,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['citId'] is int ? json['citId'] : int.tryParse(json['citId']?.toString() ?? '0'),
      nomMedico: json['citNomMedico'] ?? '',
      especialidad: json['espNombre'] ?? '', // OJO: tu backend manda 'espNombre', no 'esNombre'
      fecha: json['citFecha']?.toString() ?? '',
      hora: json['citHora']?.toString() ?? '',
      direccion: json['citDireccion'] ?? '',
      estado: json['citEstado'] ?? '',
    );
  }
}