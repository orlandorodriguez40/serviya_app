import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // 🎨 Colores corporativos
  static const Color azulIngenieria = Color(0xFF1A428A);
  static const Color grisBorde = Color(0xFFE0E0E0);

  Future<void> _handleLogin() async {
    if (_usuarioController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Por favor, completa todos los campos", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().login(
        _usuarioController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        _showSnackBar("¡Bienvenido, ${user.nombre}!");

        // 🚀 Navegación por rutas nombradas
        switch (user.rolId) {
          case '1':
            Navigator.pushReplacementNamed(context, '/home_cliente');
            break;
          case '2':
            Navigator.pushReplacementNamed(context, '/home_tecnico');
            break;
          case '3':
            Navigator.pushReplacementNamed(context, '/home_admin');
            break;
          default:
            _showSnackBar("Rol no reconocido", isError: true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ✨ Estilo de los campos de texto
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: azulIngenieria),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: grisBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: azulIngenieria, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Centramos el contenido para mejor estética en Windows
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // 🖼️ ÁREA DEL LOGOTIPO
                Image.asset(
                  'assets/images/logotipo.png', // Ruta actualizada con .PNG
                  height: 180,
                  fit: BoxFit.contain,
                  // Si la imagen falla, muestra el icono de respaldo
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.engineering,
                      size: 100,
                      color: azulIngenieria,
                    );
                  },
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _usuarioController,
                  decoration: _inputStyle("Usuario", Icons.person_outline),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputStyle("Contraseña", Icons.lock_outline),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulIngenieria,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "INGRESAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(color: azulIngenieria),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
