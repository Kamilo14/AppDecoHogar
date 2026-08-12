/// Entidad de dominio pura — representa un Producto en el negocio.
class Producto {
  final int? id;
  final int? categoriaId;
  final int? viajeId;
  final String nombre;
  final String? descripcion;
  
  // Regla 8.3: Nulables para permitir creación sin precio inicial (Santiago)
  final int? precioCompra;
  final int comisionViaje;
  final int? precioVenta; // Este actúa como el Precio Base definido por Martina

  final int cantidadDisponible;
  final String? fotoPath;
  final bool activo;

  const Producto({
    this.id,
    this.categoriaId,
    this.viajeId,
    required this.nombre,
    this.descripcion,
    this.precioCompra,
    this.comisionViaje = 0,
    this.precioVenta,
    this.cantidadDisponible = 0,
    this.fotoPath,
    this.activo = true,
  });

  /// Precio que Martina ingresó manualmente en el formulario (Base).
  int? get precioBase => precioVenta;

  /// Precio que se le cobra al cliente: Base + Comisión de Logística del Viaje.
  int? get precioFinal => (precioVenta != null) ? precioVenta! + comisionViaje : null;

  /// Costo total considerando el precio pagado y la comisión de viaje asignada.
  int? get costoReal => (precioCompra != null) ? precioCompra! + comisionViaje : null;

  /// Ganancia real para Martina (lo que queda después de recuperar gastos).
  int? get margenReal {
    final finalPrice = precioFinal;
    final realCost = costoReal;
    if (finalPrice == null || realCost == null) return null;
    return finalPrice - realCost;
  }

  bool get tieneStock => cantidadDisponible > 0;

  Producto copyWith({
    int? id,
    int? categoriaId,
    int? viajeId,
    String? nombre,
    String? descripcion,
    int? precioCompra,
    int? comisionViaje,
    int? precioVenta,
    int? cantidadDisponible,
    String? fotoPath,
    bool? activo,
  }) {
    return Producto(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      viajeId: viajeId ?? this.viajeId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioCompra: precioCompra ?? this.precioCompra,
      comisionViaje: comisionViaje ?? this.comisionViaje,
      precioVenta: precioVenta ?? this.precioVenta,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      fotoPath: fotoPath ?? this.fotoPath,
      activo: activo ?? this.activo,
    );
  }
}
