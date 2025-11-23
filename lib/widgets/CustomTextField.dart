import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/AppTheme.dart';

enum IconAlignment { start, end }

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconAlignment iconAlignment;
  final TextInputType keyboardType;
  final String? suffixText;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final double widthFactor;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.iconAlignment = IconAlignment.end,
    this.keyboardType = TextInputType.text,
    this.suffixText,
    this.prefixText,
    this.inputFormatters,
    this.widthFactor = 0.80,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          prefixText: prefixText,
          prefixIcon: iconAlignment == IconAlignment.start
              ? Icon(icon, color: AppTheme.primaryColor)
              : null,
          suffixIcon: iconAlignment == IconAlignment.end
              ? Icon(icon, color: AppTheme.primaryColor)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
