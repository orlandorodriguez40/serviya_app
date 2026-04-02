class AppConstants {
  // Tu ruta real de producción
  static const String baseUrl = "https://tupaginalista.com/serviya_api";

  // Rutas de Autenticación
  static const String loginUrl = "$baseUrl/auth/login.php";
  static const String registerUrl =
      "$baseUrl/auth/register.php"; // Verifica si es register.php o registro.php

  // La ruta que te daba error en el DataService
  static const String categoriesUrl = "$baseUrl/services/get_categorias.php";

  // Para futuras funciones
  static const String serviciosUrl = "$baseUrl/services/crear_solicitud.php";
}
