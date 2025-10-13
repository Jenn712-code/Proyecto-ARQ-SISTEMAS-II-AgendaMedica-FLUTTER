import 'package:flutter/material.dart';

class DashboardModel {
  /// Muestra un diálogo de confirmación de cierre de sesión
  void showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // cancelar
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // cerrar diálogo
              onConfirm(); // ejecutar acción de confirmación
            },
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );
  }
}