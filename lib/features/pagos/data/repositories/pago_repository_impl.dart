import '../../../../core/errors/failures.dart';
import '../../domain/entities/pago_entity.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/pago_local_datasource.dart';

class PagoRepositoryImpl implements PagoRepository {
  final PagoLocalDataSource _dataSource;

  PagoRepositoryImpl(this._dataSource);

  @override
  Stream<List<Pago>> watchPagos() => _dataSource.watchPagos();

  @override
  Stream<List<Pago>> watchPagosCliente(int clienteId) => _dataSource.watchPagosCliente(clienteId);

  @override
  Future<void> savePago(Pago pago) async {
    try {
      await _dataSource.savePago(pago);
    } catch (e) {
      throw DatabaseFailure('Error al guardar el pago: $e');
    }
  }

  @override
  Future<void> deletePago(int pagoId) async {
    try {
      await _dataSource.deletePago(pagoId);
    } catch (e) {
      throw DatabaseFailure('Error al eliminar el pago: $e');
    }
  }

  @override
  Future<Pago?> getPagoById(int pagoId) async {
    try {
      return await _dataSource.getPagoById(pagoId);
    } catch (e) {
      throw DatabaseFailure('Error al obtener el pago: $e');
    }
  }
}