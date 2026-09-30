import '../../../../core/errors/failures.dart';
import '../../domain/entities/encargo_entity.dart';
import '../../domain/repositories/encargo_repository.dart';
import '../datasources/encargo_local_datasource.dart';

class EncargoRepositoryImpl implements EncargoRepository {
  final EncargoLocalDataSource _dataSource;

  EncargoRepositoryImpl(this._dataSource);

  @override
  Stream<List<Encargo>> watchEncargos() => _dataSource.watchEncargos();

  @override
  Future<int> saveEncargo(Encargo encargo,
      {int? montoPagoInicial,
      String? metodoPago,
      bool liquidarSaldo = false}) async {
    try {
      return await _dataSource.saveEncargo(
        encargo,
        montoPagoInicial: montoPagoInicial,
        metodoPago: metodoPago,
        liquidarSaldo: liquidarSaldo,
      );
    } catch (e) {
      throw DatabaseFailure('Error al guardar el encargo: $e');
    }
  }

  @override
  Future<void> changeEstadoEncargo(int encargoId, String estado) async {
    try {
      await _dataSource.changeEstadoEncargo(encargoId, estado);
    } catch (e) {
      throw DatabaseFailure('Error al cambiar el estado del encargo: $e');
    }
  }

  @override
  Future<void> convertEncargoAVenta(int encargoId) async {
    try {
      await _dataSource.convertEncargoAVenta(encargoId);
    } catch (e) {
      throw DatabaseFailure('Error al convertir el encargo en venta: $e');
    }
  }

  @override
  Future<void> deleteEncargo(int encargoId) async {
    try {
      await _dataSource.deleteEncargo(encargoId);
    } catch (e) {
      throw DatabaseFailure('Error al desactivar el encargo: $e');
    }
  }

  @override
  Future<Encargo?> getEncargoById(int encargoId) async {
    try {
      return await _dataSource.getEncargoById(encargoId);
    } catch (e) {
      throw DatabaseFailure('Error al obtener el encargo: $e');
    }
  }
}
