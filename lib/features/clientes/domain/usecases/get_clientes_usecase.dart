import '../entities/cliente_entity.dart';
import '../repositories/cliente_repository.dart';

/// Caso de uso: obtener todos los clientes activos como stream.
/// La pantalla se suscribe a este stream y se actualiza automáticamente.
class GetClientesUseCase {
  final ClienteRepository _repository;

  GetClientesUseCase(this._repository);

  Stream<List<Cliente>> call() => _repository.watchClientes();
}
