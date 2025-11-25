class Cita {
  final int id;
  final String nomMedico;
  final String especialidad;
  final int espId;
  final String fecha;
  final String hora;
  final String direccion;
  final String estado;
  bool recordatorio;

  Cita({
    required this.id,
    required this.nomMedico,
    required this.especialidad,
    required this.espId,
    required this.fecha,
    required this.hora,
    required this.direccion,
    required this.estado,
    required this.recordatorio,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['citId'] is int ? json['citId'] : int.tryParse(json['citId']?.toString() ?? '0'),
      nomMedico: json['citNomMedico'] ?? '',
      especialidad: json['espNombre'] ?? '',
      fecha: json['citFecha']?.toString() ?? '',
      hora: json['citHora']?.toString() ?? '',
      direccion: json['citDireccion'] ?? '',
      estado: json['citEstado'] ?? '',
      recordatorio: _toBool(json['citRecordatorio']),
      espId: json['espId'] ?? 0,
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    final v = value?.toString().toLowerCase() ?? "false";
    return v == "true" || v == "1";
  }
}