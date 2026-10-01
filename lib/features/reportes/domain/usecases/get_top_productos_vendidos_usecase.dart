import '../../../encargos/domain/entities/encargo_entity.dart';
import '../../../productos/domain/entities/producto_entity.dart';

class TopProductoVendido {
  final int productoId;
  final String nombre;
  final int unidades;
  final int montoTotal;

  const TopProductoVendido({
    required this.productoId,
    required this.nombre,
    required this.unidades,
    required this.montoTotal,
  });
}

class GetTopProductosVendidosUseCase {
  List<TopProductoVendido> call(
      List<Encargo> encargos, List<Producto> productos,
      {int limit = 5}) {
    final cantidades = <int, int>{};
    final montos = <int, int>{};

    for (final encargo in encargos) {
      if (!encargo.activo ||
          encargo.tipoVenta == 'Por encargo' ||
          encargo.estado != 'ENTREGADO') {
        continue;
      }
      for (final detalle in encargo.detalles) {
        final id = detalle.productoId;
        // Solo procesamos productos reales (id != null) para el top
        if (id != null) {
          final currentQty = cantidades[id] ?? 0;
          final currentAmount = montos[id] ?? 0;
          cantidades[id] = currentQty + detalle.cantidad;
          montos[id] = currentAmount + detalle.subtotal;
        }
      }
    }

    final ranked = cantidades.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked.take(limit).map((entry) {
      final prod = productos.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Producto(
            nombre: 'Producto #${entry.key}', precioCompra: 0, precioVenta: 0),
      );
      return TopProductoVendido(
        productoId: entry.key,
        nombre: prod.nombre,
        unidades: entry.value,
        montoTotal: montos[entry.key] ?? 0,
      );
    }).toList();
  }
}
