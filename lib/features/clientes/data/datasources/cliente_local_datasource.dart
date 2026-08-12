import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/cliente_entity.dart' as domain;

/// Acceso directo a Drift para la tabla `clientes`.
/// Solo esta clase conoce cómo hablar con SQLite.
class ClienteLocalDataSource {
  final AppDatabase _db;

  ClienteLocalDataSource(this._db);

  /// Stream reactivo: emite la lista actualizada cada vez que cambia la BD.
  Stream<List<domain.Cliente>> watchClientes() {
    return (_db.select(_db.clientes)
          ..where((c) => c.activo.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  Future<void> saveCliente(domain.Cliente cliente) async {
    if (cliente.id == null) {
      await _db.into(_db.clientes).insert(
            ClientesCompanion.insert(
              nombre: cliente.nombre,
              telefono: Value(cliente.telefono),
              email: Value(cliente.email),
              direccion: Value(cliente.direccion),
              observaciones: Value(cliente.observaciones),
              fechaRegistro: cliente.fechaRegistro,
            ),
          );
    } else {
      await (_db.update(_db.clientes)
            ..where((c) => c.id.equals(cliente.id!)))
          .write(
        ClientesCompanion(
          nombre: Value(cliente.nombre),
          telefono: Value(cliente.telefono),
          email: Value(cliente.email),
          direccion: Value(cliente.direccion),
          observaciones: Value(cliente.observaciones),
        ),
      );
    }
  }

  Future<void> deleteCliente(int id) async {
    await (_db.update(_db.clientes)..where((c) => c.id.equals(id)))
        .write(const ClientesCompanion(activo: Value(false)));
  }

  Future<domain.Cliente?> getClienteById(int id) async {
    final row = await (_db.select(_db.clientes)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  /// Mapeo de la fila generada por Drift (ClienteRow) a la entidad de dominio
  domain.Cliente _toEntity(ClienteRow row) {
    return domain.Cliente(
      id: row.id,
      nombre: row.nombre,
      telefono: row.telefono,
      email: row.email,
      direccion: row.direccion,
      observaciones: row.observaciones,
      fechaRegistro: row.fechaRegistro,
      activo: row.activo,
    );
  }
}
