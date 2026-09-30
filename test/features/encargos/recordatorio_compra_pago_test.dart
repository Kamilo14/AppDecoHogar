import 'package:app_deco_hogar/core/database/database.dart' as db;
import 'package:app_deco_hogar/core/errors/failures.dart';
import 'package:app_deco_hogar/features/clientes/domain/entities/cliente_entity.dart';
import 'package:app_deco_hogar/features/encargos/data/datasources/encargo_local_datasource.dart';
import 'package:app_deco_hogar/features/encargos/data/repositories/encargo_repository_impl.dart';
import 'package:app_deco_hogar/features/encargos/domain/usecases/save_encargo_usecase.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/entities/pago_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/usecases/calcular_deuda_cliente_usecase.dart';
import 'package:app_deco_hogar/features/reportes/domain/usecases/get_reporte_deudas_usecase.dart';
import 'package:app_deco_hogar/features/reportes/domain/usecases/get_reporte_ganancias_usecase.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late db.AppDatabase database;
  late EncargoLocalDataSource source;
  late SaveEncargoUseCase save;
  late int clienteId;
  setUp(() async {
    database = db.AppDatabase.at(NativeDatabase.memory());
    source = EncargoLocalDataSource(database);
    save = SaveEncargoUseCase(EncargoRepositoryImpl(source));
    clienteId = await database.into(database.clientes).insert(
        db.ClientesCompanion.insert(
            nombre: 'Camilo', fechaRegistro: DateTime(2026)));
  });
  tearDown(() => database.close());

  Encargo pedido(List<EncargoDetalle> items) => Encargo(
      clienteId: clienteId,
      fecha: DateTime(2026),
      estado: 'PENDIENTE',
      detalles: items);

  Future<List<Pago>> pagos() async =>
      (await database.select(database.pagos).get())
          .map((p) => Pago(
              clienteId: p.clienteId,
              encargoId: p.encargoId,
              monto: p.monto,
              fecha: p.fecha,
              metodo: p.metodo,
              tipo: p.tipo))
          .toList();

  test('Pago total respeta abonos generales de la ficha del cliente', () async {
    final id = await save(pedido([
      const EncargoDetalle(
          nombreTemporal: 'Bandas',
          cantidad: 10,
          comprado: true,
          costoUnitario: 1000,
          precioUnitario: 2500)
    ]));
    await database.into(database.pagos).insert(db.PagosCompanion.insert(
        clienteId: clienteId,
        monto: 5000,
        fecha: DateTime(2026),
        metodo: 'Efectivo',
        tipo: 'ABONO'));
    final actual = (await source.getEncargoById(id))!;
    await save(actual.copyWith(estado: 'ENTREGADO'), liquidarSaldo: true);
    await save((await source.getEncargoById(id))!, liquidarSaldo: true);
    expect((await pagos()).map((p) => p.monto), [5000, 20000]);
    expect(
        CalcularDeudaClienteUseCase()(
            [(await source.getEncargoById(id))!], await pagos(), clienteId),
        0);
  });

  test('Migrar versión 8 conserva clientes, detalles, pagos y stock', () async {
    final sqlite = sqlite3.openInMemory();
    var migrated = db.AppDatabase.at(
        NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false));
    final local = EncargoLocalDataSource(migrated);
    final client = await migrated.into(migrated.clientes).insert(
        db.ClientesCompanion.insert(
            nombre: 'Migración', fechaRegistro: DateTime(2026)));
    final id = await local.saveEncargo(
        Encargo(
            clienteId: client,
            fecha: DateTime(2026),
            estado: 'COMPRADO',
            detalles: [
              const EncargoDetalle(
                  nombreTemporal: 'Bandas',
                  cantidad: 10,
                  costoUnitario: 1000,
                  precioUnitario: 2500)
            ]),
        montoPagoInicial: 5000);
    await migrated.close();
    sqlite.execute('ALTER TABLE encargo_detalle DROP COLUMN comprado');
    sqlite.execute('ALTER TABLE encargo_detalle DROP COLUMN cantidad_comprada');
    sqlite.execute('ALTER TABLE encargo_detalle DROP COLUMN compra_id');
    sqlite.execute('ALTER TABLE encargo_detalle DROP COLUMN costo_logistica');
    sqlite.execute('ALTER TABLE encargos DROP COLUMN fecha_entrega_real');
    sqlite.execute('ALTER TABLE viajes DROP COLUMN monto_distribuido');
    sqlite.execute('DROP TABLE compras');
    sqlite.execute('PRAGMA user_version = 8');
    migrated = db.AppDatabase.at(
        NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false));
    try {
      final order =
          (await EncargoLocalDataSource(migrated).getEncargoById(id))!;
      expect(order.detalles.single.comprado, isTrue);
      expect(order.detalles.single.unidadesCompradas, 10);
      expect((await migrated.select(migrated.clientes).get()).single.nombre,
          'Migración');
      expect(
          (await migrated.select(migrated.productos).get())
              .single
              .cantidadDisponible,
          10);
      expect((await migrated.select(migrated.pagos).get()).single.monto, 5000);
      expect(await migrated.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty);
    } finally {
      await migrated.close();
      sqlite.dispose();
    }
  });

  test('Comprar 15 y entregar 10 conserva 5, incluso al volver a guardar',
      () async {
    final id = await save(pedido([
      const EncargoDetalle(
          nombreTemporal: 'Bandas',
          cantidad: 15,
          comprado: true,
          costoUnitario: 1000,
          precioUnitario: 2500)
    ]));
    var actual = (await source.getEncargoById(id))!;
    await save(actual
        .copyWith(detalles: [actual.detalles.single.copyWith(cantidad: 10)]));
    actual = (await source.getEncargoById(id))!;
    expect(actual.detalles.single.unidadesCompradas, 15);
    expect(actual.total, 25000);
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        15);
    await save(actual.copyWith(estado: 'ENTREGADO'), liquidarSaldo: true);
    actual = (await source.getEncargoById(id))!;
    await save(actual);
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        5);
    expect((await pagos()).single.monto, 25000);
    final reporte = GetReporteGananciasUseCase()([], [], [actual]);
    expect(reporte.costoMercaderiaVendida, 10000);
    expect(reporte.gananciaNeta, 15000);
  });

  test('Sin sobrantes la compra y entrega mantienen una única cantidad',
      () async {
    final id = await save(pedido([
      const EncargoDetalle(
          nombreTemporal: 'Bandas',
          cantidad: 15,
          comprado: true,
          costoUnitario: 1000,
          precioUnitario: 2500)
    ]));
    final actual = (await source.getEncargoById(id))!;
    expect(actual.detalles.single.unidadesCompradas, 15);
    await save(actual.copyWith(estado: 'ENTREGADO'));
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        0);
  });

  test('No permite entregar más unidades que las compradas', () async {
    await expectLater(
        source.saveEncargo(pedido([
          const EncargoDetalle(
              nombreTemporal: 'Bandas',
              cantidad: 15,
              cantidadComprada: 10,
              comprado: true,
              costoUnitario: 1000,
              precioUnitario: 2500)
        ])),
        throwsA(isA<ValidationFailure>()));
    expect(await database.select(database.encargos).get(), isEmpty);
    expect(await database.select(database.productos).get(), isEmpty);
  });

  test('Compra parcial persiste por producto y no duplica stock al editar',
      () async {
    final id = await save(pedido([
      const EncargoDetalle(nombreTemporal: 'Bandas Elásticas', cantidad: 10),
      const EncargoDetalle(nombreTemporal: 'Poleas', cantidad: 3),
    ]));
    var actual = (await source.getEncargoById(id))!;
    expect(await database.select(database.productos).get(), isEmpty);
    await save(actual.copyWith(detalles: [
      actual.detalles[0]
          .copyWith(comprado: true, costoUnitario: 1000, precioUnitario: 2500),
      actual.detalles[1],
    ]));
    actual = (await source.getEncargoById(id))!;
    expect(actual.estado, 'PENDIENTE');
    expect(actual.detalles.map((d) => d.comprado), [true, false]);
    expect(actual.totalExigible, 25000);
    await save(actual);
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        10);
    final reporte = GetReporteGananciasUseCase()([], [], [actual]);
    expect(reporte.totalVendido, 0);
    expect(reporte.costoMercaderiaVendida, 0);
    await expectLater(source.saveEncargo(actual.copyWith(estado: 'ENTREGADO')),
        throwsA(isA<ValidationFailure>()));
    expect((await source.getEncargoById(id))!.estado, 'PENDIENTE');
  });

  test('Entrega registra abono, liquida solo saldo y coincide con reportes',
      () async {
    final id = await save(pedido([
      const EncargoDetalle(
          nombreTemporal: 'Bandas',
          cantidad: 10,
          comprado: true,
          costoUnitario: 1000,
          precioUnitario: 2500)
    ]));
    var actual = (await source.getEncargoById(id))!;
    expect(actual.estado, 'COMPRADO');
    await save(actual.copyWith(estado: 'ENTREGADO'), montoPagoInicial: 5000);
    actual = (await source.getEncargoById(id))!;
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        0);
    expect((await pagos()).single.tipo, 'ABONO');
    expect(CalcularDeudaClienteUseCase()([actual], await pagos(), clienteId),
        20000);
    final cliente =
        Cliente(id: clienteId, nombre: 'Camilo', fechaRegistro: DateTime(2026));
    expect(
        GetReporteDeudasUseCase()([cliente], [actual], await pagos())
            .single
            .deuda,
        20000);
    final reporte = GetReporteGananciasUseCase()([], [], [actual]);
    expect(reporte.totalVendido, 25000);
    expect(reporte.costoMercaderiaVendida, 10000);
    expect(reporte.gananciaNeta, 15000);
    await save(actual, liquidarSaldo: true);
    await save(actual, liquidarSaldo: true);
    expect((await pagos()).map((p) => p.monto), [5000, 20000]);
    expect(
        CalcularDeudaClienteUseCase()([actual], await pagos(), clienteId), 0);
    expect(
        GetReporteDeudasUseCase()([cliente], [actual], await pagos()), isEmpty);
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        0);
  });

  test('Abono inválido revierte entrega y descuento de stock', () async {
    final id = await save(pedido([
      const EncargoDetalle(
          nombreTemporal: 'Bandas',
          cantidad: 10,
          comprado: true,
          costoUnitario: 1000,
          precioUnitario: 2500)
    ]));
    final actual = (await source.getEncargoById(id))!;
    await expectLater(
        source.saveEncargo(actual.copyWith(estado: 'ENTREGADO'),
            montoPagoInicial: 26000),
        throwsA(isA<ValidationFailure>()));
    expect((await source.getEncargoById(id))!.estado, 'COMPRADO');
    expect(
        (await database.select(database.productos).get())
            .single
            .cantidadDisponible,
        10);
    expect(await pagos(), isEmpty);
  });

  test('Referencia obsoleta de producto se resuelve antes de insertar detalle',
      () async {
    final id = await save(pedido([
      const EncargoDetalle(
          productoId: 9999, nombreTemporal: 'Bandas', cantidad: 10)
    ]));
    var actual = (await source.getEncargoById(id))!;
    expect(actual.detalles.single.productoId, isNull);
    await save(actual.copyWith(estado: 'COMPRADO', detalles: [
      actual.detalles.single.copyWith(costoUnitario: 1000, precioUnitario: 2500)
    ]));
    actual = (await source.getEncargoById(id))!;
    expect(actual.detalles.single.productoId, isNotNull);
    expect(
        await database.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}
