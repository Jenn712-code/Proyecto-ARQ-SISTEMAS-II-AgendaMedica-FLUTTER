import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/listarCitas.dart';
import '../controllers/listarMedicamentos.dart';
import '../theme/AppTheme.dart';
import '../widgets/CitaCard.dart';
import '../widgets/MedicamentoCard.dart';
import 'package:diacritic/diacritic.dart';

class InicioDashboard extends StatefulWidget {
  final List<Cita> citas;
  final List<Medicamento> medicamentos;

  const InicioDashboard({
    super.key,
    required this.citas,
    required this.medicamentos,
  });

  @override
  State<InicioDashboard> createState() => _InicioDashboardState();
}

class _InicioDashboardState extends State<InicioDashboard> {
  List<dynamic> resultados = []; // lista combinada de Cita y Medicamento
  String busqueda = "";

  @override
  void initState() {
    super.initState();
    // Inicialmente mostramos todas las cards
    resultados = [...widget.citas, ...widget.medicamentos];
  }
  void _filtrarResultados(String query) {
    // Convertimos la query a minúsculas y quitamos tildes
    final q = removeDiacritics(query.toLowerCase());

    // Filtrar citas
    final citasFiltradas = widget.citas.where((c) {
      final nomMed = removeDiacritics(c.nomMedico.toLowerCase() ?? '');
      final esp = removeDiacritics(c.especialidad.toLowerCase() ?? '');
      return nomMed.contains(q) || esp.contains(q);
    }).toList();

    // Filtrar medicamentos
    final medicamentosFiltrados = widget.medicamentos.where((m) {
      final nombre = removeDiacritics(m.nombre.toLowerCase() ?? '');
      return nombre.contains(q);
    }).toList();

    setState(() {
      busqueda = query;
      resultados = [...citasFiltradas, ...medicamentosFiltrados];
    });
  }

  // Panel superior de porcentajes (puedes personalizar métricas)
  Widget _panelPorcentajes() {
    final totalCitas = widget.citas.length;
    final asistidas =
        widget.citas.where((c) => c.estado == "Asistida").length;

    final totalMedic = widget.medicamentos.length;
    final consumidos =
        widget.medicamentos.where((m) => m.estado == "Consumido").length;

    final porcentajeCitas =
    totalCitas == 0 ? 0 : ((asistidas / totalCitas) * 100).round();

    final porcentajeMedic =
    totalMedic == 0 ? 0 : ((consumidos / totalMedic) * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ===== TÍTULO CENTRADO =====
          Align(
            alignment: Alignment.center,
            child: Text(
              "Progreso general",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// ===== FILA DE TARJETAS REDUCIDAS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _porcentajeCardMini(
                  titulo: "Citas asistidas",
                  porcentaje: porcentajeCitas,
                  color1: const Color(0xFF2B75DC),
                  color2: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _porcentajeCardMini(
                  titulo: "Medicamentos consumidos",
                  porcentaje: porcentajeMedic,
                  color1: const Color(0xFF4AA993),
                  color2: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _porcentajeCardMini({
    required String titulo,
    required int porcentaje,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "$porcentaje%",
              style: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _panelPorcentajes(),

        // Buscador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Buscar por médico, especialidad o medicamento",
              hintStyle: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            onChanged: _filtrarResultados,
          ),
        ),

        // Lista filtrada
        Expanded(
          child: resultados.isEmpty
              ? Center(
            child: Text(
              busqueda.isEmpty
                  ? "No hay citas ni medicamentos registrados"
                  : "No se encontraron resultados para '$busqueda'",
              style: AppTheme.subtitleText,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: resultados.length,
            itemBuilder: (context, index) {
              final item = resultados[index];

              if (item is Cita) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CitaCard(
                    cita: item,
                    colorFondo: AppTheme.primaryColor,
                  ),
                );
              } else if (item is Medicamento) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MedicamentoCard(
                    medicamento: item,
                    colorFondo: Color(0xFF4AA993),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}