import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/api_config.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails(
    'notificaciones_channel', // id del canal
    'Notificaciones',         // nombre
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Bienvenido',
    'a tu agenda medica personal',
    platformChannelSpecifics,
  );
}


/*class NotificacionDTO {
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

  NotificacionDTO({
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

  factory NotificacionDTO.fromJson(Map<String, dynamic> json) {
    return NotificacionDTO(
      notId: json['notId'],
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

  Future<List<NotificacionDTO>> fetchNotificacionesPendientes() async {
  final response = await http.get(
    Uri.parse('http://<TU_IP>:8080/notificaciones/pendientes'),
    headers: {'Authorization': 'Bearer <TU_TOKEN>'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => NotificacionDTO.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener notificaciones (${response.statusCode})');
  }
}

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'notificaciones_channel', // id del canal
      'Notificaciones',         // nombre
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> mostrarNotificaciones(String cedula) async {
    List<Notificacion> notificaciones = await fetchNotificaciones(cedula);

    for (var noti in notificaciones) {
      if (noti.tipoReferencia == 'Cita') {
        await showNotification(
          'Cita médica',
          'Médico: ${noti.citNomMedico}, Fecha: ${noti.notFecha}',
        );
      } else if (noti.tipoReferencia == 'Medicamento') {
        await showNotification(
          'Medicamento',
          'Nombre: ${noti.medNombre}, Fecha: ${noti.notFecha}',
        );
      }
    }
  }
}*/
