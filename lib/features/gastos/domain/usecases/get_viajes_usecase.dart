import '../entities/viaje_entity.dart';
import '../repositories/viaje_repository.dart';

class GetViajesUseCase {
  final ViajeRepository _repository;

  GetViajesUseCase(this._repository);

  Stream<List<Viaje>> call() => _repository.watchViajes();
}