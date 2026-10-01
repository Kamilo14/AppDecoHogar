import '../../../encargos/domain/entities/encargo_entity.dart';

class ReporteVentas {
  final int totalVendido;
  final int totalProductos;

  const ReporteVentas(
      {required this.totalVendido, required this.totalProductos});
}

class GetReporteVentasUseCase {
  ReporteVentas call(List<Encargo> encargos) {
    final ventas = encargos
        .where((encargo) =>
            encargo.activo &&
            encargo.tipoVenta != 'Por encargo' &&
            encargo.estado == 'ENTREGADO')
        .toList();
    return ReporteVentas(
      totalVendido: ventas.fold(0, (sum, encargo) => sum + encargo.total),
      totalProductos:
          ventas.fold(0, (sum, encargo) => sum + encargo.detalles.length),
    );
  }
}
