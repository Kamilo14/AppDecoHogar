import '../entities/encargo_entity.dart';

abstract class EncargoRepository {
  Stream<List<Encargo>> watchEncargos();

  Future<void> saveEncargo(Encargo encargo);

  Future<void> changeEstadoEncargo(int encargoId, String estado);

  Future<void> convertEncargoAVenta(int encargoId);

  Future<void> deleteEncargo(int encargoId);

  Future<Encargo?> getEncargoById(int encargoId);
}