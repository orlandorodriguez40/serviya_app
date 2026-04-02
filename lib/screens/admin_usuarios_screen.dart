import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  static const Color azulAdmin = Color(0xFF0D1B2A);

  List<dynamic> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_listar_usuarios.php",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Gestión de Usuarios",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: azulAdmin,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(icon: Icon(Icons.engineering), text: "Técnicos"),
              Tab(icon: Icon(Icons.person), text: "Clientes"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildUserList(3), // nivel_id para Técnicos
                  _buildUserList(4), // nivel_id para Clientes
                ],
              ),
      ),
    );
  }

  Widget _buildUserList(int nivelId) {
    final filteredUsers = _usuarios
        .where((u) => int.tryParse(u['nivel_id'].toString()) == nivelId)
        .toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text("No hay usuarios en esta categoría"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: nivelId == 3
                  ? Colors.orange.withAlpha(40)
                  : Colors.blue.withAlpha(40),
              child: Icon(
                nivelId == 3 ? Icons.handyman : Icons.person,
                color: nivelId == 3 ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(
              user['nombre'] ?? "Sin nombre",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${user['email']}\nTel: ${user['telefono'] ?? 'N/A'}",
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: azulAdmin),
              onPressed: () {
                // Aquí podrías abrir un diálogo para editar o suspender
              },
            ),
          ),
        );
      },
    );
  }
}
