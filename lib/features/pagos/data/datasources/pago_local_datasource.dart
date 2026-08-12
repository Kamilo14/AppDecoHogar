import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/pago_entity.dart' as domain;

class PagoLocalDataSource {
  final AppDatabase _db;

  PagoLocalDataSource(this._db);

  Stream<List<domain.Pago>> watchPagos() {
    return (_db.select(_db.pagos)..orderBy([(p) => OrderingTerm.desc(p.fecha)])).watch().map(
          (rows) => rows.map(_toEntity).toList(),
        );
  }

  Stream<List<domain.Pago>> watchPagosCliente(int clienteId) {
    return (_db.select(_db.pagos)
          ..where((p) => p.clienteId.equals(clienteId))
          ..orderBy([(p) => OrderingTerm.desc(p.fecha)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  Future<void> savePago(domain.Pago pago) async {
    if (pago.id == null) {
      await _db.into(_db.pagos).insert(
            PagosCompanion.insert(
              clienteId: pago.clienteId,
              encargoId: Value(pago.encargoId),
              monto: pago.monto,
              fecha: pago.fecha,
              metodo: pago.metodo,
              tipo: pago.tipo,
              concepto: Value(pago.concepto),
            ),
          );
    } else {
      await (_db.update(_db.pagos)..where((p) => p.id.equals(pago.id!))).write(
        PagosCompanion(
          clienteId: Value(pago.clienteId),
          encargoId: Value(pago.encargoId),
          monto: Value(pago.monto),
          fecha: Value(pago.fecha),
          metodo: Value(pago.metodo),
          tipo: Value(pago.tipo),
          concepto: Value(pago.concepto),
        ),
      );
    }
  }

  Future<void> deletePago(int pagoId) async {
    await (_db.delete(_db.pagos)..where((p) => p.id.equals(pagoId))).go();
  }

  Future<domain.Pago?> getPagoById(int pagoId) async {
    final row = await (_db.select(_db.pagos)..where((p) => p.id.equals(pagoId))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  domain.Pago _toEntity(Pago row) {
    return domain.Pago(
      id: row.id,
      clienteId: row.clienteId,
      encargoId: row.encargoId,
      monto: row.monto,
      fecha: row.fecha,
      metodo: row.metodo,
      tipo: row.tipo,
      concepto: row.concepto,
    );
  }
}