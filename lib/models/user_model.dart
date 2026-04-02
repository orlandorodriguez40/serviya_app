class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String username; // ✨ Nuevo campo
  final String rolId;
  final String telefono;
  final String direccion;
  final String especialidades;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.username, // ✨ Agregado al constructor
    required this.rolId,
    required this.telefono,
    required this.direccion,
    required this.especialidades,
  });

  // Mapeo de JSON a Objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '0',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '', // 📥 Extraído del JSON
      rolId: json['rol_id']?.toString() ?? '1', // Por defecto rol 1 si falla
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      especialidades: json['especialidades'] ?? '',
    );
  }

  // Útil si necesitas convertir el objeto de vuelta a JSON para enviar al PHP
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombre": nombre,
      "email": email,
      "username": username,
      "rol_id": rolId,
      "telefono": telefono,
      "direccion": direccion,
      "especialidades": especialidades,
    };
  }
}
