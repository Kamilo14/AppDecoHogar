import '../entities/encargo_entity.dart';
import '../repositories/encargo_repository.dart';

class GetEncargosUseCase {
  final EncargoRepository _repository;

  GetEncargosUseCase(this._repository);

  Stream<List<Encargo>> call() => _repository.watchEncargos();
}