import '../../../../core/errors/failures.dart';
import '../../domain/entities/gasto_entity.dart';
import '../../domain/entities/viaje_entity.dart';
import '../../domain/repositories/viaje_repository.dart';
import '../datasources/viaje_local_datasource.dart';

class ViajeRepositoryImpl implements ViajeRepository {
  final ViajeLocalDataSource _dataSource;

  ViajeRepositoryImpl(this._dataSource);

  @override
  Stream<List<Viaje>> watchViajes() => _dataSource.watchViajes();

  @override
  Stream<Viaje?> watchViajeById(int viajeId) => _dataSource.watchViajeById(viajeId);

  @override
  Future<void> saveViaje(Viaje viaje) async {
    try {
      await _dataSource.saveViaje(viaje);
    } catch (e) {
      throw DatabaseFailure('Error al guardar el viaje: $e');
    }
  }

  @override
  Future<void> addGasto(Gasto gasto) async {
    try {
      await _dataSource.addGasto(gasto);
    } catch (e) {
      throw DatabaseFailure('Error al guardar el gasto: $e');
    }
  }

  @override
  Future<void> distribuirGastos(int viajeId, int montoADistribuir) async {
    try {
      await _dataSource.distribuirGastos(viajeId, montoADistribuir);
    } catch (e) {
      throw DatabaseFailure('Error al distribuir los gastos: $e');
    }
  }

  @override
  Future<Viaje?> getViajeById(int viajeId) async {
    try {
      return await _dataSource.getViajeById(viajeId);
    } catch (e) {
      throw DatabaseFailure('Error al obtener el viaje: $e');
    }
  }
}
