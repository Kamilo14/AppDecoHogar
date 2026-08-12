import '../../../../core/errors/failures.dart';
import '../entities/pago_entity.dart';
import '../repositories/pago_repository.dart';

class RegistrarPagoUseCase {
  final PagoRepository _repository;

  RegistrarPagoUseCase(this._repository);

  Future<void> call(Pago pago) async {
    if (pago.clienteId <= 0) {
      throw ValidationFailure('Selecciona un cliente válido.');
    }
    if (pago.monto <= 0) {
      throw ValidationFailure('El monto del pago debe ser mayor que cero.');
    }
    if (pago.metodo.trim().isEmpty) {
      throw ValidationFailure('Debes indicar el método de pago.');
    }
    if (pago.tipo.trim().isEmpty) {
      throw ValidationFailure('Debes indicar el tipo de pago.');
    }
    await _repository.savePago(pago);
  }
}