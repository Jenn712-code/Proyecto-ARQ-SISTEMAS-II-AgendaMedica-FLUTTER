import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notificacionService.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Bogota'));

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _handleNotificationAction,
  );

  // Pedir permisos al iniciar (NO dentro de una acción)
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImpl?.requestNotificationsPermission();
      print("Permiso concedido: $granted");
    }
  }
}

Future<void> _handleNotificationAction(NotificationResponse response) async {
  final int? id = response.id;
  if (id == null) return;

  final service = NotificacionService();

  // POSPONER
  if (response.actionId == "POSPONER") {
    final nuevaHora = DateTime.now().add(const Duration(minutes: 10));

    print("[NOTI] Posponiendo notificación $id a $nuevaHora");
    await service.reprogramarNotificacion(id, nuevaHora);
  }

  // VER DETALLE
  if (response.actionId == "DETALLE") {
    print("[NOTI] Ver detalle de notificación $id");
  }

  // Cambiar estado a true inmediatamente
  print("[NOTI] Actualizando estado de la notificación $id");
  //await service.actualizarEstadoNotificacion(id);
} // 👈 CIERRE CORRECTO


// --------------------------------------------------------------
//   FUNCIÓN PARA PROGRAMAR NOTIFICACIONES
// --------------------------------------------------------------
Future<void> programarNotificacion({
  required int id,
  required String titulo,
  required String cuerpo,
  required DateTime fecha,
}) async {
  final tz.TZDateTime programada =
  tz.TZDateTime.from( fecha.toLocal(), tz.local); // importante

  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'notificaciones_channel',
    'Notificaciones',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    actions: [
      AndroidNotificationAction("POSPONER", "Posponer"),
      AndroidNotificationAction("DETALLE", "Ver detalle"),
    ],
  );

  final NotificationDetails generalDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    titulo,
    cuerpo,
    programada,
    generalDetails,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
  );

  print("[NOTI] Notificación $id programada para $programada");
}


// --------------------------------------------------------------
//   NOTIFICACIÓN INMEDIATA (SEGUIRÁ FUNCIONANDO)
// --------------------------------------------------------------
Future<void> showNotification() async {
  const bigPicture = BigPictureStyleInformation(
    DrawableResourceAndroidBitmap('@mipmap/icono'),
    hideExpandedLargeIcon: false,
  );

  const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails(
    'notificaciones_channel',
    'Notificaciones',
    channelDescription: 'Canal de notificaciones locales',
    styleInformation: bigPicture,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Bienvenido',
    'A tu agenda médica personal',
    notificationDetails,
  );
}
