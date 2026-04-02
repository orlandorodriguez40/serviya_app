import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class DataService {
  // Cabeceras constantes para evitar avisos del linter y optimizar memoria
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  };

  /// 1. Obtiene las categorías para el Home (Pintura, Plomería, etc.)
  Future<List<CategoryModel>> getCategorias() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.categoriesUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => CategoryModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error DataService (Categorías): $e");
      return [];
    }
  }

  /// 2. Obtiene técnicos filtrados por especialidad
  /// NOTA: Asegúrate de que el archivo 'get_tecnicos.php' exista en tu servidor
  Future<List<UserModel>> getTecnicosPorEspecialidad(
    String especialidad,
  ) async {
    try {
      // Usamos interpolación directa en Uri.parse para evitar conflictos de 'const'
      final response = await http.get(
        Uri.parse(
          "${AppConstants.baseUrl}/auth/get_tecnicos.php?especialidad=$especialidad",
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => UserModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error DataService (Filtro Técnicos): $e");
      return [];
    }
  }

  /// 3. Obtiene la lista completa de técnicos
  Future<List<UserModel>> getAllTecnicos() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/auth/get_tecnicos.php"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => UserModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error DataService (Todos los Técnicos): $e");
      return [];
    }
  }
}
