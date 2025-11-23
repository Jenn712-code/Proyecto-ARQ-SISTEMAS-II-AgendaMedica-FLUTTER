/*import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../controllers/obtenerNotificaciones.dart';
import 'local_notifications.dart';

class notificacionService{

  Future<List<Notificacion>> fetchNotificacionesPendientes(String token) async {

    final url = Uri.parse("${ApiConfig.baseUrl}/notificaciones/pendientes");
    final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Notificacion.fromJson(e)).toList();
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
    List<Notificacion> notificaciones = await fetchNotificacionesPendientes(cedula);

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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../controllers/obtenerNotificaciones.dart';
import 'local_notifications.dart';

class NotificacionService {

  Future<List<Notificacion>> fetchNotificaciones(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/notificaciones/pendientes");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Notificacion.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener notificaciones");
    }
  }

  String cuerpoNotificacion(Notificacion n) {
    if (n.tipoReferencia == "Cita") {
      return "Médico: ${n.citNomMedico}\nDirección: ${n.citDireccion}";
    } else {
      return "Medicamento: ${n.medNombre}\nDosis: ${n.medDosis}\nCada ${n.medFrecuencia} horas";
    }
  }

  DateTime obtenerFechaValida(Notificacion n) {
    if (n.tipoReferencia == "Cita" && n.citFecha != null && n.citHora != null) {
      final partesHora = n.citHora!.split(":");
      final citaUTC = DateTime.utc(
        n.citFecha!.year,
        n.citFecha!.month,
        n.citFecha!.day,
        int.parse(partesHora[0]),
        int.parse(partesHora[1]),
      );
      return citaUTC.toLocal(); // <-- Convertimos a hora local
    }

    if (n.medFecha != null) {
      return n.medFecha!.toLocal(); // <-- Convertimos a hora local
    }

    return n.notFecha.toLocal();
  }

  Future<void> programarTodas(String token) async {
    List<Notificacion> lista = await fetchNotificaciones(token);

    for (var n in lista) {
      if (n.notEstado == false) {
        final fecha = obtenerFechaValida(n);
        if (fecha.isAfter(DateTime.now())) {
          await programarNotificacion(
            id: n.notId,
            titulo: n.tipoReferencia == "Cita"
                ? "Recordatorio de cita"
                : "Recordatorio de medicamento",
            cuerpo: cuerpoNotificacion(n),
            fecha: fecha,
          );
          print("[NOTI] Notificación ${n.notId} programada para $fecha");
        } else {
          print(
              "[NOTI] Notificación ${n.notId} ignorada (fecha pasada: $fecha)");
        }
      }
    }
  }

  Future<void> reprogramarNotificacion(int id, DateTime nuevaFecha) async {
    await programarNotificacion(
      id: id,
      titulo: "Recordatorio reprogramado",
      cuerpo: "Pospuesto 10 minutos",
      fecha: nuevaFecha,
    );
  }

  /*Future<void> actualizarEstadoNotificacion(int id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/notificaciones/$id/actualizarEstado");

    await http.put(url);
  }*/
}
