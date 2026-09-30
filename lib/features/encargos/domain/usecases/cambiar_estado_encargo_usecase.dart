import '../repositories/encargo_repository.dart';

class CambiarEstadoEncargoUseCase {
  final EncargoRepository _repository;

  CambiarEstadoEncargoUseCase(this._repository);

  Future<void> call(int encargoId, String estado) {
    return _repository.changeEstadoEncargo(encargoId, estado);
  }
}
