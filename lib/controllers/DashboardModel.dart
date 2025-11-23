import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/ShowDialogCustom.dart';
import 'listarCitas.dart';
import 'listarMedicamentos.dart';
import 'package:flutter_agenda_medica/services/listarMedicamentosService.dart';
import '../services/listarCitasService.dart';

class DashboardModel extends ChangeNotifier{
  String? token;
  List<Cita> citas = [];
  List<Medicamento> medicamentos = [];

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {

      final citasService = CitaService();
      final medicamentosService = MedicamentosService();

      final mapaCitas = await citasService.listarCitasBD(token!);
      final mapaMedicamentos = await medicamentosService.listarMedicamentosBD(token!);

      citas = [
        ...mapaCitas['pendientes']!,
        ...mapaCitas['asistidas']!,
        ...mapaCitas['noAsistidas']!,
      ];

      medicamentos = [
        ...mapaMedicamentos['pendientes']!,
        ...mapaMedicamentos['consumidos']!,
        ...mapaMedicamentos['noConsumidos']!,
      ];
    }
    notifyListeners();
  }

  void showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
    DialogUtils.showDialogConfirm(
      context: context,
      title: "Confirmar",
      message: "¿Deseas cerrar sesión?",
      onConfirm: () async {
        await logout(context);
        onConfirm();
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}