import 'package:drift/drift.dart';
import '../../../../core/database/database.dart' as db;
import '../../domain/entities/gasto_entity.dart' as domain;
import '../../domain/entities/viaje_entity.dart' as domain_viaje;

class ViajeLocalDataSource {
  final db.AppDatabase _db;

  ViajeLocalDataSource(this._db);

  /// Vigila todos los viajes y reacciona a cambios en viajes o gastos
  Stream<List<domain_viaje.Viaje>> watchViajes() {
    return _db.select(_db.viajes).watch().asyncMap((rows) async {
      final gastos = await _db.select(_db.gastos).get();
      return rows.map((row) => _toEntity(row, gastos.where((g) => g.viajeId == row.id).toList())).toList();
    });
  }

  /// Stream reactivo optimizado que une viaje y gastos
  Stream<domain_viaje.Viaje?> watchViajeById(int viajeId) {
    final query = _db.select(_db.viajes).join([
      leftOuterJoin(_db.gastos, _db.gastos.viajeId.equalsExp(_db.viajes.id)),
    ])..where(_db.viajes.id.equals(viajeId));

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;
      
      final viajeRow = rows.first.readTable(_db.viajes);
      // Obtenemos todos los gastos actualizados para este viaje
      final gastosData = await (_db.select(_db.gastos)..where((g) => g.viajeId.equals(viajeId))).get();
      
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
      await (_db.update(_db.viajes)..where((v) => v.id.equals(viaje.id!))).write(companion);
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

  /// Lógica centralizada: Distribuye el monto del slider sin tocar el precio base
  Future<void> distribuirGastos(int viajeId, int montoADistribuir) async {
    await _db.transaction(() async {
      final productosDelViaje = await (_db.select(_db.productos)
          ..where((p) => p.viajeId.equals(viajeId) & p.activo.equals(true))).get();
      
      // Calculamos la base de inversión. Si no hay productos o precio, usamos la cantidad como peso mínimo.
      double inversionTotal = 0;
      for (final p in productosDelViaje) {
        // Regla 8.3: precioCompra es nullable. Si es null o <= 0, tratamos como 1000 para el peso.
        final int compraVal = p.precioCompra ?? 0;
        final double pesoUnitario = compraVal <= 0 ? 1000.0 : compraVal.toDouble();
        inversionTotal += pesoUnitario * (p.cantidadDisponible <= 0 ? 1.0 : p.cantidadDisponible.toDouble());
      }

      if (inversionTotal <= 0 || montoADistribuir <= 0) {
        await (_db.update(_db.viajes)..where((v) => v.id.equals(viajeId))).write(
          const db.ViajesCompanion(distribuido: Value(true)),
        );
        return;
      }

      for (final producto in productosDelViaje) {
        // Cálculo proporcional del gasto de viaje
        final int compraVal = producto.precioCompra ?? 0;
        final double pesoProducto = (compraVal <= 0 ? 1000.0 : compraVal.toDouble()) * 
                           (producto.cantidadDisponible <= 0 ? 1.0 : producto.cantidadDisponible.toDouble());
        
        final double comisionTotalProducto = (montoADistribuir * (pesoProducto / inversionTotal));
        final double divisor = producto.cantidadDisponible <= 0 ? 1.0 : producto.cantidadDisponible.toDouble();
        
        final int comisionPorUnidad = (comisionTotalProducto / divisor).round();

        // Actualizamos SOLO la comisión. El precioFinal se calcula en la Entidad.
        await (_db.update(_db.productos)..where((p) => p.id.equals(producto.id))).write(
          db.ProductosCompanion(
            comisionViaje: Value(comisionPorUnidad),
          ),
        );
      }

      await (_db.update(_db.viajes)..where((v) => v.id.equals(viajeId))).write(
        const db.ViajesCompanion(distribuido: Value(true)),
      );
    });
  }

  Future<domain_viaje.Viaje?> getViajeById(int viajeId) async {
    final row = await (_db.select(_db.viajes)..where((v) => v.id.equals(viajeId))).getSingleOrNull();
    if (row == null) return null;
    final gastos = await (_db.select(_db.gastos)..where((g) => g.viajeId.equals(viajeId))).get();
    return _toEntity(row, gastos);
  }

  domain_viaje.Viaje _toEntity(db.Viaje row, List<db.Gasto> gastos) {
    return domain_viaje.Viaje(
      id: row.id,
      fecha: row.fecha,
      destino: row.destino,
      observaciones: row.observaciones,
      distribuido: row.distribuido,
      gastos: gastos.map((g) => domain.Gasto(id: g.id, viajeId: g.viajeId, tipo: g.tipo, monto: g.monto)).toList(),
    );
  }
}
