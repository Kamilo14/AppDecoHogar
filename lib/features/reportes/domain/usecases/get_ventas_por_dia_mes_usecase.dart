import '../../../encargos/domain/entities/encargo_entity.dart';

class GetVentasPorDiaMesUseCase {
  /// Retorna un mapa de {Etiqueta: Monto} según el período seleccionado.
  Map<String, int> call(List<Encargo> encargos, String periodo) {
    final ahora = DateTime.now();
    final Map<String, int> datos = {};

    if (periodo == 'Día') {
      // Ventas de las últimas 24 horas (por hora o simplemente hoy)
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      final total = encargos
          .where((e) =>
              e.activo &&
              e.tipoVenta != 'Por encargo' &&
              e.estado == 'ENTREGADO')
          .where((e) =>
              e.fechaVenta.isAfter(hoy) || e.fechaVenta.isAtSameMomentAs(hoy))
          .where((e) => e.fechaVenta
              .isBefore(DateTime(ahora.year, ahora.month, ahora.day + 1)))
          .fold(0, (sum, e) => sum + e.total);
      datos['Hoy'] = total;
    } else if (periodo == 'Semana') {
      // Últimos 7 días
      for (int i = 6; i >= 0; i--) {
        final fecha = ahora.subtract(Duration(days: i));
        final label = '${fecha.day}/${fecha.month}';
        final total = encargos
            .where((e) =>
                e.activo &&
                e.tipoVenta != 'Por encargo' &&
                e.estado == 'ENTREGADO')
            .where((e) =>
                e.fechaVenta.year == fecha.year &&
                e.fechaVenta.month == fecha.month &&
                e.fechaVenta.day == fecha.day)
            .fold(0, (sum, e) => sum + e.total);
        datos[label] = total;
      }
    } else {
      // Mes actual (por semanas o bloques de días)
      for (int i = 0; i < 5; i++) {
        final label = 'Sem ${i + 1}';
        // Cinco bloques para incluir también los días 29, 30 y 31.
        final total = encargos
            .where((e) =>
                e.activo &&
                e.tipoVenta != 'Por encargo' &&
                e.estado == 'ENTREGADO')
            .where((e) =>
                e.fechaVenta.year == ahora.year &&
                e.fechaVenta.month == ahora.month)
            .where((e) =>
                e.fechaVenta.day > (i * 7) && e.fechaVenta.day <= ((i + 1) * 7))
            .fold(0, (sum, e) => sum + e.total);
        datos[label] = total;
      }
    }

    return datos;
  }
}
