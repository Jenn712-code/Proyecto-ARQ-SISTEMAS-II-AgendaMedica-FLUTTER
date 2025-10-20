import 'package:flutter/material.dart';
import '../controllers/DashboardModel.dart';
import 'Home.dart';

class Perfil extends StatelessWidget {
  final DashboardModel model;

  const Perfil({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Center(
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
