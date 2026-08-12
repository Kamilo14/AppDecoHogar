import '../../../../core/errors/failures.dart';
import '../entities/viaje_entity.dart';
import '../repositories/viaje_repository.dart';

class SaveViajeUseCase {
  final ViajeRepository _repository;

  SaveViajeUseCase(this._repository);

  Future<void> call(Viaje viaje) async {
    if (viaje.destino.trim().isEmpty) {
      throw ValidationFailure('El destino del viaje no puede estar vacío.');
    }
    await _repository.saveViaje(viaje);
  }
}