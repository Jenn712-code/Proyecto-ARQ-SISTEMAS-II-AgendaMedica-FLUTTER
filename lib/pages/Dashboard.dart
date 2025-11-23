import 'package:flutter/material.dart';
import '../services/notificacionService.dart';
import 'CitasDashboardConTabs.dart';
import 'MedicamentosDashboardConTabs.dart';
import '../controllers/DashboardModel.dart';
import '../theme/AppTheme.dart';
import 'Perfil.dart';
import 'InicioDashboard.dart';

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

  bool cargando = true; // <--- FLAG PARA INDICAR QUE AÚN NO SE HAN CARGADO LOS DATOS
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    model.cargarDatosUsuario().then((_) async {

      setState(() {
        cargando = false; // <--- YA HAY DATOS
        _pages = [
          InicioDashboard(
            citas: model.citas,
            medicamentos: model.medicamentos,
          ),
          const CitasDashboardConTabs(),
          const MedicamentosDashboardConTabs(),
          Perfil(model: model),
        ];
      });

      if (model.token != null) {
        await NotificacionService().programarTodas(model.token!);
      }
    });


  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      setState(() => cargando = true);

      await model.cargarDatosUsuario();

      setState(() {
        cargando = false;
        _pages = [
          InicioDashboard(
            citas: model.citas,
            medicamentos: model.medicamentos,
          ),
          const CitasDashboardConTabs(),
          const MedicamentosDashboardConTabs(),
          Perfil(model: model),
        ];
      });
    }
  }

  final List<String> _titles = [
    'Inicio',
    'Citas',
    'Medicamentos',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {

    // MIENTRAS CARGA MUESTRA UN LOADING
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // YA HAY DATOS → MUESTRA LAS PÁGINAS CORRECTAS
    return Scaffold(
      appBar: AppBar(
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Citas"),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Medicamentos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
