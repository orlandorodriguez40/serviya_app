import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTecnicoScreen extends StatefulWidget {
  const HomeTecnicoScreen({super.key});

  @override
  State<HomeTecnicoScreen> createState() => _HomeTecnicoScreenState();
}

class _HomeTecnicoScreenState extends State<HomeTecnicoScreen>
    with SingleTickerProviderStateMixin {
  // Colores corporativos
  static const Color azulTecnico = Color(0xFF0D47A1);
  static const Color grisFondo = Color(0xFFF0F2F5);
  static const Color naranjaClaro = Color(0xFFFFF3E0);
  static const Color verdeClaro = Color(0xFFE8F5E9);
  static const Color grisClaro = Color(0xFFEEEEEE);

  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _disponibles = [];
  List<dynamic> _misTrabajos = [];
  List<dynamic> _historial = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await _cargarDisponibles();
    await _cargarMisTrabajos();
    await _cargarHistorial();
  }

  Future<void> _cargarDisponibles() async {
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(
          "https://tupaginalista.com/serviya_api/solicitudes/listar_pendientes.php",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && mounted) {
        setState(() => _disponibles = data['data']);
      }
    } catch (e) {
      debugPrint("Error Disponibles: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cargarMisTrabajos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idTecnico = prefs.getString('userId');
    if (idTecnico == null || idTecnico.isEmpty) {
      return;
    }
    try {
      final res = await http.get(
        Uri.parse(
          "https://tupaginalista.com/serviya_api/solicitudes/listar_trabajos_tecnico.php?tecnico_id=$idTecnico",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && mounted) {
        setState(() => _misTrabajos = data['data']);
      }
    } catch (e) {
      debugPrint("Error Mis Trabajos: $e");
    }
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idTecnico = prefs.getString('userId');
    if (idTecnico == null) {
      return;
    }
    try {
      final res = await http.get(
        Uri.parse(
          "https://tupaginalista.com/serviya_api/solicitudes/listar_historial_tecnico.php?tecnico_id=$idTecnico",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && mounted) {
        setState(() => _historial = data['data']);
      }
    } catch (e) {
      debugPrint("Error Historial: $e");
    }
  }

  Future<void> _gestionarTrabajo(String id, String accion) async {
    final prefs = await SharedPreferences.getInstance();
    final idTecnico = prefs.getString('userId');
    if (idTecnico == null) {
      return;
    }

    final url = (accion == 'aceptar')
        ? "https://tupaginalista.com/serviya_api/solicitudes/aceptar_solicitud.php"
        : "https://tupaginalista.com/serviya_api/solicitudes/finalizar_trabajo.php";

    try {
      final res = await http.post(
        Uri.parse(url),
        body: {'solicitud_id': id, 'tecnico_id': idTecnico},
      );
      if (!mounted) {
        return;
      }
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accion == 'aceptar'
                  ? "¡Servicio Aceptado!"
                  : "¡Trabajo Finalizado!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAll();
        if (accion == 'aceptar') {
          _tabController.animateTo(1);
        }
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de conexión"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: azulTecnico,
        elevation: 0,
        title: const Text(
          "Panel Técnico",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: "Disponibles"),
            Tab(icon: Icon(Icons.handyman), text: "Mis Trabajos"),
            Tab(icon: Icon(Icons.history), text: "Historial"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLista(_disponibles, "disponible"),
          _buildLista(_misTrabajos, "proceso"),
          _buildLista(_historial, "finalizado"),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/perfil');
                },
                icon: const Icon(Icons.person, color: azulTecnico),
                label: const Text(
                  "Mi Perfil",
                  style: TextStyle(color: azulTecnico),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Salir", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLista(List<dynamic> lista, String tipo) {
    if (_isLoading && tipo == "disponible") {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: lista.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                const Icon(
                  Icons.assignment_late_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const Center(
                  child: Text(
                    "No hay registros",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final item = lista[i];
                Color bgIcono = naranjaClaro;
                IconData icono = Icons.build;
                Color colorIcono = Colors.orange;

                if (tipo == "proceso") {
                  bgIcono = verdeClaro;
                  icono = Icons.pending_actions;
                  colorIcono = Colors.green;
                } else if (tipo == "finalizado") {
                  bgIcono = grisClaro;
                  icono = Icons.check_circle_outline;
                  colorIcono = Colors.blueGrey;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: bgIcono,
                      child: Icon(icono, color: colorIcono, size: 20),
                    ),
                    title: Text(
                      item['titulo'] ?? "Servicio",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("ID #${item['id']} - ${tipo.toUpperCase()}"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "DATOS DEL CLIENTE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.phone,
                                color: Colors.green,
                              ),
                              title: Text(item['telefono'] ?? "Sin teléfono"),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                              title: Text(item['direccion'] ?? "Sin dirección"),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "DESCRIPCIÓN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(item['descripcion'] ?? "Sin detalles"),
                            const SizedBox(height: 20),

                            if (tipo != "finalizado") ...[
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: tipo == "disponible"
                                        ? Colors.green
                                        : azulTecnico,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _gestionarTrabajo(
                                      item['id'].toString(),
                                      tipo == "disponible"
                                          ? 'aceptar'
                                          : 'finalizar',
                                    );
                                  },
                                  icon: Icon(
                                    tipo == "disponible"
                                        ? Icons.add_task
                                        : Icons.done_all,
                                  ),
                                  label: Text(
                                    tipo == "disponible"
                                        ? "ACEPTAR SERVICIO"
                                        : "FINALIZAR TRABAJO",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // --- SECCIÓN DE ESTRELLAS DINÁMICAS ---
                              Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      "VALORACIÓN DEL CLIENTE",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        // Leemos la calificación de la base de datos
                                        int rating =
                                            int.tryParse(
                                              item['calificacion'].toString(),
                                            ) ??
                                            0;
                                        return Icon(
                                          index < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: index < rating
                                              ? Colors.amber
                                              : Colors.grey,
                                          size: 30,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      (int.tryParse(
                                                    item['calificacion']
                                                        .toString(),
                                                  ) ??
                                                  0) >
                                              0
                                          ? "¡Servicio Calificado!"
                                          : "Pendiente por calificación",
                                      style: TextStyle(
                                        color:
                                            (int.tryParse(
                                                      item['calificacion']
                                                          .toString(),
                                                    ) ??
                                                    0) >
                                                0
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
