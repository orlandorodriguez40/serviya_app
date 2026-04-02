import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de texto
  final _nombreController = TextEditingController();
  final _usernameController =
      TextEditingController(); // NUEVO: Controlador para el alias
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  int? _rolSeleccionado;
  final List<String> _especialidadesSeleccionadas = [];

  final List<String> _opcionesTecnicas = [
    'Pintura',
    'Herreria',
    'Carpinteria',
    'Construccion',
    'Mecanica Automotriz',
    'Electricidad',
    'Electronica',
    'Plomeria',
    'Cristaleria',
    'Otros',
  ];

  static const Color azulIngenieria = Color(0xFF1A428A);

  Future<void> _registrarUsuario() async {
    // Validación de campos obligatorios
    if (_usernameController.text.isEmpty || _rolSeleccionado == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El nombre de usuario y el tipo de cuenta son obligatorios",
          ),
        ),
      );
      return;
    }

    final url = Uri.parse(
      "https://tupaginalista.com/serviya_api/auth/register.php",
    );

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "nombre": _nombreController.text,
          "username": _usernameController.text, // Enviamos el username elegido
          "email": _emailController.text,
          "password": _passwordController.text,
          "telefono": _telefonoController.text,
          "direccion": _direccionController.text,
          "rol_id": _rolSeleccionado,
          "especialidades": _especialidadesSeleccionadas,
        }),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "¡Registro exitoso! Ya puedes usar tu usuario para entrar",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${data['message']}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro ServiYa"),
        backgroundColor: azulIngenieria,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            _buildTextField("Nombre Completo", _nombreController, Icons.person),
            const SizedBox(height: 15),

            // NUEVO CAMPO: NOMBRE DE USUARIO
            _buildTextField(
              "Nombre de Usuario (Alias)",
              _usernameController,
              Icons.alternate_email,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              "Correo Electrónico",
              _emailController,
              Icons.email,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              "Contraseña",
              _passwordController,
              Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 15),
            _buildTextField("Teléfono", _telefonoController, Icons.phone),
            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "Regístrate como:",
                prefixIcon: const Icon(
                  Icons.assignment_ind,
                  color: azulIngenieria,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 2, child: Text("Usuario / Cliente")),
                DropdownMenuItem(value: 3, child: Text("Técnico / Prestador")),
              ],
              onChanged: (val) => setState(() {
                _rolSeleccionado = val;
                if (val == 2) _especialidadesSeleccionadas.clear();
              }),
            ),

            const SizedBox(height: 25),

            if (_rolSeleccionado == 3) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Especialidades Técnicas:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: azulIngenieria,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: _opcionesTecnicas.map((esp) {
                    return CheckboxListTile(
                      title: Text(esp, style: const TextStyle(fontSize: 14)),
                      value: _especialidadesSeleccionadas.contains(esp),
                      activeColor: azulIngenieria,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      onChanged: (bool? value) {
                        setState(() {
                          value == true
                              ? _especialidadesSeleccionadas.add(esp)
                              : _especialidadesSeleccionadas.remove(esp);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulIngenieria,
                ),
                onPressed: _registrarUsuario,
                child: const Text(
                  "CREAR CUENTA",
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: azulIngenieria),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
