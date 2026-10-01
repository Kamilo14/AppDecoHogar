import '../../../encargos/domain/entities/encargo_entity.dart';
import '../../../gastos/domain/entities/viaje_entity.dart';
import '../../../productos/domain/entities/producto_entity.dart';

class ReporteGanancias {
  final int totalInvertidoEnStock;
  final int totalVendido;
  final int costoMercaderiaVendida;
  final int gastosViaje;
  final int gananciaNeta;
  final int gastosNoDistribuidos;
  int get gananciaBruta => totalVendido - costoMercaderiaVendida;

  const ReporteGanancias({
    required this.totalInvertidoEnStock,
    required this.totalVendido,
    required this.costoMercaderiaVendida,
    required this.gastosViaje,
    required this.gananciaNeta,
    this.gastosNoDistribuidos = 0,
  });
}

class GetReporteGananciasUseCase {
  ReporteGanancias call(
      List<Producto> productos, List<Viaje> viajes, List<Encargo> encargos) {
    // 1. Inversión en stock actual (Tratamos null como 0)
    final totalInvertidoEnStock =
        productos.where((p) => p.activo).fold(0, (sum, p) {
      final int costo = p.precioCompra ?? 0;
      return sum + (costo * p.cantidadDisponible);
    });

    // 2. Ventas totales.
    final ventasRealizadas = encargos
        .where((e) =>
            e.activo && e.tipoVenta != 'Por encargo' && e.estado == 'ENTREGADO')
        .toList();

    int totalVendido = 0;
    int costoMercaderiaVendida = 0;
    int totalGastosLogisticaVentas = 0;

    for (final venta in ventasRealizadas) {
      totalVendido += venta.total;
      for (final detalle in venta.detalles) {
        final prod =
            productos.where((p) => p.id == detalle.productoId).firstOrNull;

        // Usamos el costo histórico si existe, si no el actual (tratando null como 0)
        final int costoBase = detalle.costoUnitario ?? prod?.precioCompra ?? 0;
        final logistica = detalle.costoLogistica ??
            (prod?.comisionViaje ?? 0) * detalle.cantidad;
        costoMercaderiaVendida += costoBase * detalle.cantidad + logistica;
        totalGastosLogisticaVentas += logistica;
      }
    }

    final gastosSeparados =
        viajes.fold<int>(0, (s, v) => s + v.gastoSinDistribuir);
    final gananciaNeta =
        totalVendido - costoMercaderiaVendida - gastosSeparados;

    return ReporteGanancias(
      totalInvertidoEnStock: totalInvertidoEnStock,
      totalVendido: totalVendido,
      costoMercaderiaVendida: costoMercaderiaVendida,
      gastosViaje: totalGastosLogisticaVentas,
      gananciaNeta: gananciaNeta,
      gastosNoDistribuidos: gastosSeparados,
    );
  }
}
