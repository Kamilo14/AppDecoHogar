import '../repositories/pago_repository.dart';

class EliminarPagoUseCase {
  final PagoRepository _repository;

  EliminarPagoUseCase(this._repository);

  Future<void> call(int pagoId) => _repository.deletePago(pagoId);
}