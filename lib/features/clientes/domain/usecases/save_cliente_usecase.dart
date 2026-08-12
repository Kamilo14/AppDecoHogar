import '../../../../core/errors/failures.dart';
import '../entities/cliente_entity.dart';
import '../repositories/cliente_repository.dart';

/// Caso de uso: guardar o actualizar un cliente.
/// Valida que el nombre no esté vacío antes de llamar al repositorio.
class SaveClienteUseCase {
  final ClienteRepository _repository;

  SaveClienteUseCase(this._repository);

  Future<void> call(Cliente cliente) async {
    if (cliente.nombre.trim().isEmpty) {
      throw ValidationFailure('El nombre del cliente no puede estar vacío.');
    }
    await _repository.saveCliente(cliente);
  }
}
