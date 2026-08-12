import '../repositories/encargo_repository.dart';

class ConvertirEncargoAVentaUseCase {
  final EncargoRepository _repository;

  ConvertirEncargoAVentaUseCase(this._repository);

  Future<void> call(int encargoId) {
    return _repository.convertEncargoAVenta(encargoId);
  }
}