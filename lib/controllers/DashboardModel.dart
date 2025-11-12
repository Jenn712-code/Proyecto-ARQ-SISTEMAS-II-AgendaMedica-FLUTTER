import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/ShowDialogCustom.dart';

class DashboardModel {
  String? token;

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
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