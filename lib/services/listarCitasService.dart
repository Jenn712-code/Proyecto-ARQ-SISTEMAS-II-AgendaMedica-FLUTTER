import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../controllers/listarCitas.dart';


class CitaService {

  Future<Map<String, List<Cita>>> listarCitasBD(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/citas/listarCitas");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return {
        'pendientes': (data['pendientes'] as List).map((e) => Cita.fromJson(e)).toList(),
        'asistidas': (data['asistidas'] as List).map((e) => Cita.fromJson(e)).toList(),
        'noAsistidas': (data['noAsistidas'] as List).map((e) => Cita.fromJson(e)).toList(),
      };
    } else {
      throw Exception('Error al obtener citas: ${response.statusCode}');
    }
  }

  static Future<bool> actualizarCita(Map<String, dynamic> cita, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/citas/actualizar");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(cita),
    );

    if (response.statusCode == 200) {
      return true;
    }
    print("Error al actualizar cita: ${response.statusCode} - ${response.body}");
    return false;
  }

  static Future<bool> eliminarCita(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/citas/eliminar/$id");

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}