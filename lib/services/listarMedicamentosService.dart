import 'dart:convert';
import 'package:flutter_agenda_medica/controllers/listarMedicamentos.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MedicamentosService {

  Future<Map<String, List<Medicamento>>> listarMedicamentosBD(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/medicamentos/listarMedicamentos");

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
        'pendientes': (data['pendientes'] as List).map((e) => Medicamento.fromJson(e)).toList(),
        'consumidos': (data['consumidos'] as List).map((e) => Medicamento.fromJson(e)).toList(),
        'noConsumidos': (data['noConsumidos'] as List).map((e) => Medicamento.fromJson(e)).toList(),
      };
    } else {
      throw Exception('Error al obtener los medicamentos: ${response.statusCode}');
    }
  }
}