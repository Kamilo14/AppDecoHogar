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
          .where((e) => e.activo && (e.estado == 'ENTREGADO' || e.estado == 'FINALIZADO'))
          .where((e) => e.fecha.isAfter(hoy) || e.fecha.isAtSameMomentAs(hoy))
          .fold(0, (sum, e) => sum + e.total);
      datos['Hoy'] = total;
    } 
    else if (periodo == 'Semana') {
      // Últimos 7 días
      for (int i = 6; i >= 0; i--) {
        final fecha = ahora.subtract(Duration(days: i));
        final label = '${fecha.day}/${fecha.month}';
        final total = encargos
            .where((e) => e.activo && (e.estado == 'ENTREGADO' || e.estado == 'FINALIZADO'))
            .where((e) => e.fecha.year == fecha.year && e.fecha.month == fecha.month && e.fecha.day == fecha.day)
            .fold(0, (sum, e) => sum + e.total);
        datos[label] = total;
      }
    } 
    else {
      // Mes actual (por semanas o bloques de días)
      for (int i = 0; i < 4; i++) {
        final label = 'Sem ${i + 1}';
        // Simplificación: divide el mes en 4 bloques de 7-8 días
        final total = encargos
            .where((e) => e.activo && (e.estado == 'ENTREGADO' || e.estado == 'FINALIZADO'))
            .where((e) => e.fecha.year == ahora.year && e.fecha.month == ahora.month)
            .where((e) => e.fecha.day > (i * 7) && e.fecha.day <= ((i + 1) * 7))
            .fold(0, (sum, e) => sum + e.total);
        datos[label] = total;
      }
    }

    return datos;
  }
}
