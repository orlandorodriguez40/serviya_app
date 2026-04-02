import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/user_model.dart';
import 'tecnico_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  String _searchQuery = "";
  String _categoriaSeleccionada = "";

  // Color Corporativo
  static const Color azulIngenieria = Color(0xFF1A428A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "ServiYa - Inicio",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulIngenieria,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildCategorias(),
          Expanded(child: _buildListaTecnicos()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
      decoration: const BoxDecoration(
        color: azulIngenieria,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: TextField(
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Buscar técnico o servicio...",
          prefixIcon: const Icon(Icons.search, color: azulIngenieria),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorias() {
    final categorias = [
      {'nombre': 'Todos', 'icon': Icons.grid_view},
      {'nombre': 'Plomeria', 'icon': Icons.plumbing},
      {'nombre': 'Electricidad', 'icon': Icons.bolt},
      {'nombre': 'Pintura', 'icon': Icons.format_paint},
      {'nombre': 'Carpinteria', 'icon': Icons.handyman},
    ];

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final String nombreCat = cat['nombre'] as String;
          final bool isSelected =
              _categoriaSeleccionada == (nombreCat == 'Todos' ? "" : nombreCat);

          return GestureDetector(
            onTap: () {
              setState(() {
                _categoriaSeleccionada = nombreCat == 'Todos' ? "" : nombreCat;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // Reemplazamos withOpacity por withValues
                      color: isSelected ? azulIngenieria : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? Colors.white : azulIngenieria,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nombreCat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? azulIngenieria : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaTecnicos() {
    return FutureBuilder<List<UserModel>>(
      future: _categoriaSeleccionada.isEmpty
          ? _dataService.getAllTecnicos()
          : _dataService.getTecnicosPorEspecialidad(_categoriaSeleccionada),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: azulIngenieria),
          );
        }

        final lista =
            snapshot.data?.where((t) {
              final nombre = t.nombre.toLowerCase();
              // Aquí ya no debería dar error si actualizaste el UserModel
              final especialidad = t.especialidades.toLowerCase();
              return nombre.contains(_searchQuery) ||
                  especialidad.contains(_searchQuery);
            }).toList() ??
            [];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          itemCount: lista.length,
          itemBuilder: (context, index) {
            final tecnico = lista[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    // Reemplazamos withOpacity por withValues
                    color: azulIngenieria.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 35,
                    color: azulIngenieria,
                  ),
                ),
                title: Text(
                  tecnico.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      tecnico.especialidades,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TecnicoDetailScreen(tecnico: tecnico),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
