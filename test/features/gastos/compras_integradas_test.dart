import 'package:app_deco_hogar/core/database/database.dart' as db;
import 'package:app_deco_hogar/core/errors/failures.dart';
import 'package:app_deco_hogar/features/encargos/data/datasources/encargo_local_datasource.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/gastos/data/datasources/compra_local_datasource.dart';
import 'package:app_deco_hogar/features/gastos/data/datasources/viaje_local_datasource.dart';
import 'package:app_deco_hogar/features/gastos/domain/entities/gasto_entity.dart';
import 'package:app_deco_hogar/features/reportes/domain/usecases/get_reporte_ganancias_usecase.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late db.AppDatabase database;
  late CompraLocalDataSource compras;
  late EncargoLocalDataSource encargos;
  late ViajeLocalDataSource viajes;
  late int clienteId, viajeId;
  setUp(() async {
    database = db.AppDatabase.at(NativeDatabase.memory());
    compras = CompraLocalDataSource(database);
    encargos = EncargoLocalDataSource(database);
    viajes = ViajeLocalDataSource(database);
    clienteId = await database.into(database.clientes).insert(
        db.ClientesCompanion.insert(
            nombre: 'Camilo', fechaRegistro: DateTime(2026)));
    viajeId = await database.into(database.viajes).insert(
        db.ViajesCompanion.insert(
            fecha: DateTime(2026, 9, 30), destino: 'Santiago'));
  });
  tearDown(() => database.close());

  EntradaCompra entrada(
          {String nombre = 'Bandas',
          int cantidad = 10,
          int costo = 1000,
          int? productoId}) =>
      EntradaCompra(
          nombre: nombre,
          cantidad: cantidad,
          costoUnitario: costo,
          precioVenta: 2500,
          productoId: productoId);
  Encargo venta(int productoId, int cantidad) => Encargo(
          clienteId: clienteId,
          fecha: DateTime(2026, 1, 1),
          estado: 'ENTREGADO',
          tipoVenta: 'Venta directa',
          detalles: [
            EncargoDetalle(
                productoId: productoId,
                cantidad: cantidad,
                costoUnitario: 1000,
                precioUnitario: 2500)
          ]);

  test(
      'Compra para encargo registra una sola entrada, reserva 10 y deja 5 libres',
      () async {
    final id = await encargos.saveEncargo(Encargo(
        clienteId: clienteId,
        fecha: DateTime(2026),
        estado: 'PENDIENTE',
        detalles: [
          const EncargoDetalle(nombreTemporal: 'Bandas', cantidad: 15)
        ]));
    final original = (await encargos.getEncargoById(id))!;
    await compras.registrar(viajeId, [
      EntradaCompra(
          nombre: 'Bandas',
          cantidad: 15,
          costoUnitario: 1000,
          precioVenta: 2500,
          encargoId: id,
          detalleId: original.detalles.single.id,
          cantidadCliente: 10)
    ]);
    final comprado = (await encargos.getEncargoById(id))!;
    final producto = (await database.select(database.productos).get()).single;
    expect(producto.cantidadDisponible, 15);
    expect(comprado.detalles.single.compraId, isNotNull);
    expect(comprado.total, 25000);
    expect(producto.cantidadDisponible - comprado.detalles.single.cantidad, 5);
    await expectLater(encargos.saveEncargo(venta(producto.id, 6)),
        throwsA(isA<ValidationFailure>()));
    await encargos.saveEncargo(comprado.copyWith(estado: 'ENTREGADO'),
        liquidarSaldo: true);
    await encargos.saveEncargo((await encargos.getEncargoById(id))!);
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        5);
    expect((await database.select(database.compras).get()).length, 1);
    expect((await database.select(database.pagos).get()).single.monto, 25000);
  });

  test(
      'Compra por lote crea y repone sin duplicar catálogo ni perder viajes anteriores',
      () async {
    await compras.registrar(viajeId,
        [entrada(cantidad: 2), entrada(nombre: 'Poleas', cantidad: 3)]);
    final bandas = (await database.select(database.productos).get())
        .firstWhere((p) => p.nombre == 'Bandas');
    final segundo = await database.into(database.viajes).insert(
        db.ViajesCompanion.insert(
            fecha: DateTime(2026, 10, 10), destino: 'Santiago'));
    await compras.registrar(
        segundo, [entrada(productoId: bandas.id, cantidad: 4, costo: 2000)]);
    expect((await database.select(database.productos).get()).length, 2);
    final comprasGuardadas = await database.select(database.compras).get();
    expect(comprasGuardadas.where((c) => c.viajeId == viajeId).length, 2);
    expect(comprasGuardadas.last.costoUnitario, 2000);
    expect(
        (await database.select(database.productos).get())
            .firstWhere((p) => p.id == bandas.id)
            .cantidadDisponible,
        6);
    final ventaId = await encargos.saveEncargo(venta(bandas.id, 3));
    final vendida = (await encargos.getEncargoById(ventaId))!;
    expect(vendida.detalles.map((d) => d.costoUnitario), [1000, 2000]);
    expect(vendida.detalles.map((d) => d.cantidad), [2, 1]);
    expect(vendida.fechaVenta.year, DateTime.now().year);
    final fechaVenta = vendida.fechaVenta;
    await encargos.saveEncargo(vendida);
    expect((await encargos.getEncargoById(ventaId))!.fechaVenta, fechaVenta);
    expect(
        GetReporteGananciasUseCase()([], [], [vendida]).costoMercaderiaVendida,
        4000);
  });

  test(
      'Gastos repartidos y separados se descuentan una sola vez; cero deshace reparto',
      () async {
    await compras.registrar(viajeId,
        [entrada(cantidad: 3), entrada(nombre: 'Poleas', cantidad: 2)]);
    await viajes
        .addGasto(Gasto(viajeId: viajeId, tipo: 'Pasajes', monto: 1001));
    await viajes.addGasto(Gasto(viajeId: viajeId, tipo: 'Comida', monto: 999));
    await compras.distribuir(viajeId, 1001);
    expect(
        (await database.select(database.compras).get())
            .fold<int>(0, (s, c) => s + c.gastoAsignado),
        1001);
    await compras.distribuir(viajeId, 0);
    expect(
        (await database.select(database.compras).get())
            .every((c) => c.gastoAsignado == 0),
        isTrue);
    await compras.distribuir(viajeId, 1001);
    final productos = await database.select(database.productos).get();
    final ventas = <Encargo>[];
    for (final p in productos) {
      final id = await encargos.saveEncargo(venta(p.id, p.cantidadDisponible));
      ventas.add((await encargos.getEncargoById(id))!);
    }
    final viaje = (await viajes.getViajeById(viajeId))!;
    expect(viaje.gastos.length, 2);
    final reporte = GetReporteGananciasUseCase()([], [viaje], ventas);
    expect(reporte.gastosViaje, 1001);
    expect(reporte.gastosNoDistribuidos, 999);
    expect(reporte.costoMercaderiaVendida, 6001);
    expect(reporte.gananciaNeta, 5500); // 12500 - 5000 - 2000
    await expectLater(
        compras.distribuir(viajeId, 2000), throwsA(isA<ValidationFailure>()));
    await viajes
        .addGasto(Gasto(viajeId: viajeId, tipo: 'Peaje adicional', monto: 500));
    final actualizado = (await viajes.getViajeById(viajeId))!;
    expect(actualizado.gastoSinDistribuir, 1499);
    expect(GetReporteGananciasUseCase()([], [actualizado], ventas).gananciaNeta,
        5000);
  });

  test('Un fallo al asociar revierte toda la compra múltiple y el catálogo',
      () async {
    await expectLater(
        compras.registrar(viajeId, [
          entrada(),
          const EntradaCompra(
              nombre: 'Otro',
              cantidad: 1,
              costoUnitario: 1000,
              precioVenta: 2000,
              encargoId: 999,
              detalleId: 999,
              cantidadCliente: 1)
        ]),
        throwsA(isA<ValidationFailure>()));
    expect(await database.select(database.compras).get(), isEmpty);
    expect(await database.select(database.productos).get(), isEmpty);
  });

  test('Venta directa rechaza texto libre aunque el nombre parezca válido',
      () async {
    await expectLater(
        encargos.saveEncargo(Encargo(
            fecha: DateTime.now(),
            estado: 'ENTREGADO',
            tipoVenta: 'Venta directa',
            detalles: [
              const EncargoDetalle(
                  nombreTemporal: 'No existe',
                  cantidad: 1,
                  costoUnitario: 1000,
                  precioUnitario: 2000)
            ])),
        throwsA(isA<ValidationFailure>()));
    expect(await database.select(database.encargos).get(), isEmpty);
  });

  test(
      'El redondeo de logística no se duplica cuando se vende stock antes de entregar la reserva',
      () async {
    final id = await encargos.saveEncargo(Encargo(
        clienteId: clienteId,
        fecha: DateTime(2026),
        estado: 'PENDIENTE',
        detalles: [
          const EncargoDetalle(nombreTemporal: 'Bandas', cantidad: 1)
        ]));
    final pendiente = (await encargos.getEncargoById(id))!;
    await compras.registrar(viajeId, [
      EntradaCompra(
          nombre: 'Bandas',
          cantidad: 3,
          costoUnitario: 1000,
          precioVenta: 2500,
          encargoId: id,
          detalleId: pendiente.detalles.single.id,
          cantidadCliente: 1)
    ]);
    await viajes.addGasto(Gasto(viajeId: viajeId, tipo: 'Redondeo', monto: 1));
    await compras.distribuir(viajeId, 1);
    final producto = (await database.select(database.productos).get()).single;
    final directaId = await encargos.saveEncargo(venta(producto.id, 2));
    await encargos.saveEncargo(
        (await encargos.getEncargoById(id))!.copyWith(estado: 'ENTREGADO'));
    var directa = (await encargos.getEncargoById(directaId))!;
    final entregada = (await encargos.getEncargoById(id))!;
    final costoAnterior = directa.detalles.single.costoLogistica;
    await encargos
        .saveEncargo(directa.copyWith(observaciones: 'Solo una nota'));
    directa = (await encargos.getEncargoById(directaId))!;
    expect(directa.detalles.single.costoLogistica, costoAnterior);
    expect(
        GetReporteGananciasUseCase()([], [], [directa, entregada]).gastosViaje,
        1);
  });
}
