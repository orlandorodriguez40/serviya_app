import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilClienteScreen extends StatefulWidget {
  const PerfilClienteScreen({super.key});

  @override
  State<PerfilClienteScreen> createState() => _PerfilClienteScreenState();
}

class _PerfilClienteScreenState extends State<PerfilClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _isSaving = false;
  static const Color azulIngenieria = Color(0xFF1A428A);

  @override
  void initState() {
    super.initState();
    _cargarDatosLocales();
  }

  Future<void> _cargarDatosLocales() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreController.text = prefs.getString('userName') ?? "";
      _emailController.text = prefs.getString('userEmail') ?? "";
      _telefonoController.text = prefs.getString('userPhone') ?? "";
      _direccionController.text = prefs.getString('userAddress') ?? "";
    });
  }

  Future<void> _actualizarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/usuarios/actualizar_perfil.php",
      );

      final response = await http.post(
        url,
        body: {
          'id': userId,
          'nombre': _nombreController.text,
          'email': _emailController.text,
          'telefono': _telefonoController.text,
          'direccion': _direccionController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Actualizamos SharedPreferences para que los cambios se vean en toda la App
        await prefs.setString('userName', _nombreController.text);
        await prefs.setString('userEmail', _emailController.text);
        await prefs.setString('userPhone', _telefonoController.text);
        await prefs.setString('userAddress', _direccionController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Perfil actualizado!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Mi Perfil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulIngenieria,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: azulIngenieria,
                child: Icon(
                  Icons.person_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              // CAMPO NOMBRE
              _buildTextField(
                controller: _nombreController,
                label: "Nombre Completo",
                icon: Icons.person,
                validator: (v) =>
                    v!.isEmpty ? "El nombre es obligatorio" : null,
              ),

              // CAMPO EMAIL
              _buildTextField(
                controller: _emailController,
                label: "Correo Electrónico",
                icon: Icons.email,
                type: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? "Email inválido" : null,
              ),

              // CAMPO TELÉFONO
              _buildTextField(
                controller: _telefonoController,
                label: "Teléfono / Celular",
                icon: Icons.phone,
                type: TextInputType.phone,
              ),

              // CAMPO DIRECCIÓN
              _buildTextField(
                controller: _direccionController,
                label: "Dirección de Residencia",
                icon: Icons.location_on,
                maxLines: 2,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _actualizarPerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulIngenieria,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ACTUALIZAR DATOS",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: azulIngenieria),
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
