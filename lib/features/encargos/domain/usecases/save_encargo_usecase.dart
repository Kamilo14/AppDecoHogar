import '../../../../core/errors/failures.dart';
import '../entities/encargo_entity.dart';
import '../repositories/encargo_repository.dart';

class SaveEncargoUseCase {
  final EncargoRepository _repository;

  SaveEncargoUseCase(this._repository);

  Future<int> call(Encargo encargo,
      {int? montoPagoInicial,
      String? metodoPago,
      bool liquidarSaldo = false}) async {
    if (encargo.detalles.isEmpty) {
      throw ValidationFailure('El encargo debe tener al menos un producto.');
    }

    for (final detalle in encargo.detalles) {
      if (detalle.cantidad <= 0) {
        throw ValidationFailure('La cantidad debe ser mayor a 0.');
      }
      if (detalle.precioUnitario != null && detalle.precioUnitario! < 0) {
        throw ValidationFailure('El precio no puede ser negativo.');
      }
    }

    if (encargo.tipoVenta == 'Por encargo' && encargo.clienteId == null) {
      throw ValidationFailure('Debes seleccionar un cliente para un encargo.');
    }

    return await _repository.saveEncargo(encargo,
        montoPagoInicial: montoPagoInicial,
        metodoPago: metodoPago,
        liquidarSaldo: liquidarSaldo);
  }
}
