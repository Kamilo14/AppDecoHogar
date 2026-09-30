import 'package:drift/drift.dart';
import '../../../../core/database/database.dart' as db;
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

  /// Guarda un encargo y opcionalmente registra un pago inicial en la misma transacción
  Future<int> saveEncargo(domain.Encargo encargo, {int? montoPagoInicial, String? metodoPago}) async {
    return await _db.transaction(() async {
      String? estadoAnterior;
      int correlativo = 1;

      if (encargo.id != null) {
        final actual = await (_db.select(_db.encargos)..where((e) => e.id.equals(encargo.id!))).getSingleOrNull();
        estadoAnterior = actual?.estado;
        correlativo = actual?.correlativoCliente ?? 1;
        
        // Revertir stock si ya estaba entregado para validar contra el stock "limpio"
        if (estadoAnterior == 'ENTREGADO') {
          final detallesPrevios = await (_db.select(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargo.id!))).get();
          for (final d in detallesPrevios) {
            if (d.productoId != null) await _ajustarStock(d.productoId!, d.cantidad);
          }
        }
      } 
      else if (encargo.clienteId != null) {
        final ultimo = await (_db.select(_db.encargos)
          ..where((e) => e.clienteId.equals(encargo.clienteId!))
          ..orderBy([(e) => OrderingTerm.desc(e.correlativoCliente)])
          ..limit(1)).getSingleOrNull();
        correlativo = (ultimo?.correlativoCliente ?? 0) + 1;
      }

      // VALIDACIÓN DE STOCK ANTES DE PROCESAR
      if (encargo.estado == 'ENTREGADO') {
        for (final detalle in encargo.detalles) {
          if (detalle.productoId != null) {
            final prod = await (_db.select(_db.productos)..where((p) => p.id.equals(detalle.productoId!))).getSingleOrNull();
            if (prod != null && prod.cantidadDisponible < detalle.cantidad) {
              throw Exception('Stock insuficiente para "${prod.nombre}". Disponible: ${prod.cantidadDisponible}, Solicitado: ${detalle.cantidad}');
            }
          }
        }
      }

      final encargoId = await _db.into(_db.encargos).insertVariant(db.EncargosCompanion(
        id: encargo.id == null ? const Value.absent() : Value(encargo.id!),
        clienteId: Value(encargo.clienteId),
        correlativoCliente: Value(correlativo),
        fecha: Value(encargo.fecha),
        fechaEntregaEstimada: Value(encargo.fechaEntregaEstimada),
        estado: Value(encargo.estado),
        observaciones: Value(encargo.observaciones),
        tipoVenta: Value(encargo.tipoVenta),
        activo: Value(encargo.activo),
      ));

      if (encargo.id != null) {
        await (_db.delete(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargoId))).go();
      }

      for (final detalle in encargo.detalles) {
        int? pId = detalle.productoId;
        if (pId == null && detalle.nombreTemporal != null && detalle.nombreTemporal!.isNotEmpty) {
          final exist = await (_db.select(_db.productos)..where((p) => p.nombre.equals(detalle.nombreTemporal!))..limit(1)).getSingleOrNull();
          pId = exist?.id ?? await _db.into(_db.productos).insert(db.ProductosCompanion.insert(nombre: detalle.nombreTemporal!, cantidadDisponible: const Value(0)));
        }

        await _db.into(_db.encargoDetalle).insert(db.EncargoDetalleCompanion.insert(
          encargoId: encargoId,
          productoId: Value(pId),
          nombreTemporal: Value(detalle.nombreTemporal),
          cantidad: detalle.cantidad,
          precioUnitario: Value(detalle.precioUnitario),
          costoUnitario: Value(detalle.costoUnitario),
        ));

        // Descontar stock si se entrega ahora
        if (encargo.estado == 'ENTREGADO' && pId != null) {
          await _ajustarStock(pId, -detalle.cantidad);
        }
      }

      // REGISTRO DE PAGO ATÓMICO
      if (montoPagoInicial != null && montoPagoInicial > 0 && encargo.clienteId != null) {
        await _db.into(_db.pagos).insert(db.PagosCompanion.insert(
          clienteId: encargo.clienteId!,
          encargoId: Value(encargoId),
          monto: montoPagoInicial,
          fecha: DateTime.now(),
          metodo: metodoPago ?? 'Efectivo',
          tipo: 'PAGO_TOTAL',
          concepto: Value('Pago automático venta #${encargoId}'),
        ));
      }

      return encargoId;
    });
  }

  Future<void> _ajustarStock(int productoId, int delta) async {
    final prod = await (_db.select(_db.productos)..where((p) => p.id.equals(productoId))).getSingleOrNull();
    if (prod != null) {
      await (_db.update(_db.productos)..where((p) => p.id.equals(productoId))).write(
        db.ProductosCompanion(cantidadDisponible: Value((prod.cantidadDisponible + delta).clamp(0, 999999))),
      );
    }
  }

  Future<void> changeEstadoEncargo(int encargoId, String nuevoEstado) async {
    await _db.transaction(() async {
      final actual = await (_db.select(_db.encargos)..where((e) => e.id.equals(encargoId))).getSingleOrNull();
      if (actual == null || actual.estado == nuevoEstado) return;
      final detalles = await (_db.select(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargoId))).get();
      
      if (nuevoEstado == 'ENTREGADO') {
        // VALIDACIÓN DE STOCK antes de descontar
        for (final d in detalles) {
          if (d.productoId != null) {
            final prod = await (_db.select(_db.productos)..where((p) => p.id.equals(d.productoId!))).getSingleOrNull();
            if (prod != null && prod.cantidadDisponible < d.cantidad) {
              throw Exception('Stock insuficiente para "${prod.nombre}". Disponible: ${prod.cantidadDisponible}');
            }
          }
        }
        for (final d in detalles) if (d.productoId != null) await _ajustarStock(d.productoId!, -d.cantidad);
      } else if (actual.estado == 'ENTREGADO') {
        for (final d in detalles) if (d.productoId != null) await _ajustarStock(d.productoId!, d.cantidad);
      }
      
      await (_db.update(_db.encargos)..where((e) => e.id.equals(encargoId))).write(db.EncargosCompanion(estado: Value(nuevoEstado)));
    });
  }

  Future<void> convertEncargoAVenta(int encargoId) async => changeEstadoEncargo(encargoId, 'ENTREGADO');

  Future<void> deleteEncargo(int encargoId) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.encargos)..where((e) => e.id.equals(encargoId))).getSingleOrNull();
      if (row == null || !row.activo) return;
      if (row.estado == 'ENTREGADO') {
        final dets = await (_db.select(_db.encargoDetalle)..where((d) => d.encargoId.equals(encargoId))).get();
        for (final d in dets) if (d.productoId != null) await _ajustarStock(d.productoId!, d.cantidad);
      }
      await (_db.update(_db.encargos)..where((e) => e.id.equals(encargoId))).write(const db.EncargosCompanion(activo: Value(false)));
    });
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
      detalles: details.map((d) => domain.EncargoDetalle(
        id: d.id,
        encargoId: d.encargoId,
        productoId: d.productoId,
        nombreTemporal: d.nombreTemporal, 
        cantidad: d.cantidad,
        precioUnitario: d.precioUnitario,
        costoUnitario: d.costoUnitario,
      )).toList(),
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
