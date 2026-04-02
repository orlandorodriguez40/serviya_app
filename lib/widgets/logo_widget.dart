import 'package:flutter/material.dart';

class ServiYaLogo extends StatelessWidget {
  final double size;

  const ServiYaLogo({super.key, this.size = 150.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logotipo.png',
      width: size,
      height: size,
      // Mantiene la proporción del logo redondo
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Respaldo visual con el Azul Ingeniería si la imagen falta
        return Icon(
          Icons.engineering_rounded,
          size: size,
          color: const Color(0xFF1A428A),
        );
      },
    );
  }
}
