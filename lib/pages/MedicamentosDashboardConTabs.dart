import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/services/listarMedicamentosService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/listarMedicamentos.dart';
import '../theme/AppTheme.dart';
import 'crearMedicamento.dart';
import '../widgets/MedicamentoCard.dart';

class MedicamentosDashboardConTabs extends StatefulWidget {
  const MedicamentosDashboardConTabs({super.key});

  @override
  State<MedicamentosDashboardConTabs> createState() => _MedicamentosDashboardConTabsState();
}

class _MedicamentosDashboardConTabsState extends State<MedicamentosDashboardConTabs> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final MedicamentosService _medicamentosService = MedicamentosService();
  Map<String, List<Medicamento>>? _medicamentos;
  String? _token;

  @override
  void initState() {
    super.initState();
    // 3 pestañas: Programados, Consumidos, Omitidos
    _tabController = TabController(length: 3, vsync: this);
    _loadMedicamentos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint('No se encontró token guardado');
      return;
    }
    setState(() => _token = token);

    try {
      final data = await _medicamentosService.listarMedicamentosBD(token);
      setState(() => _medicamentos = data);
    } catch (e) {
      debugPrint('Error al cargar los medicamentos: $e');
    }
  }

  Widget _buildMedicamentoList(List<Medicamento> medicamentos, Color color) {
    if (medicamentos.isEmpty) {
      return Center(child: Text("No hay medicamentos registrados en esta categoría", style: AppTheme.subtitleText));
    }

    return ListView.builder(
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        final med = medicamentos[index];
        return MedicamentoCard(
          nombre: med.nombre ?? '',
          dosis: med.dosis ?? '',
          frecuencia: med.frecuencia ?? '',
          duracion: med.duracion ?? '',
          fecha: med.fecha ?? '',
          colorFondo: color,
        );
      },
    );
  }

  List<Medicamento> _ordenarPorFechaHora(List<Medicamento> medicamentos) {
    medicamentos.sort((a, b) {
      final fechaHoraA = _parseFechaHoraIso(a.fecha);
      final fechaHoraB = _parseFechaHoraIso(b.fecha);
      return fechaHoraA.compareTo(fechaHoraB);
    });
    return medicamentos;
  }

  DateTime _parseFechaHoraIso(String? fechaHoraIso) {
    try {
      if (fechaHoraIso == null || fechaHoraIso.isEmpty) {
        return DateTime(2100); // Fecha muy lejana para evitar errores
      }
      return DateTime.parse(fechaHoraIso);
    } catch (e) {
      return DateTime(2100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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

          // EL CONTENIDO DE LAS PESTAÑAS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 75),
              child: _medicamentos == null
                  ? const Center(child: CircularProgressIndicator()) // Cargando
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildMedicamentoList(
                    _ordenarPorFechaHora(_medicamentos!['pendientes'] ?? []),
                    Colors.blue.shade800,
                  ),
                  _buildMedicamentoList(
                    _ordenarPorFechaHora(_medicamentos!['consumidos'] ?? []),
                    Colors.green,
                  ),
                  _buildMedicamentoList(
                    _ordenarPorFechaHora(_medicamentos!['noConsumidos'] ?? []),
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTÓN FLOTANTE para la creación de medicamentos
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const crearMedicamento()),
            );

            // Si se creó una cita, recargamos los datos
            if (result == true) {
              _loadMedicamentos();
            }
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
          label: const Text("Crear", style: TextStyle(fontSize: 18)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}