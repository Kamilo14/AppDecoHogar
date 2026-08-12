import '../repositories/encargo_repository.dart';

class SoftDeleteEncargoUseCase {
  final EncargoRepository _repository;

  SoftDeleteEncargoUseCase(this._repository);

  Future<void> call(int encargoId) {
    return _repository.deleteEncargo(encargoId);
  }
}