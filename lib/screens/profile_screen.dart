import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Colores de Marca
  static const Color azulIngenieria = Color(0xFF1A428A);

  // Controladores para editar los campos
  final TextEditingController _nombreController = TextEditingController(
    text: "Orlando Rodriguez",
  );
  final TextEditingController _correoController = TextEditingController(
    text: "orlandorodriguez@gmail.com",
  );
  final TextEditingController _telefonoController = TextEditingController(
    text: "+584247121387",
  );
  final TextEditingController _direccionController = TextEditingController(
    text: "El Chama",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mi Perfil Técnico",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulIngenieria,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // Avatar Circular con Inicial
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0x1A1A428A),
              child: Icon(Icons.person, size: 60, color: azulIngenieria),
            ),
            const SizedBox(height: 30),

            // Campos Editables
            _buildEditField(
              "Nombre Completo",
              _nombreController,
              Icons.person_outline,
            ),
            _buildEditField(
              "Correo Electrónico",
              _correoController,
              Icons.email_outlined,
            ),
            _buildEditField(
              "Teléfono / WhatsApp",
              _telefonoController,
              Icons.phone_android_outlined,
            ),
            _buildEditField(
              "Dirección (Hogar o Empresa)",
              _direccionController,
              Icons.location_on_outlined,
            ),

            const SizedBox(height: 40),

            // Botón ACTUALIZAR DATOS
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulIngenieria,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  // Aquí irá la lógica para enviar el UPDATE a tu PHP
                  debugPrint(
                    "Actualizando datos de: ${_nombreController.text}",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("¡Datos actualizados correctamente!"),
                    ),
                  );
                },
                child: const Text(
                  "ACTUALIZAR DATOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de edición
  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: azulIngenieria),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: azulIngenieria, width: 2),
          ),
        ),
      ),
    );
  }
}
