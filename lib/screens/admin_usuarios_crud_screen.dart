import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUsuariosCrudScreen extends StatefulWidget {
  const AdminUsuariosCrudScreen({super.key});

  @override
  State<AdminUsuariosCrudScreen> createState() =>
      _AdminUsuariosCrudScreenState();
}

class _AdminUsuariosCrudScreenState extends State<AdminUsuariosCrudScreen> {
  static const Color azulProfundo = Color(0xFF0D1B2A);
  List<dynamic> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_listar_usuarios.php",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _usuarios = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando usuarios: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processUsuario(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_gestionar_usuarios.php",
      );
      final response = await http.post(url, body: jsonEncode(body));

      if (response.statusCode == 200) {
        debugPrint("Respuesta servidor: ${response.body}");
        _fetchUsuarios();
      }
    } catch (e) {
      debugPrint("Error en proceso: $e");
    }
  }

  void _showUserForm(dynamic user) {
    TextEditingController nameCtrl = TextEditingController(
      text: user?['nombre'] ?? "",
    );
    TextEditingController emailCtrl = TextEditingController(
      text: user?['email'] ?? "",
    );
    TextEditingController telCtrl = TextEditingController(
      text: user?['telefono'] ?? "",
    );

    int selectedRol = int.tryParse(user?['rol_id']?.toString() ?? "1") ?? 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? "Nuevo Usuario" : "Editar Usuario"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: telCtrl,
                decoration: const InputDecoration(labelText: "Teléfono"),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                // CAMBIO CLAVE: Usamos initialValue en lugar de value para cumplir con Flutter 3.33+
                initialValue: [1, 2, 3].contains(selectedRol) ? selectedRol : 1,
                decoration: const InputDecoration(
                  labelText: "Rol de Usuario",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Cliente")),
                  DropdownMenuItem(value: 2, child: Text("Técnico")),
                  DropdownMenuItem(value: 3, child: Text("Administrador")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    selectedRol = val;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: azulProfundo),
            onPressed: () {
              _processUsuario({
                "action": user == null ? "create" : "update",
                "id": user?['id'],
                "nombre": nameCtrl.text,
                "email": emailCtrl.text,
                "telefono": telCtrl.text,
                "rol_id": selectedRol,
                "password": "123",
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestión de Usuarios",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulProfundo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulProfundo,
        onPressed: () => _showUserForm(null),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUsuarios,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _usuarios.length,
                itemBuilder: (context, index) {
                  final u = _usuarios[index];
                  final int rId =
                      int.tryParse(u['rol_id']?.toString() ?? "1") ?? 1;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: azulProfundo.withAlpha(20),
                        child: Text(
                          u['id'].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: azulProfundo,
                          ),
                        ),
                      ),
                      title: Text(
                        u['nombre'] ?? "N/A",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Rol: ${rId == 3 ? 'Admin' : (rId == 2 ? 'Técnico' : 'Cliente')}\n${u['email']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUserForm(u),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _processUsuario({
                                "action": "delete",
                                "id": u['id'],
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
