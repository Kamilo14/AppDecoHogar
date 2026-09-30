import 'package:app_deco_hogar/core/database/database.dart';
import 'package:app_deco_hogar/core/errors/failures.dart';
import 'package:app_deco_hogar/features/encargos/data/datasources/encargo_local_datasource.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart'
    as domain;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late EncargoLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.at(NativeDatabase.memory());
    dataSource = EncargoLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('EncargoLocalDataSource - Validación de Stock al Entregar', () {
    test(
        'Debe lanzar ValidationFailure si no hay stock suficiente al marcar como ENTREGADO',
        () async {
      // 1. Insertar producto con stock 2
      final productoId = await db.into(db.productos).insert(
            ProductosCompanion.insert(
              nombre: 'Test Producto',
              precioCompra: const Value(1000),
              precioVenta: const Value(2000),
              cantidadDisponible: const Value(2),
            ),
          );

      // 2. Crear encargo pendiente de 3 unidades
      final encargo = domain.Encargo(
        clienteId: null,
        fecha: DateTime.now(),
        estado: 'PENDIENTE',
        tipoVenta: 'Venta directa',
        detalles: [
          EncargoDetalle(
              productoId: productoId,
              cantidad: 3,
              precioUnitario: 2000,
              costoUnitario: 1000),
        ],
      );

      await dataSource.saveEncargo(encargo);

      // 3. Intentar cambiar a ENTREGADO
      final encargoId = (await db.select(db.encargos).get()).first.id;

      expect(
        () => dataSource.changeEstadoEncargo(encargoId, 'ENTREGADO'),
        throwsA(isA<ValidationFailure>().having(
            (e) => e.message, 'message', contains('Stock insuficiente'))),
      );
    });

    test('Debe descontar stock correctamente cuando el estado pasa a ENTREGADO',
        () async {
      final productoId = await db.into(db.productos).insert(
            ProductosCompanion.insert(
              nombre: 'Test Producto',
              precioCompra: const Value(1000),
              precioVenta: const Value(2000),
              cantidadDisponible: const Value(10),
            ),
          );

      final encargo = domain.Encargo(
        clienteId: null,
        fecha: DateTime.now(),
        estado: 'PENDIENTE',
        tipoVenta: 'Venta directa',
        detalles: [
          EncargoDetalle(
              productoId: productoId,
              cantidad: 3,
              precioUnitario: 2000,
              costoUnitario: 1000),
        ],
      );

      await dataSource.saveEncargo(encargo);

      // El stock debe seguir siendo 10
      var p = await (db.select(db.productos)
            ..where((t) => t.id.equals(productoId)))
          .getSingle();
      expect(p.cantidadDisponible, 10);

      final encargoId = (await db.select(db.encargos).get()).first.id;
      await dataSource.changeEstadoEncargo(encargoId, 'ENTREGADO');

      // Ahora el stock debe ser 7
      p = await (db.select(db.productos)..where((t) => t.id.equals(productoId)))
          .getSingle();
      expect(p.cantidadDisponible, 7);
    });
  });
}
