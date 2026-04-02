import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminSolicitudesCrudScreen extends StatefulWidget {
  const AdminSolicitudesCrudScreen({super.key});

  @override
  State<AdminSolicitudesCrudScreen> createState() =>
      _AdminSolicitudesCrudScreenState();
}

class _AdminSolicitudesCrudScreenState
    extends State<AdminSolicitudesCrudScreen> {
  static const Color azulProfundo = Color(0xFF0D1B2A);
  List<dynamic> _solicitudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSolicitudes();
  }

  Future<void> _fetchSolicitudes() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_gestionar_solicitudes.php",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _solicitudes = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error al cargar solicitudes: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSolicitud(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_gestionar_solicitudes.php",
      );
      final response = await http.post(url, body: jsonEncode(body));

      // Usamos 'response' para validar y eliminar el warning de variable no usada
      if (response.statusCode == 200) {
        debugPrint("Respuesta exitosa: ${response.body}");
        _fetchSolicitudes();
      } else {
        debugPrint("Error en servidor: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error al actualizar solicitud: $e");
    }
  }

  Future<void> _deleteSolicitud(int id) async {
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_gestionar_solicitudes.php",
      );
      final response = await http.post(
        url,
        body: jsonEncode({"action": "delete", "id": id}),
      );

      if (response.statusCode == 200) {
        debugPrint("Eliminado correctamente");
        _fetchSolicitudes();
      }
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
  }

  void _showEditDialog(dynamic item) {
    TextEditingController titleCtrl = TextEditingController(
      text: item['titulo'],
    );
    TextEditingController descCtrl = TextEditingController(
      text: item['descripcion'],
    );
    String currentStatus = (item['status'] ?? "pendiente")
        .toString()
        .toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Solicitud #${item['id']}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                // --- CAMBIO CLAVE: initialValue en lugar de value ---
                initialValue:
                    [
                      "pendiente",
                      "aceptado",
                      "finalizado",
                    ].contains(currentStatus)
                    ? currentStatus
                    : "pendiente",
                items: ["pendiente", "aceptado", "finalizado"]
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    currentStatus = val;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Estado del Servicio",
                  border: OutlineInputBorder(),
                ),
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
              _updateSolicitud({
                "action": "update",
                "id": item['id'],
                "titulo": titleCtrl.text,
                "descripcion": descCtrl.text,
                "status": currentStatus,
                "calificacion": item['calificacion'],
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Actualizar",
              style: TextStyle(color: Colors.white),
            ),
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
          "Módulo Solicitudes",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulProfundo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSolicitudes,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _solicitudes.length,
                itemBuilder: (context, index) {
                  final s = _solicitudes[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: azulProfundo.withAlpha(20),
                        child: const Icon(
                          Icons.build,
                          size: 18,
                          color: azulProfundo,
                        ),
                      ),
                      title: Text(
                        s['titulo'] ?? "Sin título",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Cliente: ${s['cliente_nombre'] ?? 'N/A'}\nEstado: ${s['status']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(s),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              if (s['id'] != null) {
                                _deleteSolicitud(s['id']);
                              }
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
