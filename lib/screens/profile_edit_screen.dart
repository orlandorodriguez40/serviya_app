import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserModel usuario;

  const ProfileEditScreen({super.key, required this.usuario});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  bool _isLoading = false;
  static const Color azulIngenieria = Color(0xFF1A428A);

  final List<String> _opcionesEspecialidad = [
    "Plomeria",
    "Electricidad",
    "Pintura",
    "Carpinteria",
    "Albanileria",
    "Refrigeracion",
  ];
  List<String> _especialidadesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _telefonoController = TextEditingController(text: widget.usuario.telefono);
    _direccionController = TextEditingController(
      text: widget.usuario.direccion,
    );

    if (widget.usuario.especialidades.isNotEmpty) {
      _especialidadesSeleccionadas = widget.usuario.especialidades.split(', ');
    }
  }

  // MÉTODO ACTUALIZADO: Ahora usa la variable y el servicio real
  Future<void> _guardarCambios() async {
    setState(() => _isLoading = true);

    // 1. Convertimos la lista de especialidades a un solo String
    String especialidadesString = _especialidadesSeleccionadas.join(', ');

    try {
      // 2. Llamamos al servicio (Asegúrate de que updateProfile reciba estos parámetros)
      final authService = AuthService();

      // Creamos un objeto temporal con los nuevos datos para enviar
      final usuarioActualizado = UserModel(
        id: widget.usuario.id,
        nombre: _nombreController.text,
        email: widget.usuario.email,
        username: widget.usuario.username,
        rolId: widget.usuario.rolId,
        telefono: _telefonoController.text,
        direccion: _direccionController.text,
        especialidades: especialidadesString, // Usamos la variable aquí
      );

      final exito = await authService.updateProfile(usuarioActualizado);

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Perfil actualizado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Regresa a la pantalla anterior
      } else {
        throw Exception("El servidor no pudo procesar la solicitud");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error al guardar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar mi Perfil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulIngenieria,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: azulIngenieria),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFotoPerfil(),
                  const SizedBox(height: 30),
                  _buildTextField(
                    "Nombre Completo",
                    _nombreController,
                    Icons.person,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField("Teléfono", _telefonoController, Icons.phone),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Dirección",
                    _direccionController,
                    Icons.location_on,
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Mis Especialidades",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: azulIngenieria,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildChecklist(),

                  const SizedBox(height: 40),
                  _buildBotonGuardar(),
                ],
              ),
            ),
    );
  }

  Widget _buildFotoPerfil() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: azulIngenieria.withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 60, color: azulIngenieria),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: azulIngenieria,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icono,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: azulIngenieria),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: azulIngenieria, width: 2),
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _opcionesEspecialidad.map((especialidad) {
          return CheckboxListTile(
            title: Text(especialidad),
            activeColor: azulIngenieria,
            value: _especialidadesSeleccionadas.contains(especialidad),
            onChanged: (bool? valor) {
              setState(() {
                if (valor == true) {
                  _especialidadesSeleccionadas.add(especialidad);
                } else {
                  _especialidadesSeleccionadas.remove(especialidad);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: azulIngenieria,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "GUARDAR CAMBIOS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}
