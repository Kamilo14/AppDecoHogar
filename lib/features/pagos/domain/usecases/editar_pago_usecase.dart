import '../entities/pago_entity.dart';
import '../repositories/pago_repository.dart';

class EditarPagoUseCase {
  final PagoRepository _repository;

  EditarPagoUseCase(this._repository);

  Future<void> call(Pago pago) => _repository.savePago(pago);
}