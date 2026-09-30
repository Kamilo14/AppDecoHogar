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
        .join([
          leftOuterJoin(_db.encargoDetalle,
              _db.encargoDetalle.encargoId.equalsExp(_db.encargos.id))
        ])
        .watch()
        .map((rows) {
          final orders = <int, db.Encargo>{};
          final details = <int, List<db.EncargoDetalleData>>{};
          for (final row in rows) {
            final order = row.readTable(_db.encargos);
            orders[order.id] = order;
            final detail = row.readTableOrNull(_db.encargoDetalle);
            if (detail != null) (details[order.id] ??= []).add(detail);
          }
          return orders.values
              .map((e) => _toEntity(e, details[e.id] ?? []))
              .toList();
        });
  }

  bool _entregado(String estado) =>
      estado == 'ENTREGADO' || estado == 'FINALIZADO';

  Future<int> saveEncargo(domain.Encargo encargo,
      {int? montoPagoInicial,
      String? metodoPago,
      bool liquidarSaldo = false}) async {
    return _db.transaction(() async {
      final previo =
          encargo.id == null ? null : await getEncargoById(encargo.id!);
      if (encargo.id != null && previo == null) {
        throw ValidationFailure(
            'El encargo ya no existe. Vuelve a abrir la lista.');
      }
      if (encargo.detalles.isEmpty)
        throw ValidationFailure('Añade al menos un producto.');
      if (previo != null && !previo.activo)
        throw ValidationFailure('El encargo está eliminado.');
      if (previo != null && previo.clienteId != encargo.clienteId) {
        final pagos = await (_db.select(_db.pagos)
              ..where((p) => p.encargoId.equals(previo.id!)))
            .get();
        if (pagos.isNotEmpty)
          throw ValidationFailure(
              'No se puede cambiar el cliente de un encargo con pagos.');
      }
      final detalles = <domain.EncargoDetalle>[];
      final ocupacion = await _db.customSelect('''
        SELECT d.compra_id, SUM(d.cantidad) AS unidades FROM encargo_detalle d
        JOIN encargos e ON e.id = d.encargo_id WHERE e.activo = 1 AND e.id != ?
        AND d.compra_id IS NOT NULL AND (d.comprado = 1 OR e.estado IN ('ENTREGADO', 'FINALIZADO'))
        GROUP BY d.compra_id''',
          variables: [Variable.withInt(encargo.id ?? -1)]).get();
      final ocupadas = <int, int>{
        for (final r in ocupacion)
          r.read<int>('compra_id'): r.read<int>('unidades')
      };
      final consumo = await _db.customSelect(
          '''SELECT d.compra_id, SUM(d.cantidad) AS unidades,
        SUM(COALESCE(d.costo_logistica, 0)) AS logistica FROM encargo_detalle d
        JOIN encargos e ON e.id = d.encargo_id WHERE e.activo = 1 AND e.id != ?
        AND d.compra_id IS NOT NULL AND e.estado IN ('ENTREGADO','FINALIZADO') GROUP BY d.compra_id''',
          variables: [Variable.withInt(encargo.id ?? -1)]).get();
      final vendidas = <int, int>{
        for (final r in consumo)
          r.read<int>('compra_id'): r.read<int>('unidades')
      };
      final logisticaUsada = <int, int>{
        for (final r in consumo)
          r.read<int>('compra_id'): r.read<int>('logistica')
      };
      Future<void> agregarConCompra(
          domain.EncargoDetalle d, db.Compra compra) async {
        final usadas = ocupadas[compra.id] ?? 0;
        if (compra.productoId != d.productoId ||
            usadas + d.cantidad > compra.cantidad) {
          throw ValidationFailure(
              'La compra no tiene suficientes unidades libres para este producto.');
        }
        if (encargo.tipoVenta == 'Por encargo' &&
            (!d.comprado || d.unidadesCompradas != compra.cantidad)) {
          throw ValidationFailure(
              'La cantidad comprada se conserva desde el viaje. Solo cambia las unidades para el cliente.');
        }
        var logistica = compra.gastoAsignado * d.cantidad ~/ compra.cantidad;
        if (_entregado(encargo.estado)) {
          final anterior = previo?.detalles
              .where((p) => p.compraId == compra.id && p.cantidad == d.cantidad)
              .firstOrNull;
          final remanente =
              compra.gastoAsignado - (logisticaUsada[compra.id] ?? 0);
          if (previo != null &&
              _entregado(previo.estado) &&
              anterior?.costoLogistica != null) {
            logistica = anterior!.costoLogistica!;
          } else if ((vendidas[compra.id] ?? 0) + d.cantidad ==
              compra.cantidad) {
            logistica = remanente;
          } else {
            logistica =
                logistica.clamp(0, remanente < 0 ? 0 : remanente).toInt();
          }
          vendidas.update(compra.id, (n) => n + d.cantidad,
              ifAbsent: () => d.cantidad);
          logisticaUsada.update(compra.id, (n) => n + logistica,
              ifAbsent: () => logistica);
        }
        detalles.add(d.copyWith(
            compraId: compra.id,
            costoUnitario: compra.costoUnitario,
            costoLogistica: logistica));
        ocupadas[compra.id] = usadas + d.cantidad;
      }

      for (final d in encargo.detalles) {
        final comprado = d.comprado || encargo.estado == 'COMPRADO';
        if (d.unidadesCompradas < d.cantidad || d.unidadesCompradas <= 0) {
          throw ValidationFailure(
              'La cantidad comprada debe ser igual o mayor que la cantidad para el cliente.');
        }
        if (d.cantidad <= 0)
          throw ValidationFailure('La cantidad debe ser mayor a cero.');
        if (comprado || _entregado(encargo.estado)) {
          if (d.costoUnitario == null ||
              d.costoUnitario! < 0 ||
              d.precioUnitario == null ||
              d.precioUnitario! <= 0) {
            throw ValidationFailure(
                'Ingresa costo y precio de venta de los productos comprados.');
          }
        }
        if (_entregado(encargo.estado) &&
            encargo.tipoVenta == 'Por encargo' &&
            !comprado) {
          throw ValidationFailure(
              'Marca como comprados todos los productos antes de entregar.');
        }
        int? productoId = d.productoId;
        db.Producto? producto;
        if (productoId != null) {
          producto = await (_db.select(_db.productos)
                ..where((p) => p.id.equals(productoId!)))
              .getSingleOrNull();
          if (producto == null) productoId = null;
        }
        final nombre = d.nombreTemporal?.trim();
        if (encargo.tipoVenta != 'Por encargo' &&
            (productoId == null || producto?.activo != true)) {
          throw ValidationFailure(
              'Selecciona un producto existente del inventario para la venta.');
        }
        if (productoId == null && (nombre == null || nombre.isEmpty)) {
          throw ValidationFailure(
              'El producto ya no existe. Escribe su nombre nuevamente.');
        }
        // Un recordatorio no crea inventario; al comprar se resuelve un ID real.
        if (productoId == null && (comprado || _entregado(encargo.estado))) {
          producto = await (_db.select(_db.productos)
                ..where((p) => p.nombre.equals(nombre!))
                ..limit(1))
              .getSingleOrNull();
          productoId = producto?.id ??
              await _db.into(_db.productos).insert(db.ProductosCompanion.insert(
                  nombre: nombre!,
                  precioCompra: Value(d.costoUnitario),
                  precioVenta: Value(d.precioUnitario)));
        }
        final detalle = domain.EncargoDetalle(
            productoId: productoId,
            nombreTemporal: nombre ?? producto?.nombre,
            cantidad: d.cantidad,
            cantidadComprada: d.unidadesCompradas,
            comprado: comprado,
            compraId: d.compraId,
            costoLogistica:
                d.costoLogistica ?? (producto?.comisionViaje ?? 0) * d.cantidad,
            costoUnitario: d.costoUnitario,
            precioUnitario: d.precioUnitario);
        if (d.compraId != null) {
          final compra = await (_db.select(_db.compras)
                ..where((c) => c.id.equals(d.compraId!)))
              .getSingle();
          await agregarConCompra(detalle, compra);
        } else if (encargo.tipoVenta != 'Por encargo' &&
            _entregado(encargo.estado)) {
          var faltan = d.cantidad;
          final compras = await (_db.select(_db.compras)
                ..where((c) => c.productoId.equals(productoId!))
                ..orderBy([
                  (c) => OrderingTerm.asc(c.fecha),
                  (c) => OrderingTerm.asc(c.id)
                ]))
              .get();
          for (final compra in compras) {
            final libres = compra.cantidad - (ocupadas[compra.id] ?? 0);
            final tomar = faltan < libres ? faltan : libres;
            if (tomar <= 0) continue;
            await agregarConCompra(
                detalle.copyWith(cantidad: tomar, cantidadComprada: tomar),
                compra);
            faltan -= tomar;
            if (faltan == 0) break;
          }
          // Existencias anteriores al registro de compras: conservar el costo del catálogo.
          if (faltan > 0)
            detalles.add(detalle.copyWith(
                cantidad: faltan,
                cantidadComprada: faltan,
                costoLogistica: (producto?.comisionViaje ?? 0) * faltan));
        } else {
          detalles.add(detalle);
        }
      }
      final estado = _entregado(encargo.estado)
          ? encargo.estado
          : detalles.every((d) => d.comprado)
              ? 'COMPRADO'
              : 'PENDIENTE';
      var correlativo = previo?.correlativoCliente ?? 1;
      if (previo == null && encargo.clienteId != null) {
        final ultimo = await (_db.select(_db.encargos)
              ..where((e) => e.clienteId.equals(encargo.clienteId!))
              ..orderBy([(e) => OrderingTerm.desc(e.correlativoCliente)])
              ..limit(1))
            .getSingleOrNull();
        correlativo = (ultimo?.correlativoCliente ?? 0) + 1;
      }
      final values = db.EncargosCompanion(
          clienteId: Value(encargo.clienteId),
          correlativoCliente: Value(correlativo),
          fecha: Value(encargo.fecha),
          fechaEntregaReal: Value(_entregado(estado)
              ? previo?.fechaEntregaReal ?? DateTime.now()
              : null),
          fechaEntregaEstimada: Value(encargo.fechaEntregaEstimada),
          estado: Value(estado),
          observaciones: Value(encargo.observaciones),
          tipoVenta: Value(encargo.tipoVenta),
          activo: Value(encargo.activo));
      final id = previo?.id ?? await _db.into(_db.encargos).insert(values);
      if (previo != null) {
        await (_db.update(_db.encargos)..where((e) => e.id.equals(id)))
            .write(values);
        await (_db.delete(_db.encargoDetalle)
              ..where((d) => d.encargoId.equals(id)))
            .go();
      }
      // Diferencia entre efecto anterior y nuevo: editar no duplica inventario.
      final deltas = <int, int>{};
      void acumular(List<domain.EncargoDetalle> items, String estado,
          String tipo, int signo) {
        for (final d in items) {
          if (d.productoId == null) continue;
          final entrada =
              tipo == 'Por encargo' && d.comprado && d.compraId == null
                  ? d.unidadesCompradas
                  : 0;
          final salida = _entregado(estado) ? d.cantidad : 0;
          deltas.update(d.productoId!, (v) => v + signo * (entrada - salida),
              ifAbsent: () => signo * (entrada - salida));
        }
      }

      if (previo != null)
        acumular(previo.detalles, previo.estado, previo.tipoVenta, -1);
      acumular(detalles, estado, encargo.tipoVenta, 1);
      for (final entry in deltas.entries) {
        final producto = await (_db.select(_db.productos)
              ..where((p) => p.id.equals(entry.key)))
            .getSingle();
        final stock = producto.cantidadDisponible + entry.value;
        final reserva = await _db
            .customSelect('''SELECT COALESCE(SUM(d.cantidad), 0) AS unidades
          FROM encargo_detalle d JOIN encargos e ON e.id = d.encargo_id
          WHERE e.activo = 1 AND e.estado NOT IN ('ENTREGADO','FINALIZADO')
          AND d.comprado = 1 AND d.producto_id = ? AND e.id != ?''',
                variables: [
              Variable.withInt(entry.key),
              Variable.withInt(id)
            ]).getSingle();
        final reservaPropia = _entregado(estado)
            ? 0
            : detalles
                .where((d) => d.comprado && d.productoId == entry.key)
                .fold<int>(0, (s, d) => s + d.cantidad);
        if (stock < reserva.read<int>('unidades') + reservaPropia)
          throw ValidationFailure(
              'Stock insuficiente para "${producto.nombre}".');
        await (_db.update(_db.productos)..where((p) => p.id.equals(entry.key)))
            .write(db.ProductosCompanion(cantidadDisponible: Value(stock)));
      }
      for (final d in detalles) {
        if (d.comprado &&
            d.compraId == null &&
            d.productoId != null &&
            !(previo?.detalles
                    .any((p) => p.productoId == d.productoId && p.comprado) ??
                false)) {
          await (_db.update(_db.productos)
                ..where((p) => p.id.equals(d.productoId!)))
              .write(db.ProductosCompanion(
                  precioCompra: Value(d.costoUnitario),
                  precioVenta: Value(d.precioUnitario)));
        }
        await _db.into(_db.encargoDetalle).insert(
            db.EncargoDetalleCompanion.insert(
                encargoId: id,
                productoId: Value(d.productoId),
                nombreTemporal: Value(d.nombreTemporal),
                cantidad: d.cantidad,
                cantidadComprada: Value(d.unidadesCompradas),
                compraId: Value(d.compraId),
                costoLogistica: Value(d.costoLogistica),
                comprado: Value(d.comprado),
                precioUnitario: Value(d.precioUnitario),
                costoUnitario: Value(d.costoUnitario)));
      }
      final total =
          encargo.copyWith(estado: estado, detalles: detalles).totalExigible;
      final pagos = await (_db.select(_db.pagos)
            ..where((p) => p.encargoId.equals(id)))
          .get();
      final abonado = pagos.fold(0, (sum, p) => sum + p.monto);
      var saldo = (total - abonado).clamp(0, total);
      // También respetar abonos generales registrados desde la ficha del cliente.
      if (encargo.clienteId != null) {
        final cuenta = await _db.customSelect('''
          SELECT COALESCE(SUM(d.cantidad * COALESCE(d.precio_unitario, 0)), 0) AS cargos
          FROM encargos e JOIN encargo_detalle d ON d.encargo_id = e.id
          WHERE e.cliente_id = ? AND e.activo = 1
            AND (e.estado != 'PENDIENTE' OR d.comprado = 1)
        ''', variables: [Variable.withInt(encargo.clienteId!)]).getSingle();
        final pagosCliente = await (_db.select(_db.pagos)
              ..where((p) => p.clienteId.equals(encargo.clienteId!)))
            .get();
        final deudaGlobal = cuenta.read<int>('cargos') -
            pagosCliente.fold(0, (s, p) => s + p.monto);
        saldo = saldo.clamp(0, deudaGlobal < 0 ? 0 : deudaGlobal).toInt();
      }
      final monto = liquidarSaldo ? saldo : montoPagoInicial ?? 0;
      if (monto < 0 || monto > saldo)
        throw ValidationFailure(
            'El abono no puede superar el saldo pendiente.');
      if (estado == 'FINALIZADO' && monto < saldo)
        throw ValidationFailure(
            'Para finalizar, registra el pago del saldo pendiente.');
      if (monto > 0 && encargo.clienteId != null) {
        await _db.into(_db.pagos).insert(db.PagosCompanion.insert(
            clienteId: encargo.clienteId!,
            encargoId: Value(id),
            monto: monto,
            fecha: DateTime.now(),
            metodo: metodoPago ?? 'Efectivo',
            tipo: monto == saldo ? 'PAGO_TOTAL' : 'ABONO',
            concepto: Value('Pago encargo ENC-$id')));
      }
      return id;
    });
  }

  Future<void> changeEstadoEncargo(int encargoId, String nuevoEstado) async {
    await _db.transaction(() async {
      final actual = await getEncargoById(encargoId);
      if (actual == null || actual.estado == nuevoEstado) return;
      await saveEncargo(actual.copyWith(estado: nuevoEstado));
    });
  }

  Future<void> convertEncargoAVenta(int encargoId) =>
      changeEstadoEncargo(encargoId, 'ENTREGADO');

  Future<void> deleteEncargo(int encargoId) async {
    await _db.transaction(() async {
      final actual = await getEncargoById(encargoId);
      if (actual == null || !actual.activo) return;
      // Cancelar la venta devuelve unidades; las compras físicas se conservan.
      if (_entregado(actual.estado)) {
        for (final d in actual.detalles) {
          if (d.productoId == null) continue;
          final p = await (_db.select(_db.productos)
                ..where((p) => p.id.equals(d.productoId!)))
              .getSingle();
          await (_db.update(_db.productos)
                ..where((p) => p.id.equals(d.productoId!)))
              .write(db.ProductosCompanion(
                  cantidadDisponible:
                      Value(p.cantidadDisponible + d.cantidad)));
        }
      }
      await (_db.update(_db.encargos)..where((e) => e.id.equals(encargoId)))
          .write(const db.EncargosCompanion(activo: Value(false)));
    });
  }

  Future<domain.Encargo?> getEncargoById(int id) async {
    final row = await (_db.select(_db.encargos)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final details = await (_db.select(_db.encargoDetalle)
          ..where((d) => d.encargoId.equals(id)))
        .get();
    return _toEntity(row, details);
  }

  domain.Encargo _toEntity(
          db.Encargo row, List<db.EncargoDetalleData> details) =>
      domain.Encargo(
          id: row.id,
          clienteId: row.clienteId,
          correlativoCliente: row.correlativoCliente,
          fecha: row.fecha,
          fechaEntregaReal: row.fechaEntregaReal,
          fechaEntregaEstimada: row.fechaEntregaEstimada,
          estado: row.estado,
          observaciones: row.observaciones,
          tipoVenta: row.tipoVenta,
          activo: row.activo,
          detalles: details
              .map((d) => domain.EncargoDetalle(
                  id: d.id,
                  encargoId: d.encargoId,
                  productoId: d.productoId,
                  nombreTemporal: d.nombreTemporal,
                  cantidad: d.cantidad,
                  cantidadComprada: d.cantidadComprada,
                  compraId: d.compraId,
                  costoLogistica: d.costoLogistica,
                  comprado: d.comprado,
                  precioUnitario: d.precioUnitario,
                  costoUnitario: d.costoUnitario))
              .toList());
}
