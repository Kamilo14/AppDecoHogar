import '../../../encargos/domain/entities/encargo_entity.dart';
import '../entities/pago_entity.dart';

class CalcularDeudaClienteUseCase {
  /// Calcula la deuda neta: ventas reales menos pagos recibidos.
  int call(List<Encargo> encargos, List<Pago> pagos, int clienteId) {
    // Una compra parcial exige solo el valor de los productos ya conseguidos.
    final totalEncargado = encargos
        .where((e) =>
            e.clienteId == clienteId &&
            e.activo &&
            e.tipoVenta != 'Por encargo')
        .fold(0, (sum, e) => sum + e.totalExigible);

    final totalPagado = pagos
        .where((p) => p.clienteId == clienteId)
        .fold(0, (sum, p) => sum + p.monto);

    return totalEncargado - totalPagado;
  }
}
