import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../encargos/domain/entities/encargo_entity.dart';
import '../../../pagos/domain/entities/pago_entity.dart';

class ClienteDeudaResumen {
  final Cliente cliente;
  final int deuda;

  const ClienteDeudaResumen({required this.cliente, required this.deuda});
}

class GetReporteDeudasUseCase {
  List<ClienteDeudaResumen> call(
      List<Cliente> clientes, List<Encargo> encargos, List<Pago> pagos) {
    final result = <ClienteDeudaResumen>[];

    for (final cliente in clientes) {
      final ventas = encargos
          .where((encargo) => encargo.clienteId == cliente.id)
          .where((encargo) => encargo.activo)
          .fold(0, (sum, encargo) => sum + encargo.totalExigible);
      final recuperado = pagos
          .where((pago) => pago.clienteId == cliente.id)
          .fold(0, (sum, pago) => sum + pago.monto);
      final deuda = ventas - recuperado;
      if (deuda > 0) {
        result.add(ClienteDeudaResumen(cliente: cliente, deuda: deuda));
      }
    }

    result.sort((a, b) => b.deuda.compareTo(a.deuda));
    return result;
  }
}
