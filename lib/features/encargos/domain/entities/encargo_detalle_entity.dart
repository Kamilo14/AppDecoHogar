class EncargoDetalle {
  final int? id;
  final int? encargoId;
  final int? productoId; // Ahora es opcional para permitir recordatorios
  final String? nombreTemporal; // Para guardar el nombre antes de crear el producto
  final int cantidad;
  final int? precioUnitario;
  final int? costoUnitario;

  const EncargoDetalle({
    this.id,
    this.encargoId,
    this.productoId,
    this.nombreTemporal,
    required this.cantidad,
    this.precioUnitario,
    this.costoUnitario,
  });

  int get subtotal => cantidad * (precioUnitario ?? 0);

  EncargoDetalle copyWith({
    int? id,
    int? encargoId,
    int? productoId,
    String? nombreTemporal,
    int? cantidad,
    int? precioUnitario,
    int? costoUnitario,
  }) {
    return EncargoDetalle(
      id: id ?? this.id,
      encargoId: encargoId ?? this.encargoId,
      productoId: productoId ?? this.productoId,
      nombreTemporal: nombreTemporal ?? this.nombreTemporal,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      costoUnitario: costoUnitario ?? this.costoUnitario,
    );
  }
}
