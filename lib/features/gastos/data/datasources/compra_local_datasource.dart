import 'package:drift/drift.dart';
import '../../../../core/database/database.dart' as db;
import '../../../../core/errors/failures.dart';
import '../../../encargos/data/datasources/encargo_local_datasource.dart';
import '../../../encargos/domain/entities/encargo_entity.dart' as domain;

class EntradaCompra {
  final int? productoId, encargoId, detalleId;
  final String nombre;
  final int cantidad, costoUnitario, precioVenta, cantidadCliente;
  const EntradaCompra(
      {this.productoId,
      this.encargoId,
      this.detalleId,
      required this.nombre,
      required this.cantidad,
      required this.costoUnitario,
      required this.precioVenta,
      this.cantidadCliente = 0});
}

class CompraLocalDataSource {
  final db.AppDatabase database;
  CompraLocalDataSource(this.database);

  Stream<List<db.Compra>> watchCompras() => (database.select(database.compras)
        ..orderBy([
          (c) => OrderingTerm.desc(c.fecha),
          (c) => OrderingTerm.desc(c.id)
        ]))
      .watch();

  Future<void> registrar(int viajeId, List<EntradaCompra> entradas) async {
    if (entradas.isEmpty)
      throw ValidationFailure('Agrega al menos una compra.');
    await database.transaction(() async {
      final viaje = await (database.select(database.viajes)
            ..where((v) => v.id.equals(viajeId)))
          .getSingle();
      final source = EncargoLocalDataSource(database);
      final encargos = <int, domain.Encargo>{};
      final seleccionados = <int>{};
      for (final entrada in entradas) {
        if (entrada.cantidad <= 0 ||
            entrada.costoUnitario < 0 ||
            entrada.precioVenta <= 0 ||
            entrada.nombre.trim().isEmpty) {
          throw ValidationFailure(
              'Revisa nombre, cantidad, costo y precio de cada compra.');
        }
        db.Producto? producto;
        if (entrada.productoId != null) {
          producto = await (database.select(database.productos)
                ..where((p) => p.id.equals(entrada.productoId!)))
              .getSingleOrNull();
          if (producto == null || !producto.activo)
            throw ValidationFailure(
                'El producto seleccionado no está disponible.');
        } else {
          final catalogo = await database.select(database.productos).get();
          producto = catalogo
              .where((p) =>
                  p.nombre.trim().toLowerCase() ==
                  entrada.nombre.trim().toLowerCase())
              .firstOrNull;
          if (producto != null && !producto.activo)
            throw ValidationFailure(
                'Reactiva el producto existente antes de comprarlo.');
        }
        final productoId = producto?.id ??
            await database.into(database.productos).insert(
                db.ProductosCompanion.insert(
                    nombre: entrada.nombre.trim(),
                    precioCompra: Value(entrada.costoUnitario),
                    precioVenta: Value(entrada.precioVenta)));
        final compraId = await database.into(database.compras).insert(
            db.ComprasCompanion.insert(
                viajeId: viajeId,
                productoId: productoId,
                nombreProducto: producto?.nombre ?? entrada.nombre.trim(),
                fecha: viaje.fecha,
                cantidad: entrada.cantidad,
                costoUnitario: entrada.costoUnitario,
                precioVenta: entrada.precioVenta));
        await (database.update(database.productos)
              ..where((p) => p.id.equals(productoId)))
            .write(db.ProductosCompanion(
                cantidadDisponible: Value(
                    (producto?.cantidadDisponible ?? 0) + entrada.cantidad),
                precioCompra: Value(entrada.costoUnitario),
                precioVenta: Value(entrada.precioVenta),
                comisionViaje: const Value(0),
                viajeId: Value(viajeId)));
        if (entrada.encargoId != null) {
          if (entrada.detalleId == null ||
              !seleccionados.add(entrada.detalleId!) ||
              entrada.cantidadCliente <= 0 ||
              entrada.cantidadCliente > entrada.cantidad) {
            throw ValidationFailure(
                'Selecciona una línea de encargo una sola vez y revisa sus cantidades.');
          }
          final encargo = encargos[entrada.encargoId] ??
              await source.getEncargoById(entrada.encargoId!);
          if (encargo == null ||
              !encargo.activo ||
              encargo.estado != 'PENDIENTE')
            throw ValidationFailure('El encargo ya no está pendiente.');
          final detalle = encargo.detalles
              .where((d) => d.id == entrada.detalleId)
              .firstOrNull;
          if (detalle == null || detalle.comprado || detalle.compraId != null)
            throw ValidationFailure(
                'Ese producto del encargo ya tiene una compra registrada.');
          if (detalle.productoId != null && detalle.productoId != productoId)
            throw ValidationFailure(
                'La compra debe corresponder al producto del encargo.');
          encargos[entrada.encargoId!] = encargo.copyWith(
              detalles: encargo.detalles
                  .map((d) => d.id != entrada.detalleId
                      ? d
                      : d.copyWith(
                          productoId: productoId,
                          compraId: compraId,
                          nombreTemporal: entrada.nombre.trim(),
                          cantidad: entrada.cantidadCliente,
                          cantidadComprada: entrada.cantidad,
                          comprado: true,
                          costoUnitario: entrada.costoUnitario,
                          precioUnitario: entrada.precioVenta,
                          costoLogistica: 0))
                  .toList());
        }
      }
      for (final encargo in encargos.values) {
        await source.saveEncargo(encargo);
      }
    });
  }

