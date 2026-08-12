/// Entidad de dominio pura para categorías de productos.
class Categoria {
  final int? id;
  final String nombre;

  const Categoria({
    this.id,
    required this.nombre,
  });

  Categoria copyWith({
    int? id,
    String? nombre,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }
}