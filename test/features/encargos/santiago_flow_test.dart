import 'package:app_deco_hogar/core/database/database.dart';
import 'package:app_deco_hogar/features/encargos/data/datasources/encargo_local_datasource.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart' as domain;
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
    test('Al guardar un encargo con un producto nuevo, debe crearse en BD con stock reservado', () async {
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
            cantidad: cantidadPedida
          ),
        ],
      );

      // 2. Ejecutar el guardado (Santiago Flow activado en DataSource)
      await dataSource.saveEncargo(encargo);

      // 3. Verificar que el producto se creó automáticamente
      final todosLosProductos = await db.select(db.productos).get();
      final productoCreado = todosLosProductos.firstWhere((p) => p.nombre == nombreNuevo);

      expect(productoCreado, isNotNull);
      // REGLA: cantidadDisponible = cantidad pedida (Reserva inmediata)
      expect(productoCreado.cantidadDisponible, cantidadPedida);
      // REGLA: Precios iniciales en null
      expect(productoCreado.precioCompra, isNull);
      expect(productoCreado.precioVenta, isNull);
    });

    test('Al pasar de PENDIENTE a ENTREGADO un producto auto-creado, el stock debe quedar en 0', () async {
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
            cantidad: cantidad
          ),
        ],
      );

      // Guardamos (se crea el producto con stock 3)
      await dataSource.saveEncargo(encargo);
      
      // Obtenemos el encargo guardado para tener el ID
      final lista = await dataSource.watchEncargos().first;
      final encargoId = lista.first.id!;

      // Cambiamos a ENTREGADO
      await dataSource.changeEstadoEncargo(encargoId, 'ENTREGADO');

      // Verificamos stock final
      final producto = await (db.select(db.productos)..where((p) => p.nombre.equals(nombreNuevo))).getSingle();
      expect(producto.cantidadDisponible, 0); 
    });
  });
}
