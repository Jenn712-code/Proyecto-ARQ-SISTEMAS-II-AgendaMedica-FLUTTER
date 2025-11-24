import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/crearPacienteModel.dart';
import '../theme/AppTheme.dart';
import '../widgets/CustomTextField.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class crearPaciente extends StatefulWidget {
  const crearPaciente({super.key});

  @override
  State<crearPaciente> createState() => _crearPacienteState();
}

class _crearPacienteState extends State<crearPaciente> {
  final model = crearPacienteModel();
  final regexCel = RegExp(r"^3\d{9}$");

  @override
  void dispose() {
    model.cedulaController.dispose();
    model.nombreController.dispose();
    model.fechaNacimientoController.dispose();
    model.epsController.dispose();
    model.celularController.dispose();
    model.correoController.dispose();
    model.contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registrarme",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // ocupa toda la pantalla
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: model.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // centra verticalmente
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: model.cedulaController,
                        label: "Cédula",
                        icon: Icons.credit_card,
                        obscureText: false,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Ingrese la cédula";
                          if (v.length < 6) return "Cédula inválida";
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.nombreController,
                        label: "Nombre Completo",
                        icon: Icons.person,
                        obscureText: false,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Ingrese el nombre";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.fechaNacimientoController,
                        label: 'Fecha de Nacimiento',
                        icon: Icons.calendar_today,
                        obscureText: false,
                        readOnly: true,
                        onTap: () => _mostrarSelectorFecha(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La fecha es obligatoria";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: DropdownButtonFormField2<String>(
                            decoration: const InputDecoration(labelText: "EPS"),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              iconSize: 28,
                            ),
                            isExpanded: true,
                            value: model.epsSeleccionada,
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor, // Fondo del menú desplegable
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.secondaryColor),
                              ),
                            ),

                            // Estilo de los ítems del menú
                            menuItemStyleData: const MenuItemStyleData(
                              overlayColor: WidgetStatePropertyAll(AppTheme.secondaryColor), // Color al pasar el dedo
                            ),
                            items: [
                              "Colsanitas",
                              "Compensar",
                              "Coomeva",
                              "Famisanar",
                              "Nueva EPS",
                              "Salud Total",
                              "Sanitas",
                              "Sura",
                              "Otro"
                            ].map((eps) {
                              return DropdownMenuItem<String>(
                                value: eps,
                                child: Text(eps),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                model.epsSeleccionada = value;
                              });
                            },
                            validator: (value) => value == null ? "Seleccione una EPS" : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.celularController,
                        label: "Celular",
                        icon: Icons.phone,
                        obscureText: false,
                        prefixText: "+57  ",
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Ingrese el celular";
                          if (!regexCel.hasMatch(v)) return "Número inválido (debe empezar en 3 y tener 10 dígitos)";
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),

                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.correoController,
                        label: "Correo",
                        icon: Icons.email,
                        obscureText: false,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Ingrese el correo";
                          if (!v.contains("@")) return "Correo inválido";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        controller: model.contrasenaController,
                        label: 'Contraseña',
                        obscureText: !model.passwordVisible,
                        icon: model.passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        togglePassword: () {
                          setState(() {
                            model.passwordVisible = !model.passwordVisible;
                          });
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Ingrese una contraseña";
                          if (v.length < 6) return "Mínimo 6 caracteres";
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Botón Guardar
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => model.guardarPaciente(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(215, 47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          label: const Text("Guardar"),
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    DateTime fechaSeleccionada = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Aseguramos que el contenido no desborde
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Seleccionar fecha",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Calendario adaptable
                      CalendarDatePicker(
                        initialDate: fechaSeleccionada,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        onDateChanged: (newDate) {
                          fechaSeleccionada = newDate;
                        },
                      ),

                      const SizedBox(height: 8),

                      // Botones personalizados
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(ctx).pop(fechaSeleccionada);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text("Aceptar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((fechaSeleccionadaFinal) {
      if (fechaSeleccionadaFinal != null) {
        model.fechaNacimientoController.text =
            model.fechaNacimientoController.text =
        "${fechaSeleccionadaFinal.year.toString().padLeft(4,'0')}/${fechaSeleccionadaFinal.month.toString().padLeft(2,'0')}/${fechaSeleccionadaFinal.day.toString().padLeft(2,'0')}";
        setState(() {}); // Refrescar UI
      }
    });
  }
}