import '../../../encargos/domain/entities/encargo_entity.dart';
import '../entities/pago_entity.dart';

class CalcularDeudaClienteUseCase {
  /// Calcula la deuda neta: (Suma de encargos con precio fijado) - (Suma de pagos)
  int call(List<Encargo> encargos, List<Pago> pagos, int clienteId) {
    // Regla 8.3: Ignoramos encargos PENDIENTES que no tengan precio fijado aún.
    // Sumamos solo encargos activos que NO sean PENDIENTE (es decir: COMPRADO, ENTREGADO, FINALIZADO)
    final totalEncargado = encargos
        .where((e) => e.clienteId == clienteId && e.activo && e.estado != 'PENDIENTE')
        .fold(0, (sum, e) => sum + e.total);

    final totalPagado = pagos
        .where((p) => p.clienteId == clienteId)
        .fold(0, (sum, p) => sum + p.monto);

    return totalEncargado - totalPagado;
  }
}
