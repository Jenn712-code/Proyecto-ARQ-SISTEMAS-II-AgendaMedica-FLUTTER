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
}