import 'package:drift/drift.dart';
import 'compra_local_datasource.dart';
import '../../../../core/database/database.dart' as db;
import '../../domain/entities/gasto_entity.dart' as domain;
import '../../domain/entities/viaje_entity.dart' as domain_viaje;

class ViajeLocalDataSource {
  final db.AppDatabase _db;

  ViajeLocalDataSource(this._db);

  /// Vigila todos los viajes y reacciona a cambios en viajes o gastos
  Stream<List<domain_viaje.Viaje>> watchViajes() {
    return _db
        .select(_db.viajes)
        .join([
          leftOuterJoin(
              _db.gastos, _db.gastos.viajeId.equalsExp(_db.viajes.id)),
        ])
        .watch()
        .map((rows) {
          final viajes = <int, db.Viaje>{};
          final gastos = <int, List<db.Gasto>>{};
          for (final row in rows) {
            final viaje = row.readTable(_db.viajes);
            viajes[viaje.id] = viaje;
            final gasto = row.readTableOrNull(_db.gastos);
            if (gasto != null) (gastos[viaje.id] ??= []).add(gasto);
          }
          return viajes.values
              .map((v) => _toEntity(v, gastos[v.id] ?? []))
              .toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
        });
  }

  /// Stream reactivo optimizado que une viaje y gastos
  Stream<domain_viaje.Viaje?> watchViajeById(int viajeId) {
    final query = _db.select(_db.viajes).join([
      leftOuterJoin(_db.gastos, _db.gastos.viajeId.equalsExp(_db.viajes.id)),
    ])
      ..where(_db.viajes.id.equals(viajeId));

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;

      final viajeRow = rows.first.readTable(_db.viajes);
      // Obtenemos todos los gastos actualizados para este viaje
      final gastosData = await (_db.select(_db.gastos)
            ..where((g) => g.viajeId.equals(viajeId)))
          .get();

      return _toEntity(viajeRow, gastosData);
    });
  }

  Future<void> saveViaje(domain_viaje.Viaje viaje) async {
    final companion = db.ViajesCompanion(
      id: viaje.id == null ? const Value.absent() : Value(viaje.id!),
      fecha: Value(viaje.fecha),
      destino: Value(viaje.destino),
      observaciones: Value(viaje.observaciones),
      distribuido: Value(viaje.distribuido),
    );

    if (viaje.id == null) {
      await _db.into(_db.viajes).insert(companion);
    } else {
      await (_db.update(_db.viajes)..where((v) => v.id.equals(viaje.id!)))
          .write(companion);
    }
  }

  Future<void> addGasto(domain.Gasto gasto) async {
    await _db.into(_db.gastos).insert(
          db.GastosCompanion.insert(
            viajeId: gasto.viajeId,
            tipo: gasto.tipo,
            monto: gasto.monto,
          ),
        );
  }

  Future<void> distribuirGastos(int viajeId, int montoADistribuir) =>
      CompraLocalDataSource(_db).distribuir(viajeId, montoADistribuir);

  Future<domain_viaje.Viaje?> getViajeById(int viajeId) async {
    final row = await (_db.select(_db.viajes)
          ..where((v) => v.id.equals(viajeId)))
        .getSingleOrNull();
    if (row == null) return null;
    final gastos = await (_db.select(_db.gastos)
          ..where((g) => g.viajeId.equals(viajeId)))
        .get();
    return _toEntity(row, gastos);
  }

  domain_viaje.Viaje _toEntity(db.Viaje row, List<db.Gasto> gastos) {
    return domain_viaje.Viaje(
      id: row.id,
      fecha: row.fecha,
      destino: row.destino,
      observaciones: row.observaciones,
      distribuido: row.distribuido,
      montoDistribuido: row.montoDistribuido,
      gastos: gastos
          .map((g) => domain.Gasto(
              id: g.id, viajeId: g.viajeId, tipo: g.tipo, monto: g.monto))
          .toList(),
    );
  }
}
