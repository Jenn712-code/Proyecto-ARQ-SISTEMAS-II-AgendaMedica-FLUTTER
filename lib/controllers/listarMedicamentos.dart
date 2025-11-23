class Medicamento {
  final int? id;
  final String? nombre;
  final String? frecuencia;
  final String? dosis;
  final String? duracion;
  final String? fecha;
  final String? estado;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.frecuencia,
    required this.dosis,
    required this.duracion,
    required this.fecha,
    required this.estado,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['medId'] is int ? json['medId'] : int.tryParse(json['medId']?.toString() ?? '0'),
      nombre: json['medNombre']?.toString(),
      frecuencia: json['medFrecuencia']?.toString(),
      dosis: json['medDosis']?.toString(),
      duracion: json['medDuracion']?.toString(),
      fecha: json['medFecha']?.toString(),
      estado: json['medEstado'] ?? '',
    );
  }
}