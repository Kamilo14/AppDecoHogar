import '../../../../core/errors/failures.dart';
import '../entities/gasto_entity.dart';
import '../repositories/viaje_repository.dart';

class AgregarGastoUseCase {
  final ViajeRepository _repository;

  AgregarGastoUseCase(this._repository);

  Future<void> call(Gasto gasto) async {
    if (gasto.tipo.trim().isEmpty) {
      throw ValidationFailure('Debes indicar el tipo de gasto.');
    }
    if (gasto.monto <= 0) {
      throw ValidationFailure('El monto debe ser mayor que cero.');
    }
    await _repository.addGasto(gasto);
  }
}