import '../entities/pago_entity.dart';
import '../repositories/pago_repository.dart';

class GetPagosClienteUseCase {
  final PagoRepository _repository;

  GetPagosClienteUseCase(this._repository);

  Stream<List<Pago>> call(int clienteId) => _repository.watchPagosCliente(clienteId);
}