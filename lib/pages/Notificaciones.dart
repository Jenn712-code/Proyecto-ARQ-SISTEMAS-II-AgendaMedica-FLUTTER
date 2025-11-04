import 'package:flutter/material.dart';
import '../controllers/DashboardModel.dart';


class Notificaciones extends StatefulWidget {
  const Notificaciones({super.key});

  static String routeName = 'notificacionespage';
  static String routePath = '/notificacionespage';

  @override
  State<Notificaciones> createState() => _NotificacionesState();
}

class _NotificacionesState extends State<Notificaciones>
    with SingleTickerProviderStateMixin {
  final DashboardModel model = DashboardModel();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método auxiliar para mostrar popups
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_today),
              text: "Citas",
            ),
            Tab(
              icon: Icon(Icons.medication),
              text: "Medicamentos",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- TAB 1: CITAS ---
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.event_available, color: Colors.blue),
                title: const Text("Cita con el médico general"),
                subtitle: const Text("25 de octubre, 9:00 AM"),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarPopup(
                    context,
                    "Cita médica",
                    "Detalles de la cita: consulta general en el Centro de Salud.",
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.event, color: Colors.green),
                title: const Text("Cita con el psicólogo"),
                subtitle: const Text("28 de octubre, 3:00 PM"),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarPopup(
                    context,
                    "Cita con el psicólogo",
                    "Sesión semanal de acompañamiento emocional.",
                  ),
                ),
              ),
            ],
          ),

          // --- TAB 2: MEDICAMENTOS ---
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.medication_outlined, color: Colors.redAccent),
                title: const Text("Paracetamol 500mg"),
                subtitle: const Text("Cada 8 horas"),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarPopup(
                    context,
                    "Medicamento",
                    "Tomar después de las comidas para evitar malestar estomacal.",
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.vaccines, color: Colors.orange),
                title: const Text("Vitaminas B12"),
                subtitle: const Text("Cada mañana, antes del desayuno"),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarPopup(
                    context,
                    "Vitaminas B12",
                    "Ayudan a mejorar la energía y el estado de ánimo.",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


