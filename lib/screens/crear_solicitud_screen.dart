import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({super.key});

  @override
  State<CrearSolicitudScreen> createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends State<CrearSolicitudScreen> {
  static const Color azulIngenieria = Color(0xFF1A428A);
  static const Color grisFondo = Color(0xFFF5F7FA);
  static const Color blancoPuro = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  final _fechaController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _enviarSolicitud() async {
    // CORRECCIÓN: Bloque en el if de validación
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception("No se encontró ID de usuario");
      }

      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/solicitudes/guardar_solicitud.php",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cliente_id": userId,
          "titulo": _tituloController.text.trim(),
          "descripcion": _descController.text.trim(),
          "fecha": _fechaController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // CORRECCIÓN: Bloque en el if de mounted
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Solicitud guardada con éxito!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(data['message'] ?? "Error desconocido");
      }
    } catch (e) {
      // CORRECCIÓN: Bloque en el if de mounted para error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // CORRECCIÓN: Bloque en el if de mounted para setState final
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        title: const Text(
          "Nueva Solicitud",
          style: TextStyle(color: blancoPuro, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulIngenieria,
        iconTheme: const IconThemeData(color: blancoPuro),
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: azulIngenieria),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Describe qué ayuda necesitas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: azulIngenieria,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildInputField(
                      "Título del Servicio (Ej: Reparar PC)",
                      _tituloController,
                      Icons.title,
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      "Describe el problema detalladamente...",
                      _descController,
                      Icons.description_outlined,
                      maxLines: 4,
                      validator: (v) =>
                          v!.isEmpty ? 'Por favor, describe tu problema' : null,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _seleccionarFecha(context),
                      child: AbsorbPointer(
                        child: _buildInputField(
                          "Fecha sugerida",
                          _fechaController,
                          Icons.calendar_month_outlined,
                          validator: (v) =>
                              v!.isEmpty ? 'Selecciona una fecha' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _enviarSolicitud,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulIngenieria,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "CREAR SOLICITUD 🚀",
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
            ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: blancoPuro,
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: azulIngenieria, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
}
