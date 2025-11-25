class Medicamento {
  final int id;
  final String nombre;
  final String frecuencia;
  final String dosis;
  final String duracion;
  final String fecha;
  final String estado;
  bool recordatorio;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.frecuencia,
    required this.dosis,
    required this.duracion,
    required this.fecha,
    required this.estado,
    required this.recordatorio,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['medId'] is int
          ? json['medId']
          : int.tryParse(json['medId']?.toString() ?? '0') ?? 0,
      nombre: json['medNombre']?.toString() ?? '',
      frecuencia: json['medFrecuencia']?.toString() ?? '',
      dosis: json['medDosis']?.toString() ?? '',
      duracion: json['medDuracion']?.toString() ?? '',
      fecha: json['medFecha']?.toString() ?? '',
      estado: json['medEstado']?.toString() ?? '',
      recordatorio: _toBool(json['medRecordatorio']),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    final v = value?.toString().toLowerCase() ?? "false";
    return v == "true" || v == "1";
  }
}