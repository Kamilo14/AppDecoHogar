import '../repositories/cliente_repository.dart';

/// Caso de uso: soft-delete de un cliente.
/// El cliente queda desactivado (activo = false) pero no se borra de la BD,
/// para mantener el historial de encargos y pagos asociados.
class SoftDeleteClienteUseCase {
  final ClienteRepository _repository;

  SoftDeleteClienteUseCase(this._repository);

  Future<void> call(int clienteId) async {
    await _repository.deleteCliente(clienteId);
  }
}
