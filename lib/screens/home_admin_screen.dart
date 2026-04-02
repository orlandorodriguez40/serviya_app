import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- IMPORTACIONES ACTIVADAS ---
import 'admin_roles_screen.dart';
import 'admin_solicitudes_crud_screen.dart';
import 'admin_usuarios_crud_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  static const Color azulProfundo = Color(0xFF0D1B2A);
  static const Color grisFondo = Color(0xFFF8F9FA);

  int _selectedIndex = 0;
  List<dynamic> _reporteGlobal = [];
  List<dynamic> _usuarios = [];
  bool _isLoading = true;

  int _total = 0;
  int _pendientes = 0;
  int _finalizados = 0;
  double _promedioRating = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (_selectedIndex == 0) {
      await _cargarSolicitudes();
    } else {
      await _fetchUsuarios();
    }
  }

  Future<void> _cargarSolicitudes() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/admin/admin_listar_solicitudes.php",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> lista = data['data'];
          int p = 0;
          int f = 0;
          double suma = 0;
          int conta = 0;

          for (var item in lista) {
            final String st = (item['status'] ?? "").toString().toLowerCase();
            if (st == 'pendiente') {
              p++;
            }
            if (st == 'finalizado') {
              f++;
            }
            final int c =
                int.tryParse(item['calificacion']?.toString() ?? "0") ?? 0;
            if (c > 0) {
              suma += c;
              conta++;
            }
          }

          setState(() {
            _reporteGlobal = lista;
            _total = lista.length;
            _pendientes = p;
            _finalizados = f;
            _promedioRating = conta > 0 ? (suma / conta) : 0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Solicitudes: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      debugPrint("Error Usuarios: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Dashboard Admin" : "Gestión de Usuarios",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: azulProfundo,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      // --- DRAWER ACTUALIZADO Y FUNCIONAL ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: azulProfundo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: azulProfundo,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Panel de Control",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "Administrador Principal",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_accessibility,
                color: azulProfundo,
              ),
              title: const Text("CRUD Roles"),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AdminRolesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: azulProfundo),
              title: const Text("CRUD Solicitudes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const AdminSolicitudesCrudScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt, color: azulProfundo),
              title: const Text("CRUD Usuarios"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const AdminUsuariosCrudScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Cerrar Sesión"),
              onTap: () {
                // Ajusta esto según tu ruta de login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0 ? _buildDashboard() : _buildUsuariosTabs(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _cargarDatos();
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Servicios",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Usuarios"),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildHeaderStats(),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Monitor Global",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarSolicitudes,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _reporteGlobal.length,
                    itemBuilder: (context, index) =>
                        _cardServicio(_reporteGlobal[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: azulProfundo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Total", _total.toString(), Colors.blue),
          _statItem("Pend.", _pendientes.toString(), Colors.orange),
          _statItem("Fin.", _finalizados.toString(), Colors.green),
          _statItem("Rating", _promedioRating.toStringAsFixed(1), Colors.amber),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color col) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: col,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _cardServicio(dynamic item) {
    final int c = int.tryParse(item['calificacion']?.toString() ?? "0") ?? 0;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: azulProfundo.withAlpha(20),
          child: Text(
            item['id'].toString(),
            style: const TextStyle(color: azulProfundo, fontSize: 12),
          ),
        ),
        title: Text(item['titulo'] ?? "Servicio"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "C: ${item['cliente_id']} | T: ${item['tecnico_id'] ?? 'Pend.'}",
            ),
            if (c > 0)
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < c ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
        trailing: _chipStatus(item['status'] ?? ""),
      ),
    );
  }

  Widget _chipStatus(String st) {
    Color col = Colors.blue;
    if (st.toLowerCase() == "finalizado") {
      col = Colors.green;
    } else if (st.toLowerCase() == "pendiente") {
      col = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: col.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: col),
      ),
      child: Text(
        st.toUpperCase(),
        style: TextStyle(color: col, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUsuariosTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: azulProfundo,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(icon: Icon(Icons.engineering), text: "Técnicos"),
              Tab(icon: Icon(Icons.person), text: "Clientes"),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(children: [_buildUserList(2), _buildUserList(1)]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(int rolId) {
    final filtered = _usuarios.where((u) {
      final int uRol = int.tryParse(u['rol_id']?.toString() ?? "0") ?? 0;
      return uRol == rolId;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No hay registros"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final u = filtered[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (rolId == 2 ? Colors.orange : Colors.blue)
                  .withAlpha(40),
              child: Icon(
                rolId == 2 ? Icons.handyman : Icons.person,
                color: rolId == 2 ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(u['nombre'] ?? "N/A"),
            subtitle: Text("${u['email']}\nTel: ${u['telefono'] ?? '---'}"),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