  Future<void> distribuir(int viajeId, int monto) async {
    await database.transaction(() async {
      final gastos = await (database.select(database.gastos)
            ..where((g) => g.viajeId.equals(viajeId)))
          .get();
      final total = gastos.fold<int>(0, (s, g) => s + g.monto);
      final compras = await (database.select(database.compras)
            ..where((c) => c.viajeId.equals(viajeId))
            ..orderBy([(c) => OrderingTerm.asc(c.id)]))
          .get();
      if (monto < 0 || monto > total)
        throw ValidationFailure(
            'El reparto debe estar entre cero y el total de gastos.');
      if (compras.isEmpty && monto > 0)
        throw ValidationFailure(
            'Registra las compras de este viaje antes de repartir gastos.');
      final ventas = await database.customSelect(
          '''SELECT d.id FROM encargo_detalle d
        JOIN encargos e ON e.id = d.encargo_id JOIN compras c ON c.id = d.compra_id
        WHERE c.viaje_id = ? AND e.activo = 1 AND e.estado IN ('ENTREGADO', 'FINALIZADO') LIMIT 1''',
          variables: [Variable.withInt(viajeId)]).get();
      final viaje = await (database.select(database.viajes)
            ..where((v) => v.id.equals(viajeId)))
          .getSingle();
      if (ventas.isNotEmpty && monto != viaje.montoDistribuido)
        throw ValidationFailure(
            'Este viaje ya tiene ventas: sus costos están cerrados. Los gastos adicionales quedan como egresos separados.');
      if (ventas.isNotEmpty) return;
      final base = compras.fold<int>(
          0,
          (s, c) =>
              s + (c.costoUnitario > 0 ? c.costoUnitario : 1) * c.cantidad);
      var acumulado = 0;
      var asignado = 0;
      for (final c in compras) {
        acumulado += (c.costoUnitario > 0 ? c.costoUnitario : 1) * c.cantidad;
        final hastaAqui = monto * acumulado ~/ base;
        final parte = hastaAqui - asignado;
        asignado = hastaAqui;
        await (database.update(database.compras)
              ..where((t) => t.id.equals(c.id)))
            .write(db.ComprasCompanion(gastoAsignado: Value(parte)));
        // La ficha del catálogo conserva la sugerencia de la compra más reciente.
        final ultima = await (database.select(database.compras)
              ..where((t) => t.productoId.equals(c.productoId))
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingle();
        if (ultima.id == c.id) {
          await (database.update(database.productos)
                ..where((p) => p.id.equals(c.productoId)))
              .write(db.ProductosCompanion(
                  comisionViaje: Value((parte / c.cantidad).round())));
        }
      }
      await (database.update(database.viajes)
            ..where((v) => v.id.equals(viajeId)))
          .write(db.ViajesCompanion(
              montoDistribuido: Value(monto), distribuido: Value(monto > 0)));
    });
  }
}
