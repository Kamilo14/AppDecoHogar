import 'package:app_deco_hogar/core/database/database.dart';
import 'package:app_deco_hogar/features/gastos/data/datasources/viaje_local_datasource.dart';
import 'package:app_deco_hogar/features/productos/data/datasources/producto_local_datasource.dart';
import 'package:app_deco_hogar/features/productos/domain/entities/producto_entity.dart' as domain;
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ViajeLocalDataSource viajeDataSource;
  late ProductoLocalDataSource productoDataSource;

  setUp(() {
    db = AppDatabase.at(NativeDatabase.memory());
    viajeDataSource = ViajeLocalDataSource(db);
    productoDataSource = ProductoLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Pruebas de Carga Rápida en Viaje (Regla 8.5)', () {
    test('Debe vincular el producto al viaje y sumar stock correctamente', () async {
      // 1. Crear un viaje
      final viajeId = await db.into(db.viajes).insert(
        ViajesCompanion.insert(
          fecha: DateTime.now(),
          destino: 'Santiago',
        ),
      );

      // 2. Crear un producto base sin stock ni viaje
      final productoId = await db.into(db.productos).insert(
        ProductosCompanion.insert(
          nombre: 'Cortina Nueva',
          precioCompra: const Value(null),
          precioVenta: const Value(null),
          cantidadDisponible: const Value(0),
        ),
      );

      // 3. Simular "Carga Rápida" desde el viaje
      // Martina compra 5 unidades a $3.000 c/u
      final productoActualizado = domain.Producto(
        id: productoId,
        nombre: 'Cortina Nueva',
        precioCompra: 3000,
        precioVenta: 6000,
        cantidadDisponible: 5, // 0 + 5
        viajeId: viajeId,
      );

      // Usamos el datasource de productos para guardar (como hace el diálogo)
      await productoDataSource.saveProducto(productoActualizado);

      // 4. Verificaciones
      final pResult = await (db.select(db.productos)..where((t) => t.id.equals(productoId))).getSingle();
      
      expect(pResult.viajeId, viajeId);
      expect(pResult.cantidadDisponible, 5);
      expect(pResult.precioCompra, 3000);
    });
  });
}
