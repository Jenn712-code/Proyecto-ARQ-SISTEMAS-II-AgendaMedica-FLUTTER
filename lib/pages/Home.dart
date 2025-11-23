import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/pages/crearPaciente.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/AppTheme.dart';
import 'Dashboard.dart';
import '../controllers/HomeModel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'OlvideContrasena.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageModel model;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    model = HomePageModel();
    model.limpiarCampos(_formKey);
  }

  @override
  void dispose() {
    model.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
        child: KeyboardListener(
        focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: (event) async {
              if (event.logicalKey == LogicalKeyboardKey.enter && event is KeyDownEvent) {
                if (_formKey.currentState!.validate()) {
                  final success = await model.iniciarSesion(context);
                    if (success && context.mounted) {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Dashboard()),
                    );
                  }
                }
              }
            },
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 90% del ancho de la pantalla
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),

                child: Form(
                  key: _formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icono.png',
                          width: 250,
                          height: 250,
                        ),

                        // Título
                        Text(
                          'Iniciar Sesión',
                          style: AppTheme.snapStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Accede a tu Agenda Médica personal',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            fontFamily: GoogleFonts
                                .roboto()
                                .fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Campo correo
                        _buildTextField(
                          controller: model.txtCorreoController,
                          focusNode: model.txtCorreoFocus,
                          label: 'Correo',
                          icon: Icons.email,
                          obscure: false,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return "El correo no puede estar vacío";
                            }
                            if (!value.contains("@")) {
                              return "El correo debe contener @";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Campo contraseña
                        _buildTextField(
                          controller: model.txtContrasenaController,
                          focusNode: model.txtContrasenaFocus,
                          label: 'Contraseña',
                          icon: model.passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          obscure: !model.passwordVisible,
                          togglePassword: () {
                            setState(() {
                              model.passwordVisible = !model.passwordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "La contraseña no puede estar vacía";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Botón Ingresar
                        ElevatedButton.icon(
                          onPressed: () async{
                            if (_formKey.currentState!.validate()) {
                              final ok = await model.iniciarSesion(context);
                              if (ok) {
                                model.limpiarCampos(_formKey);
                                // Ir al Dashboard
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Dashboard()),
                                );
                              }
                            }
                          },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(215, 47),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: const Icon(Icons.login, size: 20),
                            label: const Text("Ingresar"),
                            iconAlignment: IconAlignment.end,
                          ),

                          const SizedBox(height: 20),

                          // Botón olvidar contraseña
                          TextButton.icon(
                            onPressed: (){
                              model.limpiarCampos(_formKey);
                              _formKey.currentState?.reset();
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OlvideContrasena()),
                              );
                            },
                            icon: const FaIcon(
                                FontAwesomeIcons.solidFaceSadTear, size: 20),
                            iconAlignment: IconAlignment.end,
                            label: const Text("Olvidé la contraseña"),
                          ),

                          const SizedBox(height: 5),

                          // Botón registro
                          TextButton(
                            onPressed: (){
                              model.limpiarCampos(_formKey);
                              _formKey.currentState?.reset();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const crearPaciente()),
                              );
                            },
                            child: const Text("No tengo cuenta, registrarme"),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required bool obscure,
    VoidCallback? togglePassword,
    String? Function(String?)? validator,
  }) {
    return FractionallySizedBox(
      widthFactor: 0.80, // 80% del ancho del contenedor
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        validator: validator,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.snapStyle(
            fontSize: 20,
            color: AppTheme.primaryColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          filled: true,
          fillColor: AppTheme.secondaryColor,
          suffixIcon: togglePassword != null
              ? IconButton(
            icon: Icon(icon, color: AppTheme.primaryColor),
            onPressed: togglePassword,
          )
              : Icon(icon, color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}