import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_agenda_medica/pages/Home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/AppTheme.dart';

class OlvideContrasena extends StatefulWidget {
  const OlvideContrasena({super.key});

  @override
  State<OlvideContrasena> createState() => _OlvideContrasenaPageState();
}

class _OlvideContrasenaPageState extends State<OlvideContrasena> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _nuevaContrasenaController = TextEditingController();

  // Focus nodes
  final FocusNode _correoFocus = FocusNode();
  final FocusNode _tokenFocus = FocusNode();
  final FocusNode _nuevaContrasenaFocus = FocusNode();

  // Estados
  bool _correoValidado = false;
  bool _tokenValidado = false;
  bool _procesando = false;
  bool _ocultarToken = true;
  bool _mostrarContrasena = false;

  // URL base
  final String urlBase = "${ApiConfig.baseUrl}/IniciarSesion";

  // === Paso 1: Validar correo ===
  Future<void> _validarCorreo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _procesando = true);
    final correo = _correoController.text.trim();

    final response = await http.post(
      Uri.parse("$urlBase/olvide_contrasena"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"pacCorreo": correo}),
    );

    setState(() => _procesando = false);

    final data = jsonDecode(response.body);
    final mensaje = data['mensaje'] ?? "Error al validar el correo";

    if (response.statusCode == 200) {
      _showDialog("Correo enviado", mensaje);
      setState(() => _correoValidado = true);
      FocusScope.of(context).unfocus();
    } else if (response.statusCode == 404) {
      _showDialog("Correo no registrado", mensaje);
    } else {
      _showDialog("Error", mensaje);
    }
  }

  // === Paso 2: Validar token ===
  Future<void> _validarToken() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _procesando = true);

    final response = await http.post(
      Uri.parse("$urlBase/restablecer_contrasena"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pacCorreo": _correoController.text.trim(),
        "token": _tokenController.text.trim(),
        "nuevaContrasena": "",
      }),
    );

    setState(() => _procesando = false);

    final data = jsonDecode(response.body);
    final mensaje = data['mensaje'] ?? "Error al validar el token";

    if (response.statusCode == 200) {
      _showDialog("Token validado", mensaje);
      setState(() => _tokenValidado = true);
      FocusScope.of(context).unfocus();
    } else if (response.statusCode == 401) {
      _showDialog("Token incorrecto", mensaje);
    } else {
      _showDialog("Error", mensaje);
    }
  }

  // === Paso 3: Restablecer contraseña ===
  Future<void> _restablecerContrasena() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _procesando = true);
    final correo = _correoController.text.trim();
    final token = _tokenController.text.trim();
    final nuevaContrasena = _nuevaContrasenaController.text.trim();

    final response = await http.post(
      Uri.parse("$urlBase/restablecer_contrasena"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pacCorreo": correo,
        "token": token,
        "nuevaContrasena": nuevaContrasena,
      }),
    );

    setState(() => _procesando = false);

    final data = jsonDecode(response.body);
    final mensaje = data['mensaje'] ?? "Error al restablecer contraseña";

    if (response.statusCode == 200) {
      _showDialog("Éxito", mensaje);
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    } else if (response.statusCode == 401) {
      _showDialog("Token incorrecto", mensaje);
    } else {
      _showDialog("Error", mensaje);
    }
  }

  // === Diálogo reutilizable ===
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.snapStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Construcción de la UI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(
                'Ingrese su correo electrónico registrado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: GoogleFonts.roboto().fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              const SizedBox(height: 20),

              // === Campo correo ===
              _buildTextField(
                controller: _correoController,
                focusNode: _correoFocus,
                label: "Correo electrónico",
                icon: Icons.email,
                obscure: false,
                readOnly: _correoValidado,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un correo electrónico';
                  }
                  if (!value.contains('@')) {
                    return "El correo debe contener '@'";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _procesando || _correoValidado ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _validarCorreo();
                  }
                },
                icon: const Icon(Icons.email, color: Colors.white),
                iconAlignment: IconAlignment.end,
                label: const Text(
                  "Validar correo",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(height: 40, color: Colors.white),

              if (_correoValidado) ...[
                Text(
                  'Ingrese el token recibido por correo eléctronico',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _tokenController,
                  focusNode: _tokenFocus,
                  label: "Token recibido",
                  readOnly: _tokenValidado,
                  icon: _mostrarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  obscure: !_mostrarContrasena,
                  togglePassword: () {
                    setState(() {
                      _mostrarContrasena = !_mostrarContrasena;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el token recibido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _procesando || _tokenValidado ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _validarToken();
                    }
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  iconAlignment: IconAlignment.end,
                  label: const Text(
                    "Validar token",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              if (_procesando) const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),

              if (_tokenValidado) ...[
                const Divider(height: 40, color: Colors.white),
                Text(
                  'Ingrese una nueva contraseña',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nuevaContrasenaController,
                  focusNode: _nuevaContrasenaFocus,
                  label: "Nueva contraseña",
                  icon: _mostrarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  obscure: !_mostrarContrasena,
                  togglePassword: () {
                    setState(() {
                      _mostrarContrasena = !_mostrarContrasena;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una nueva contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _procesando ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _restablecerContrasena();
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  iconAlignment: IconAlignment.end,
                  label: const Text(
                    "Restablecer contraseña",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // === Widget de campo reutilizable ===
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required bool obscure,
    bool readOnly = false,
    VoidCallback? togglePassword,
    String? Function(String?)? validator,
  }) {
    return FractionallySizedBox(
      widthFactor: 0.80,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        readOnly: readOnly,
        validator: validator,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.snapStyle(
            fontSize: 18,
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
