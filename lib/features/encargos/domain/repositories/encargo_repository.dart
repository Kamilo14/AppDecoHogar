import '../entities/encargo_entity.dart';

abstract class EncargoRepository {
  Stream<List<Encargo>> watchEncargos();

  /// Guarda o actualiza un encargo y retorna su ID.
  /// Permite registrar un pago inicial de forma atómica.
  Future<int> saveEncargo(Encargo encargo, {int? montoPagoInicial, String? metodoPago});

  Future<void> changeEstadoEncargo(int encargoId, String estado);

  Future<void> convertEncargoAVenta(int encargoId);

  Future<void> deleteEncargo(int encargoId);

  Future<Encargo?> getEncargoById(int encargoId);
}