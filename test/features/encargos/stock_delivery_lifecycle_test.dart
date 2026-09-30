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

  group('Pruebas de Regresión - Stock y Entrega', () {
    test('ERR-12: El stock NO debe descontarse en estado PENDIENTE', () async {
      final productoId = await db.into(db.productos).insert(
            ProductosCompanion.insert(
              nombre: 'Manzanas',
              precioCompra: const Value(100),
              precioVenta: const Value(200),
              cantidadDisponible: const Value(10),
            ),
          );

      final encargo = domain.Encargo(
        clienteId: null,
        fecha: DateTime.now(),
        estado: 'PENDIENTE',
        detalles: [
          EncargoDetalle(
              productoId: productoId, cantidad: 3, precioUnitario: 200),
        ],
      );

      await dataSource.saveEncargo(encargo);

      final p = await (db.select(db.productos)
            ..where((t) => t.id.equals(productoId)))
          .getSingle();
      expect(p.cantidadDisponible, 10); // Sigue siendo 10
    });

    test('ERR-13: Debe fallar si se intenta entregar sin stock suficiente',
        () async {
      final productoId = await db.into(db.productos).insert(
            ProductosCompanion.insert(
              nombre: 'Manzanas',
              precioCompra: const Value(100),
              precioVenta: const Value(200),
              cantidadDisponible: const Value(2),
            ),
          );

      final encargoId = await db.into(db.encargos).insert(
            EncargosCompanion.insert(
              fecha: DateTime.now(),
              estado: 'PENDIENTE',
            ),
          );
      await db.into(db.encargoDetalle).insert(
            EncargoDetalleCompanion.insert(
              encargoId: encargoId,
              productoId: Value(productoId),
              cantidad: 5,
              precioUnitario: const Value(200),
            ),
          );

      expect(
        () => dataSource.changeEstadoEncargo(encargoId, 'ENTREGADO'),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
