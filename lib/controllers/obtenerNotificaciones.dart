class Notificacion {
  final int notId;
  final DateTime notFecha;
  final bool notEstado;
  final String tipoReferencia;
  final String? medNombre;
  final String? medDosis;
  final int? medFrecuencia;
  final DateTime? medFecha;
  final String? citNomMedico;
  final DateTime? citFecha;
  final String? citHora;
  final String? citDireccion;
  final String? citEspecialidad;

  Notificacion({
    required this.notId,
    required this.notFecha,
    required this.notEstado,
    required this.tipoReferencia,
    this.medNombre,
    this.medDosis,
    this.medFrecuencia,
    this.medFecha,
    this.citNomMedico,
    this.citFecha,
    this.citHora,
    this.citDireccion,
    this.citEspecialidad,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      notId: json['notId'] is int ? json['notId'] : int.tryParse(json['notId']?.toString() ?? '0'),
      notFecha: DateTime.parse(json['notFecha']),
      notEstado: json['notEstado'],
      tipoReferencia: json['tipoReferencia'],
      medNombre: json['medNombre'],
      medDosis: json['medDosis'],
      medFrecuencia: json['medFrecuencia'],
      medFecha: json['medFecha'] != null ? DateTime.parse(json['medFecha']) : null,
      citNomMedico: json['citNomMedico'],
      citFecha: json['citFecha'] != null ? DateTime.parse(json['citFecha']) : null,
      citHora: json['citHora'],
      citDireccion: json['citDireccion'],
      citEspecialidad: json['citEspecialidad'],
    );
  }
}