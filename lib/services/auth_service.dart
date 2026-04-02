import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Asegúrate de que la ruta sea exacta a donde están tus archivos PHP
  final String baseUrl = "https://tupaginalista.com/serviya_api/auth";

  // 1. INICIAR SESIÓN
  Future<UserModel?> login(String emailOrUsername, String password) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http
          .post(
            url,
            // Agregamos headers para evitar el error 505 y asegurar formato JSON
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"email": emailOrUsername, "password": password}),
          )
          .timeout(
            const Duration(seconds: 15),
          ); // Tiempo de espera para móviles

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          final userData = responseData['user'];

          // --- GUARDAR SESIÓN LOCALMENTE ---
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userId', userData['id'].toString());
          await prefs.setString('userName', userData['nombre'] ?? '');
          await prefs.setString('userEmail', userData['email'] ?? '');
          await prefs.setString('userRole', userData['rol_id'].toString());

          return UserModel.fromJson(userData);
        } else {
          final errorMsg =
              responseData['message'] ?? "Credenciales incorrectas";
          dev.log("Fallo en login: $errorMsg", name: "AuthService");
          throw Exception(errorMsg);
        }
      } else {
        dev.log(
          "Error de servidor: ${response.statusCode}",
          name: "AuthService",
        );
        throw Exception("Servidor no disponible (${response.statusCode})");
      }
    } catch (e) {
      if (e.toString().contains("Exception:")) rethrow;

      dev.log("Error de conexión", name: "AuthService", error: e);
      // Este mensaje ayuda al usuario a saber si es su internet o el permiso
      throw Exception(
        "No se pudo conectar con el servidor. Verifica tu conexión.",
      );
    }
  }

  // 2. ACTUALIZAR PERFIL
  Future<bool> updateProfile(UserModel user) async {
    final url = Uri.parse("$baseUrl/update_profile.php");

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "id": user.id,
              "nombre": user.nombre,
              "telefono": user.telefono,
              "direccion": user.direccion,
              "especialidades": user.especialidades,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', user.nombre);
        return true;
      }
      return false;
    } catch (e) {
      dev.log("Error al actualizar perfil", name: "AuthService", error: e);
      return false;
    }
  }

  // 3. CERRAR SESIÓN
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    dev.log("Sesión finalizada", name: "AuthService");
  }

  // 4. VERIFICAR SESIÓN
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
