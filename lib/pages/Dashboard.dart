import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/pages/crearCita.dart';
import 'package:flutter_agenda_medica/pages/crearMedicamento.dart';

// 🎯 Widgets de Dashboard con pestañas
import 'CitasDashboardConTabs.dart';
import 'MedicamentosDashboardConTabs.dart';

import '../controllers/DashboardModel.dart';
import '../theme/AppTheme.dart';
import 'Perfil.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static String routeName = 'Dashboardpage';
  static String routePath = '/dashboardpage';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardModel model = DashboardModel();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    model.cargarDatosUsuario().then((_) {
      setState(() {
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Lista de títulos dinámicos para el AppBar
  final List<String> _titles = [
    'Inicio',
    'Citas',
    'Medicamentos',
    'Perfil',
  ];

  // Lista de pantallas que vas a mostrar en el dashboard
  late final List<Widget> _pages = [
    // 0. Inicio
    const Center(child: Text("Inicio")),

    // 1. Citas (AHORA USA EL WIDGET CON EL TAB BAR)
    const CitasDashboardConTabs(),

    // 2. Medicamentos (AHORA USA EL WIDGET CON EL TAB BAR)
    const MedicamentosDashboardConTabs(),

    // 3. Perfil
    Perfil(model: model),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título cambia según la página seleccionada
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.secondaryColor,
      ),

      // Muestra la página seleccionada
      body: _pages[_selectedIndex],

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Citas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: "Medicamentos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}