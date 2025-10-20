import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/OlvideContraseñaModel.dart';
import '../theme/AppTheme.dart';

class OlvideContrasena extends StatefulWidget {
  const OlvideContrasena({super.key});

  @override
  State<OlvideContrasena> createState() => _OlvideContrasenaPageState();
}

class _OlvideContrasenaPageState extends State<OlvideContrasena> {
  final _formKey = GlobalKey<FormState>();
  final OlvideContrasenaModel model = OlvideContrasenaModel();

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  // === Construcción de la UI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contraseña",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
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
                controller: model.correoController,
                focusNode: model.correoFocus,
                label: "Correo electrónico",
                icon: Icons.email,
                obscure: false,
                readOnly: model.correoValidado,
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
                onPressed: model.procesando || model.correoValidado ? null : () {
                  if (_formKey.currentState!.validate()) {
                    model.validarCorreo(context, _formKey, setState);
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

              if (model.correoValidado) ...[
                Text(
                  'Ingrese el token recibido por correo eléctronico',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: model.tokenController,
                  focusNode: model.tokenFocus,
                  label: "Token recibido",
                  readOnly: model.tokenValidado,
                  icon: model.mostrarToken ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  obscure: !model.mostrarToken,
                  togglePassword: () {
                    setState(() {
                      model.mostrarToken = !model.mostrarToken;
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
                  onPressed: model.procesando || model.tokenValidado ? null : () {
                    if (_formKey.currentState!.validate()) {
                      model.validarToken(context, _formKey, setState);
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

              if (model.procesando) const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),

              if (model.tokenValidado) ...[
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
                  controller: model.nuevaContrasenaController,
                  focusNode: model.nuevaContrasenaFocus,
                  label: "Nueva contraseña",
                  icon: model.mostrarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  obscure: !model.mostrarContrasena,
                  togglePassword: () {
                    setState(() {
                      model.mostrarContrasena = !model.mostrarContrasena;
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
                  onPressed: model.procesando ? null : () {
                    if (_formKey.currentState!.validate()) {
                      model.restablecerContrasena(context, _formKey, setState);
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
