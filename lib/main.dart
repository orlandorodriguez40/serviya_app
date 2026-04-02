import 'package:flutter/material.dart';

// Importación de pantallas desde la subcarpeta 'screens'
import 'screens/login_screen.dart';
import 'screens/home_cliente_screen.dart';
import 'screens/home_tecnico_screen.dart';
import 'screens/home_admin_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/crear_solicitud_screen.dart'; // <--- Pantalla de creación de servicios

void main() {
  // Asegura la inicialización de los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------
  // MODO DESARROLLO: Forzamos el inicio en el Login (isLoggedIn: false).
  // ---------------------------------------------------------
  const bool isLoggedIn = false;
  const String userRole = '';

  runApp(const ServiYaApp(isLoggedIn: isLoggedIn, userRole: userRole));
}

class ServiYaApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userRole;

  const ServiYaApp({
    super.key,
    required this.isLoggedIn,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServiYa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A428A),
          primary: const Color(0xFF1A428A),
        ),
        useMaterial3: true,
      ),

      // Definimos la pantalla de inicio según el estado de sesión
      home: _getInitialScreen(),

      // 🗺️ MAPA DE RUTAS: Permite navegar usando Navigator.pushNamed
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home_cliente': (context) => const HomeClienteScreen(),
        '/home_tecnico': (context) => const HomeTecnicoScreen(),
        '/home_admin': (context) => const HomeAdminScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/crear_solicitud': (context) =>
            const CrearSolicitudScreen(), // <--- Registro exitoso
      },
    );
  }

  /// Determina qué pantalla mostrar al abrir la app
  Widget _getInitialScreen() {
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    switch (userRole) {
      case '1':
        return const HomeClienteScreen();
      case '2':
        return const HomeTecnicoScreen();
      case '3':
        return const HomeAdminScreen();
      default:
        return const LoginScreen();
    }
  }
}
