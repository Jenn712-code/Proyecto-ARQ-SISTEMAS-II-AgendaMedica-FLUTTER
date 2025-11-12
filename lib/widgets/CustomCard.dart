import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';

class CustomCard extends StatelessWidget {
  final Color colorBorde;
  final IconData icono;
  final String titulo;
  final Widget contenido; // cuerpo interno flexible (Column, Row, Text...)
  final VoidCallback? onTap;
  final double bordeIzquierdo; // opcional: para estilo de "franja lateral"

  const CustomCard({
    Key? key,
    required this.colorBorde,
    required this.icono,
    required this.titulo,
    required this.contenido,
    this.onTap,
    this.bordeIzquierdo = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorBorde, width: bordeIzquierdo > 0 ? 0 : 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: bordeIzquierdo > 0
              ? Border(left: BorderSide(color: colorBorde, width: bordeIzquierdo))
              : null,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12.0),
          leading: Icon(icono, color: colorBorde, size: 30),
          title: Text(
            titulo,
            style: TextStyle(fontWeight: FontWeight.bold, color: colorBorde),
          ),
          subtitle: DefaultTextStyle(
            style: AppTheme.subtitleText,
            child: contenido,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
