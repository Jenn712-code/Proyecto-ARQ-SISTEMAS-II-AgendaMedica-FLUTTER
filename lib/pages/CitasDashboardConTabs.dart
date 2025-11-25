import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/listarCitas.dart';
import '../services/listarCitasService.dart';
import '../theme/AppTheme.dart';
import 'crearCita.dart';
import '../widgets/CitaCard.dart';
import 'package:intl/intl.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint('No se encontró token guardado');
      return;
    }

    if (!mounted) return; // <-- protege el setState

    setState(() => _token = token);

    try {
      final data = await _citaService.listarCitasBD(token);

      if (!mounted) return; // <-- protege el setState después del await

      setState(() => _citas = data);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error al cargar citas: $e');
    }
  }

  Widget _buildCitaList(List<Cita> citas, Color color) {
    if (citas.isEmpty) {
      return Center(
        child: Text(
          "No hay citas registradas en esta categoria",
          style: AppTheme.subtitleText,
        ),
      );
    }

    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];

        return CitaCard(
          cita: cita,
          colorFondo: AppTheme.primaryColor,
          onDelete: _recargarCitas,
          onUpdate: _recargarCitas,
        );
      },
    );
  }

  void _recargarCitas() async {
    await _loadCitas();
    if (mounted) setState(() {});
  }

  List<Cita> _ordenarPorFecha(List<Cita> citas) {
    final listaOrdenada = List<Cita>.from(citas); // Copia segura

    listaOrdenada.sort((a, b) {
      final fechaHoraA = _parseFechaHora(a.fecha, a.hora);
      final fechaHoraB = _parseFechaHora(b.fecha, b.hora);
      return fechaHoraA.compareTo(fechaHoraB);
    });

    return listaOrdenada;
  }

  DateTime _parseFechaHora(String? fecha, String? hora) {
    if (fecha == null) return DateTime(2100);

    try {
      final date = DateFormat('yyyy-MM-dd').parse(fecha);

      if (hora == null || hora.isEmpty) {
        return date;
      }

      // Soporta: 02:30 PM o 14:30
      DateTime time;
      if (hora.contains("AM") || hora.contains("PM")) {
        time = DateFormat('hh:mm a').parse(hora);
      } else {
        time = DateFormat('HH:mm').parse(hora);
      }

      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } catch (e) {
      debugPrint("Error parseando fecha/hora: $e");
      return DateTime(2100);
    }
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 75),
              child: _citas == null
                  ? const Center(child: CircularProgressIndicator()) // Cargando
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildCitaList(
                    _ordenarPorFecha(_citas!['pendientes'] ?? []),
                    Colors.blue.shade800,
                  ),
                  _buildCitaList(
                    _ordenarPorFecha(_citas!['asistidas'] ?? []),
                    Colors.green,
                  ),
                  _buildCitaList(
                    _ordenarPorFecha(_citas!['noAsistidas'] ?? []),
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTÓN FLOTANTE para la creación de citas
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const crearCita()),
            );

            // Si se creó una cita, recargamos los datos
            if (result == true) {
              _loadCitas();
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