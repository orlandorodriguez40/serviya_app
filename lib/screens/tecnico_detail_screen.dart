import 'package:flutter/material.dart';
import '../models/user_model.dart';

class TecnicoDetailScreen extends StatelessWidget {
  final UserModel tecnico;

  const TecnicoDetailScreen({super.key, required this.tecnico});

  static const Color azulIngenieria = Color(0xFF1A428A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tecnico.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: azulIngenieria,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeccion(
                    Icons.work,
                    "Especialidades",
                    tecnico.especialidades,
                  ),
                  const SizedBox(height: 20),
                  _buildSeccion(Icons.phone, "Teléfono", tecnico.telefono),
                  const SizedBox(height: 20),
                  _buildSeccion(
                    Icons.location_on,
                    "Dirección",
                    tecnico.direccion,
                  ),
                  const SizedBox(height: 30),
                  _buildBotonContacto(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        // ✨ Reemplazado withOpacity por withValues
        color: azulIngenieria.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: azulIngenieria,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            tecnico.nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "@${tecnico.username}", // ✨ Ahora reconocido por el modelo
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🛠️ Solución al error de 'SizedBox':
              // Usamos '...' para "esparcir" la lista de iconos dentro de los children del Row
              ...List.generate(
                5,
                (index) =>
                    const Icon(Icons.star, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                "4.8 (12 reseñas)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion(IconData icono, String titulo, String contenido) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: azulIngenieria),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                contenido.isEmpty ? "No especificado" : contenido,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotonContacto() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          // Lógica para contactar (WhatsApp o Llamada)
        },
        icon: const Icon(Icons.message, color: Colors.white),
        label: const Text(
          "CONTACTAR AHORA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: azulIngenieria,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
