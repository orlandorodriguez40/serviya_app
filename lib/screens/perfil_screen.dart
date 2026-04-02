import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Colores corporativos consistentes
  static const Color azulIngenieria = Color(0xFF1A428A);
  static const Color grisFondo = Color(0xFFF5F7FA);
  static const Color blancoPuro = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(color: blancoPuro, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulIngenieria,
        iconTheme: const IconThemeData(color: blancoPuro),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar del Usuario
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: azulIngenieria,
                child: Icon(Icons.person, size: 60, color: blancoPuro),
              ),
            ),
            const SizedBox(height: 30),

            // Campos de edición
            _buildEditField(
              "Nombre Completo",
              "Orlando Developer",
              Icons.person_outline,
            ),
            const SizedBox(height: 15),
            _buildEditField("Teléfono", "+58 412 1234567", Icons.phone_android),
            const SizedBox(height: 15),
            _buildEditField("Ciudad", "Mérida", Icons.location_city),

            const SizedBox(height: 40),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Datos actualizados correctamente"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulIngenieria,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Guardar Cambios",
                  style: TextStyle(
                    color: blancoPuro,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para los campos de texto
  Widget _buildEditField(String label, String initialValue, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: azulIngenieria,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: blancoPuro,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          controller: TextEditingController(text: initialValue),
        ),
      ],
    );
  }
}
