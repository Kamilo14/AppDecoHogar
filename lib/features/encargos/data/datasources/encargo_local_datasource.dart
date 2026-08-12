import 'package:drift/drift.dart';
import '../../../../core/database/database.dart' as db;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/encargo_detalle_entity.dart' as domain;
import '../../domain/entities/encargo_entity.dart' as domain;

class EncargoLocalDataSource {
  final db.AppDatabase _db;

  EncargoLocalDataSource(this._db);

  Stream<List<domain.Encargo>> watchEncargos() {
    return (_db.select(_db.encargos)
          ..where((e) => e.activo.equals(true))
          ..orderBy([(e) => OrderingTerm.desc(e.fecha)]))
        .watch()
        .asyncMap((rows) async {
          final details = await _db.select(_db.encargoDetalle).get();
          return rows.map((row) {
            return _toEntity(
              row,
              details.where((detalle) => detalle.encargoId == row.id).toList(),
            );
          }).toList();
        });
  }

  Future<void> saveEncargo(domain.Encargo encargo) async {
    await _db.transaction(() async {
      String? estadoAnterior;
      int correlativo = 1;

      if (encargo.id != null) {
        final actual = await (_db.select(_db.encargos)..where((e) => e.id.equals(encargo.id!))).getSingleOrNull();
        estadoAnterior = actual?.estado;
        correlativo = actual?.correlativoCliente ?? 1;
      } 
      else if (encargo.clienteId != null) {
        final query = _db.select(_db.encargos)
          ..where((e) => e.clienteId.equals(encargo.clienteId!))
          ..orderBy([(e) => OrderingTerm.desc(e.correlativoCliente)])
          ..limit(1);
        final ultimo = await query.getSingleOrNull();
        correlativo = (ultimo?.correlativoCliente ?? 0) + 1;
      }

      if (encargo.estado == 'ENTREGADO' && estadoAnterior != 'ENTREGADO') {
        for (final detalle in encargo.detalles) {
          if (detalle.productoId != null) {
            await _validarStockDisponible(detalle.productoId!, detalle.cantidad);
          }
        }
      }

      final companion = db.EncargosCompanion(
        id: encargo.id == null ? const Value.absent() : Value(encargo.id!),
        clienteId: Value(encargo.clienteId),
        correlativoCliente: Value(correlativo),
        fecha: Value(encargo.fecha),
        fechaEntregaEstimada: Value(encargo.fechaEntregaEstimada),
        estado: Value(encargo.estado),
        observaciones: Value(encargo.observaciones),
        tipoVenta: Value(encargo.tipoVenta),
        activo: Value(encargo.activo),
      );

      int encargoId;
      if (encargo.id != null) {
        encargoId = encargo.id!;
        await (_db.update(_db.encargos)..where((e) => e.id.equals(encargoId))).write(companion);
        await (_db.delete(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargoId))).go();
      } else {
        encargoId = await _db.into(_db.encargos).insert(companion);
      }

      for (final detalle in encargo.detalles) {
        // Corrección definitiva de Variable: El tipo genérico T debe ser Object. 
        // Drift maneja el valor nulo internamente si pasamos el tipo base.
        await _db.customInsert(
          'INSERT INTO encargo_detalle (encargo_id, producto_id, nombre_temporal, cantidad, precio_unitario, costo_unitario) VALUES (?, ?, ?, ?, ?, ?)',
          variables: [
            Variable<int>(encargoId),
            Variable<int>(detalle.productoId), // detalle.productoId es int?, Variable<int> lo acepta
            Variable<String>(detalle.nombreTemporal), // detalle.nombreTemporal es String?, Variable<String> lo acepta
            Variable<int>(detalle.cantidad),
            Variable<int>(detalle.precioUnitario),
            Variable<int>(detalle.costoUnitario),
          ],
        );
      }

      if (encargo.estado == 'ENTREGADO' && estadoAnterior != 'ENTREGADO') {
        for (final detalle in encargo.detalles) {
          if (detalle.productoId != null) {
            await _descontarStock(detalle.productoId!, detalle.cantidad);
          }
        }
      }
    });
  }

  Future<void> _validarStockDisponible(int productoId, int cantidad) async {
    final prod = await (_db.select(_db.productos)..where((p) => p.id.equals(productoId))).getSingleOrNull();
    if (prod == null) return; 
    if (prod.precioCompra != null && prod.cantidadDisponible < cantidad) {
      throw ValidationFailure('Stock insuficiente');
    }
  }

  Future<void> _descontarStock(int productoId, int cantidad) async {
    final prod = await (_db.select(_db.productos)..where((p) => p.id.equals(productoId))).getSingleOrNull();
    if (prod != null) {
      final nuevaCantidad = prod.cantidadDisponible - cantidad;
      await (_db.update(_db.productos)..where((p) => p.id.equals(productoId))).write(
        db.ProductosCompanion(cantidadDisponible: Value(nuevaCantidad < 0 ? 0 : nuevaCantidad)),
      );
    }
  }

  Future<void> changeEstadoEncargo(int encargoId, String nuevoEstado) async {
    await _db.transaction(() async {
      final encargoRow = await (_db.select(_db.encargos)..where((e) => e.id.equals(encargoId))).getSingleOrNull();
      if (encargoRow == null) return;

      if (nuevoEstado == 'ENTREGADO' && encargoRow.estado != 'ENTREGADO') {
        final detalles = await (_db.select(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargoId))).get();
        for (final d in detalles) {
          if (d.productoId != null) {
            await _validarStockDisponible(d.productoId!, d.cantidad);
            await _descontarStock(d.productoId!, d.cantidad);
          }
        }
      }

      await (_db.update(_db.encargos)..where((e) => e.id.equals(encargoId))).write(
        db.EncargosCompanion(estado: Value(nuevoEstado)),
      );
    });
  }

  Future<void> convertEncargoAVenta(int encargoId) async {
    await changeEstadoEncargo(encargoId, 'ENTREGADO');
  }

  Future<void> deleteEncargo(int encargoId) async {
    await (_db.update(_db.encargos)..where((e) => e.id.equals(encargoId))).write(
      const db.EncargosCompanion(activo: Value(false)),
    );
  }

  Future<domain.Encargo?> getEncargoById(int encargoId) async {
    final row = await (_db.select(_db.encargos)..where((e) => e.id.equals(encargoId))).getSingleOrNull();
    if (row == null) return null;
    final details = await (_db.select(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargoId))).get();
    return _toEntity(row, details);
  }

  domain.Encargo _toEntity(db.Encargo row, List<db.EncargoDetalleData> details) {
    return domain.Encargo(
      id: row.id,
      clienteId: row.clienteId,
      correlativoCliente: row.correlativoCliente,
      fecha: row.fecha,
      fechaEntregaEstimada: row.fechaEntregaEstimada,
      estado: row.estado,
      observaciones: row.observaciones,
      tipoVenta: row.tipoVenta,
      activo: row.activo,
      detalles: details
          .map(
            (detalle) => domain.EncargoDetalle(
              id: detalle.id,
              encargoId: detalle.encargoId,
              productoId: detalle.productoId,
              nombreTemporal: _getNombreTemporalSafe(detalle), 
              cantidad: detalle.cantidad,
              precioUnitario: detalle.precioUnitario,
              costoUnitario: detalle.costoUnitario,
            ),
          )
          .toList(),
    );
  }

  String? _getNombreTemporalSafe(db.EncargoDetalleData data) {
    try {
      return (data as dynamic).nombreTemporal as String?;
    } catch (_) {
      return null;
    }
  }
}
