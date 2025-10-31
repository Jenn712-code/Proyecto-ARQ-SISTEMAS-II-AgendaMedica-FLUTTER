// Archivo: lib/pages/MedicamentosDashboardConTabs.dart

import 'package:flutter/material.dart';
// Importa tu formulario de creación de medicamento
import 'crearMedicamento.dart';
// Importa el widget de la tarjeta (asumiendo que está en lib/widgets)
import '../widgets/MedicamentoCard.dart';

class MedicamentosDashboardConTabs extends StatefulWidget {
  const MedicamentosDashboardConTabs({super.key});

  @override
  State<MedicamentosDashboardConTabs> createState() => _MedicamentosDashboardConTabsState();
}

// 🎯 NECESARIO: Agrega 'with SingleTickerProviderStateMixin' para el TabController
class _MedicamentosDashboardConTabsState extends State<MedicamentosDashboardConTabs>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 pestañas: Programados, Consumidos, Omitidos
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 💡 Datos de prueba temporales para simular la carga
  final List<Map<String, String>> _medsProgramados = [
    {"nombre": "Amoxicilina", "dosis": "500mg", "frecuencia": "Cada 8 horas", "toma": "08:00 AM"},
    {"nombre": "Ibuprofeno", "dosis": "200mg", "frecuencia": "Cada 6 horas", "toma": "12:00 PM"},
  ];
  final List<Map<String, String>> _medsConsumidos = [
    {"nombre": "Vitaminas D", "dosis": "1 tableta", "frecuencia": "Diaria", "toma": "Consumido"},
  ];
  final List<Map<String, String>> _medsOmitidos = [
    {"nombre": "Metformina", "dosis": "850mg", "frecuencia": "Cada 12 horas", "toma": "Omitido"},
  ];

  // 🎯 Método para construir la lista de medicamentos, reutilizando MedicamentoCard
  Widget _buildMedicamentoList(List<Map<String, String>> medicamentos, Color color) {
    if (medicamentos.isEmpty) {
      return const Center(child: Text("No hay medicamentos registrados en esta categoría."));
    }

    return ListView.builder(
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        final med = medicamentos[index];
        return MedicamentoCard(
          nombre: med["nombre"]!,
          dosis: med["dosis"]!,
          frecuencia: med["frecuencia"]!,
          siguienteToma: med["toma"]!,
          colorFondo: color,
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
              Tab(text: "Programados"),
              Tab(text: "Consumidos"),
              Tab(text: "Omitidos"),
            ],
            isScrollable: false,
          ),

          // 🎯 EL CONTENIDO DE LAS PESTAÑAS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Programados
                _buildMedicamentoList(_medsProgramados, Colors.blue.shade800),

                // 2. Consumidos
                _buildMedicamentoList(_medsConsumidos, Colors.green),

                // 3. Omitidos
                _buildMedicamentoList(_medsOmitidos, Colors.red),
              ],
            ),
          ),
        ],
      ),

      // 🎯 BOTÓN FLOTANTE para la creación de medicamentos
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // NAVEGA a tu formulario (crearMedicamento.dart)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const crearMedicamento()),
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
          label: const Text("Crear medicamento", style: TextStyle(fontSize: 18)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}