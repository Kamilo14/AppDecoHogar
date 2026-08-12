import '../../../../core/errors/failures.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/cliente_local_datasource.dart';

/// Implementación concreta del repositorio.
/// Llama al datasource y captura errores de Drift,
/// convirtiéndolos en Failures tipados que la UI puede entender.
class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteLocalDataSource _dataSource;

  ClienteRepositoryImpl(this._dataSource);

  @override
  Stream<List<Cliente>> watchClientes() {
    return _dataSource.watchClientes();
  }

  @override
  Future<void> saveCliente(Cliente cliente) async {
    try {
      await _dataSource.saveCliente(cliente);
    } catch (e) {
      throw DatabaseFailure('Error al guardar el cliente: $e');
    }
  }

  @override
  Future<void> deleteCliente(int id) async {
    try {
      await _dataSource.deleteCliente(id);
    } catch (e) {
      throw DatabaseFailure('Error al eliminar el cliente: $e');
    }
  }

  @override
  Future<Cliente?> getClienteById(int id) async {
    try {
      return await _dataSource.getClienteById(id);
    } catch (e) {
      throw DatabaseFailure('Error al obtener el cliente: $e');
    }
  }
}
