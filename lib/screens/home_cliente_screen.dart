import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'crear_solicitud_screen.dart';
import 'perfil_cliente_screen.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  static const Color azulIngenieria = Color(0xFF1A428A);
  static const Color grisSuave = Color(0xFFF5F7FA);

  List<dynamic> _misSolicitudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse(
        "https://tupaginalista.com/serviya_api/solicitudes/listar_solicitudes.php?cliente_id=$userId",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _misSolicitudes = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error al cargar solicitudes: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoCalificacion(String solicitudId) {
    int ratingTemporal = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Calificar Técnico",
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("¿Qué te pareció el servicio recibido?"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setDialogState(() => ratingTemporal = index + 1);
                        },
                        icon: Icon(
                          index < ratingTemporal
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 35,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "CANCELAR",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulIngenieria,
                  ),
                  onPressed: ratingTemporal == 0
                      ? null
                      : () async {
                          try {
                            final res = await http.post(
                              Uri.parse(
                                "https://tupaginalista.com/serviya_api/solicitudes/calificar_servicio.php",
                              ),
                              body: {
                                'solicitud_id': solicitudId.toString(),
                                'puntuacion': ratingTemporal.toString(),
                              },
                            );

                            // GUARDIA DE ASYNC GAP para el diálogo
                            if (!dialogContext.mounted) return;

                            final responseData = jsonDecode(res.body);

                            if (responseData['status'] == 'success') {
                              Navigator.pop(dialogContext);

                              // GUARDIA DE ASYNC GAP para el estado de la pantalla
                              if (!mounted) return;

                              setState(() {
                                for (var item in _misSolicitudes) {
                                  if (item['id'].toString() == solicitudId) {
                                    item['calificacion'] = ratingTemporal
                                        .toString();
                                  }
                                }
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("¡Gracias por calificar!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              _cargarSolicitudes();
                            }
                          } catch (e) {
                            debugPrint("Error al enviar calificación: $e");
                          }
                        },
                  child: const Text(
                    "ENVIAR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisSuave,
      appBar: AppBar(
        title: const Text(
          "ServiYa - Mis Servicios",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulIngenieria,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: azulIngenieria,
            child: const Text(
              "Consulta el estado de tus requerimientos",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: azulIngenieria),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarSolicitudes,
                    child: _misSolicitudes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(15),
                            itemCount: _misSolicitudes.length,
                            itemBuilder: (context, index) =>
                                _cardSolicitud(_misSolicitudes[index]),
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(Icons.add_box, "Nueva", Colors.green, () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CrearSolicitudScreen(),
                  ),
                );
                if (res == true && mounted) {
                  _cargarSolicitudes();
                }
              }),
              _buildNavButton(
                Icons.account_circle,
                "Perfil",
                azulIngenieria,
                () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PerfilClienteScreen(),
                    ),
                  );
                  if (res == true && mounted) {
                    _cargarSolicitudes();
                  }
                },
              ),
              _buildNavButton(Icons.logout, "Salir", Colors.redAccent, () {
                Navigator.pushReplacementNamed(context, '/login');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return MaterialButton(
      minWidth: 40,
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSolicitud(dynamic item) {
    final String status = (item['status'] ?? "")
        .toString()
        .toUpperCase()
        .trim();
    final String califRaw = (item['calificacion'] ?? "0").toString().trim();
    final int califInt = int.tryParse(califRaw) ?? 0;

    final bool esFinalizado = status == "FINALIZADO";
    final bool yaCalificado = califInt > 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: (esFinalizado && !yaCalificado)
            ? () {
                _mostrarDialogoCalificacion(item['id'].toString());
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.handyman, color: azulIngenieria),
            ),
            title: Text(
              item['titulo'] ?? "Sin título",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fecha: ${item['fecha_sugerida']}"),
                if (esFinalizado) ...[
                  const SizedBox(height: 4),
                  if (yaCalificado) ...[
                    Row(
                      children: [
                        const Text(
                          "✅ Ya calificaste ",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < califInt ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      "⭐ Toca para calificar",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ],
            ),
            trailing: _buildStatusChip(status),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No tienes solicitudes registradas.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color baseColor = Colors.orange;
    if (status == 'ACEPTADO') {
      baseColor = Colors.blue;
    }
    if (status == 'FINALIZADO') {
      baseColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: baseColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: baseColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
