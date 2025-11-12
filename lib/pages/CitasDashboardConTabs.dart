import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/listarCitas.dart';
import '../services/listarCitasService.dart';
import 'crearCita.dart';
import '../widgets/CitaCard.dart';

class CitasDashboardConTabs extends StatefulWidget {
  const CitasDashboardConTabs({super.key});

  @override
  State<CitasDashboardConTabs> createState() => _CitasDashboardConTabsState();
}

class _CitasDashboardConTabsState extends State<CitasDashboardConTabs> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final CitaService _citaService = CitaService();
  Map<String, List<Cita>>? _citas;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadCitas();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _loadCitas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint('No se encontró token guardado');
      return;
    }
    setState(() => _token = token);

    try {
      final data = await _citaService.listarCitas(token);
      setState(() => _citas = data);
    } catch (e) {
      debugPrint('Error al cargar citas: $e');
    }
  }


  Widget _buildCitaList(List<Cita> citas, Color color) {
    if (citas.isEmpty) {
      return const Center(child: Text("No hay citas registradas."));
    }

    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return CitaCard(
          nomMedico: cita.nomMedico ?? '',
          especialidad: cita.especialidad ?? '',
          fecha: cita.fecha ?? '',
          hora: cita.hora ?? '',
          direccion: cita.direccion ?? '',
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
          // EL TAB BAR
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

          // CONTENIDO DE LAS TABS
          Expanded(
            child: _citas == null
                ? const Center(child: CircularProgressIndicator()) // Cargando
                : TabBarView(
              controller: _tabController,
              children: [
                // Pendientes (borde azul oscuro)
                _buildCitaList(_citas!['pendientes'] ?? [], Colors.blue.shade800),

                // 2Asistidas (borde verde)
                _buildCitaList(_citas!['asistidas'] ?? [], Colors.green),

                // 3No Asistidas (borde rojo)
                _buildCitaList(_citas!['noAsistidas'] ?? [], Colors.red),
              ],
            ),
          ),
        ],
      ),

      // BOTÓN FLOTANTE para la creación de citas
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