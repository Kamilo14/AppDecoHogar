import '../repositories/viaje_repository.dart';

class DistribuirGastosUseCase {
  final ViajeRepository _repository;

  DistribuirGastosUseCase(this._repository);

  Future<void> call(int viajeId, int montoADistribuir) => 
      _repository.distribuirGastos(viajeId, montoADistribuir);
}
