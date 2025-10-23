import 'package:flutter/material.dart';
import '../controllers/DashboardModel.dart';
import 'Home.dart';
import 'Notificaciones.dart';

class Perfil extends StatelessWidget {
  final DashboardModel model;
  final String nombreUsuario;

  const Perfil({super.key, required this.model, required this.nombreUsuario});

  // Popup para mostrar información o acciones
  void _mostrarPopup(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        // Nombre de usuario
        Center(
          child: Column(
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 10),
              Text(
                nombreUsuario,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),



        // Otras opciones dentro de Configuraciones
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.blueGrey),
          title: const Text("Notificaciones"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Notificaciones()),
            );
          },
        ),

        const SizedBox(height: 40),

        // Botón Cerrar sesión
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              model.showLogoutDialog(context, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text(
              "Cerrar sesión",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
