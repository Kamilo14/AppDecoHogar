import '../entities/cliente_entity.dart';

/// Contrato abstracto — define qué puede hacer el repositorio de clientes.
/// La capa de Presentación y Dominio solo conocen esta interfaz,
/// nunca la implementación concreta de Drift.
abstract class ClienteRepository {
  /// Retorna todos los clientes activos como stream reactivo.
  Stream<List<Cliente>> watchClientes();

  /// Guarda un nuevo cliente. Si ya tiene ID, lo actualiza.
  Future<void> saveCliente(Cliente cliente);

  /// Soft-delete: desactiva el cliente sin borrarlo de la BD.
  Future<void> deleteCliente(int id);

  /// Obtiene un cliente por ID.
  Future<Cliente?> getClienteById(int id);
}
