// Archivo: lib/pages/CitasDashboardConTabs.dart

import 'package:flutter/material.dart';
// Importa tu formulario de creación de citas
import 'crearCita.dart';
// Importa el widget de la tarjeta (asumiendo que está en lib/widgets)
import '../widgets/CitaCard.dart';

class CitasDashboardConTabs extends StatefulWidget {
  const CitasDashboardConTabs({super.key});

  @override
  State<CitasDashboardConTabs> createState() => _CitasDashboardConTabsState();
}

// 🎯 NECESARIO: Agrega 'with SingleTickerProviderStateMixin' para el TabController
class _CitasDashboardConTabsState extends State<CitasDashboardConTabs>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 pestañas: Pendientes, Asistidas, No Asistidas
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 💡 Datos de prueba temporales para Citas
  final List<Map<String, String>> _citasPendientes = [
    {
      "especialidad": "Cardiología",
      "medico": "Dr. Juan Pérez",
      "fechaHora": "15 Dic 2025 - 10:30 AM",
      "direccion": "Calle Salud 123, Consultorio 5"
    },
    {
      "especialidad": "Dermatología",
      "medico": "Dra. María González",
      "fechaHora": "18 Nov 2025 - 2:15 PM",
      "direccion": "Av. Médica 456, Piso 2"
    },
    // Añadir más datos de prueba si es necesario...
  ];

  final List<Map<String, String>> _citasAsistidas = [
    {
      "especialidad": "Pediatría",
      "medico": "Dr. Carlos López",
      "fechaHora": "20 May 2025 - 9:00 AM",
      "direccion": "Clínica Infantil, Sala 12"
    },
  ];

  final List<Map<String, String>> _citasNoAsistidas = [
    {
      "especialidad": "Oftalmología",
      "medico": "Dra. Ana Martínez",
      "fechaHora": "22 Abr 2025 - 4:30 PM",
      "direccion": "Centro Oftalmológico, Consultorio B"
    },
  ];

  // 🎯 Método para construir la lista de citas, reutilizando CitaCard
  Widget _buildCitaList(List<Map<String, String>> citas, Color color) {
    if (citas.isEmpty) {
      return const Center(
        child: Text("No hay citas registradas en esta categoría.", textAlign: TextAlign.center),
      );
    }

    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return CitaCard(
          especialidad: cita["especialidad"]!,
          medico: cita["medico"]!,
          fechaHora: cita["fechaHora"]!,
          direccion: cita["direccion"]!,
          colorBorde: color,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🎯 EL TAB BAR
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.teal,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Pendientes"),
              Tab(text: "Asistidas"),
              Tab(text: "No Asistidas"),
            ],
            isScrollable: false,
          ),

          // 🎯 EL CONTENIDO DE LAS PESTAÑAS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Pendientes (Borde Azul Oscuro)
                _buildCitaList(_citasPendientes, Colors.blue.shade800),

                // 2. Asistidas (Borde Verde)
                _buildCitaList(_citasAsistidas, Colors.green),

                // 3. No Asistidas (Borde Rojo)
                _buildCitaList(_citasNoAsistidas, Colors.red),
              ],
            ),
          ),
        ],
      ),

      // 🎯 BOTÓN FLOTANTE para la creación de citas
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // NAVEGA a tu formulario (crearCita.dart)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const crearCita()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text("Crear cita", style: TextStyle(fontSize: 18)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}