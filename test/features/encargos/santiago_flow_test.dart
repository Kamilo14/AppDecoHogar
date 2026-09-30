import 'package:app_deco_hogar/core/database/database.dart';
import 'package:app_deco_hogar/features/encargos/data/datasources/encargo_local_datasource.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart'
    as domain;
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

  group('Santiago Flow - Creación Automática de Productos', () {
    test('Un recordatorio conserva nombre y cantidad sin crear stock',
        () async {
      // 1. Preparar encargo con un producto inexistente (solo nombre temporal)
      const nombreNuevo = "Mesa Vintage Santiago";
      const cantidadPedida = 5;

      final encargo = domain.Encargo(
        clienteId: null,
        fecha: DateTime.now(),
        estado: 'PENDIENTE',
        detalles: [
          const EncargoDetalle(
              productoId: null,
              nombreTemporal: nombreNuevo,
              cantidad: cantidadPedida),
        ],
      );

      // 2. Ejecutar el guardado (Santiago Flow activado en DataSource)
      await dataSource.saveEncargo(encargo);

      expect(await db.select(db.productos).get(), isEmpty);
      final guardado = (await dataSource.watchEncargos().first).single;
      expect(guardado.detalles.single.nombreTemporal, nombreNuevo);
      expect(guardado.detalles.single.cantidad, cantidadPedida);
      expect(guardado.detalles.single.precioUnitario, isNull);
    });

    test('Comprar ingresa stock y entregar lo descuenta', () async {
      // Este test valida que si el cliente pide 5, se crean 5, y al entregar se restan 5 -> queda 0.
      const nombreNuevo = "Espejo Sol";
      const cantidad = 3;

      final encargo = domain.Encargo(
        clienteId: null,
        fecha: DateTime.now(),
        estado: 'PENDIENTE',
        detalles: [
          const EncargoDetalle(
              productoId: null,
              nombreTemporal: nombreNuevo,
              cantidad: cantidad),
        ],
      );

      // Guardamos (se crea el producto con stock 3)
      await dataSource.saveEncargo(encargo);

      // Obtenemos el encargo guardado para tener el ID
      final lista = await dataSource.watchEncargos().first;
      final encargoId = lista.first.id!;

      await dataSource.saveEncargo(lista.first.copyWith(
        estado: 'COMPRADO',
        detalles: [
          lista.first.detalles.single
              .copyWith(costoUnitario: 1000, precioUnitario: 2500)
        ],
      ));
      expect((await db.select(db.productos).get()).single.cantidadDisponible,
          cantidad);
      // Cambiamos a ENTREGADO
      await dataSource.changeEstadoEncargo(encargoId, 'ENTREGADO');

      // Verificamos stock final
      final producto = await (db.select(db.productos)
            ..where((p) => p.nombre.equals(nombreNuevo)))
          .getSingle();
      expect(producto.cantidadDisponible, 0);
    });
  });
}
