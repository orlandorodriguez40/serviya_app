class CategoryModel {
  final String id;
  final String nombre;
  final String descripcion;

  CategoryModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  // Este método transforma el JSON que viene de get_categorias.php a un objeto Dart
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}
