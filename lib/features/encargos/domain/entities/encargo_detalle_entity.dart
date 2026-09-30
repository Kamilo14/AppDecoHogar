class EncargoDetalle {
  final int? id;
  final int? encargoId;
  final int? productoId; // Ahora es opcional para permitir recordatorios
  final String?
      nombreTemporal; // Para guardar el nombre antes de crear el producto
  final int cantidad;
  final int? compraId;
  final int? costoLogistica;
  final int? cantidadComprada;
  int get unidadesCompradas => cantidadComprada ?? cantidad;
  final bool comprado;
  final int? precioUnitario;
  final int? costoUnitario;

  const EncargoDetalle({
    this.id,
    this.encargoId,
    this.productoId,
    this.nombreTemporal,
    required this.cantidad,
    this.compraId,
    this.costoLogistica,
    this.cantidadComprada,
    this.comprado = false,
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
    int? compraId,
    int? costoLogistica,
    int? cantidadComprada,
    bool? comprado,
    int? precioUnitario,
    int? costoUnitario,
  }) {
    return EncargoDetalle(
      id: id ?? this.id,
      encargoId: encargoId ?? this.encargoId,
      productoId: productoId ?? this.productoId,
      nombreTemporal: nombreTemporal ?? this.nombreTemporal,
      cantidad: cantidad ?? this.cantidad,
      compraId: compraId ?? this.compraId,
      costoLogistica: costoLogistica ?? this.costoLogistica,
      cantidadComprada: cantidadComprada ?? this.cantidadComprada,
      comprado: comprado ?? this.comprado,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      costoUnitario: costoUnitario ?? this.costoUnitario,
    );
  }
}
