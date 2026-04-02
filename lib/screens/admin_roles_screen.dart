import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  static const Color azulProfundo = Color(0xFF0D1B2A);
  List<dynamic> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_gestionar_roles.php",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _roles = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error al cargar roles: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processRole(String action, {int? id, String? nombre}) async {
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_gestionar_roles.php",
      );
      final response = await http.post(
        url,
        body: jsonEncode({"action": action, "id": id, "nombre": nombre}),
      );

      // CORRECCIÓN: Ahora usamos 'response' para validar y evitar el error
      if (response.statusCode == 200) {
        debugPrint("Operación $action exitosa");
        _fetchRoles();
      } else {
        debugPrint("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error al procesar rol: $e");
    }
  }

  void _showRoleDialog(dynamic role) {
    TextEditingController controller = TextEditingController(
      text: role?['nombre'] ?? "",
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(role == null ? "Nuevo Rol" : "Editar Rol"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nombre del Rol (Ej: Supervisor)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (role == null) {
                _processRole("create", nombre: controller.text);
              } else {
                _processRole("update", id: role['id'], nombre: controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
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
          "Gestión de Roles",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulProfundo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulProfundo,
        onPressed: () {
          _showRoleDialog(null);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRoles,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final r = _roles[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: azulProfundo.withAlpha(30),
                        child: Text(
                          r['id'].toString(),
                          style: const TextStyle(color: azulProfundo),
                        ),
                      ),
                      title: Text(
                        r['nombre'] ?? "Sin nombre",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showRoleDialog(r);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _processRole("delete", id: r['id']);
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
