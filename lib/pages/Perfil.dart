// Archivo: lib/pages/Perfil.dart

import 'package:flutter/material.dart';
import '../controllers/DashboardModel.dart';
import '../theme/AppTheme.dart';

// 🎯 Importar la nueva página de Historial Médico
import 'HistorialMedicoPage.dart';

class Perfil extends StatefulWidget {
  final DashboardModel model;
  const Perfil({super.key, required this.model});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {

  // 💡 Función para simular el cierre de sesión
  void _cerrarSesion(BuildContext context) {
    // Aquí iría la lógica real de cerrar sesión (limpiar tokens, etc.)

    // Simulación de navegación a la pantalla de Login/Inicio
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/', // Asumiendo que tu ruta de login o inicio es '/'
          (Route<dynamic> route) => false,
    );

    // Mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sesión cerrada exitosamente.")),
    );
  }

  // --- Widgets de utilidad para la interfaz ---

  Widget _buildExpansionTile({required String title, required IconData icon, required List<Widget> children}) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Icon(icon, color: AppTheme.primaryColor), // Usa el color de tu tema
      children: children,
    );
  }

  Widget _buildListTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- Widget Principal Build ---

  @override
  Widget build(BuildContext context) {
    // 💡 Datos de usuario simulados (reemplazar con datos de widget.model)
    final String nombreUsuario = widget.model.nombreUsuario ?? "Usuario";
    final String correoUsuario = widget.model.correoUsuario ?? "correo@ejemplo.com";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección superior de Perfil
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: AppTheme.secondaryColor, // Color de fondo del perfil
              child: Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nombreUsuario,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    Text(
                      correoUsuario,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- 1. Configuraciones (Contiene Recordatorios) ---
            _buildExpansionTile(
              title: "Configuraciones",
              icon: Icons.settings,
              children: [
                _buildListTile(
                  title: "Recordatorios",
                  icon: Icons.notifications,
                  onTap: () {
                    // Navegación a la configuración de recordatorios
                  },
                ),
                // Aquí podrías añadir otras configuraciones
              ],
            ),

            // --- 2. Historial Médico (NUEVA SECCIÓN) ---
            _buildExpansionTile(
              title: "Historial Médico",
              icon: Icons.folder_shared,
              children: [
                // 🎯 NUEVA OPCIÓN: Registrar Archivo en Historial
                _buildListTile(
                  title: "Registrar Archivo en Historial",
                  icon: Icons.upload_file,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Navega a la página que tiene la lista y el botón de subida
                        builder: (context) => const HistorialMedicoPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Botón Cerrar Sesión ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                onPressed: () => _cerrarSesion(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar sesión", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}