import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = "https://tupaginalista.com/serviya_api/auth";

  // 1. INICIAR SESIÓN
  Future<UserModel?> login(String emailOrUsername, String password) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({"email": emailOrUsername, "password": password}),
      );

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
          // 🚨 LANZAR EXCEPCIÓN: Enviamos el mensaje real del PHP a la pantalla
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
        throw Exception("Error en el servidor (${response.statusCode})");
      }
    } catch (e) {
      // Si el error ya es una Exception nuestra, la relanzamos
      if (e.toString().contains("Exception:")) rethrow;

      dev.log("Error de conexión", name: "AuthService", error: e);
      throw Exception("Error de conexión: Verifica tu internet.");
    }
  }

  // 2. ACTUALIZAR PERFIL
  Future<bool> updateProfile(UserModel user) async {
    final url = Uri.parse("$baseUrl/update_profile.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": user.id,
          "nombre": user.nombre,
          "telefono": user.telefono,
          "direccion": user.direccion,
          "especialidades": user.especialidades,
        }),
      );

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
