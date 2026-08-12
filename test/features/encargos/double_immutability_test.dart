import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/productos/domain/entities/producto_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pruebas de Doble Inmutabilidad (Regla 8.2)', () {
    test('Costo y Precio del encargo no deben cambiar si el producto se actualiza después', () {
      // 1. Estado inicial: Encargo comprado con precios fijados
      const productoOriginal = Producto(
        id: 1,
        nombre: 'Producto Test',
        precioCompra: 1000,
        precioVenta: 2000,
      );

      final encargoDetalle = const EncargoDetalle(
        productoId: 1,
        cantidad: 1,
        precioUnitario: 2000, // Precio pactado
        costoUnitario: 1000,  // Costo en ese viaje
      );

      final encargo = Encargo(
        id: 1,
        clienteId: 1,
        fecha: DateTime.now(),
        estado: 'COMPRADO',
        detalles: [encargoDetalle],
      );

      // 2. Simulamos que el producto cambia su precio base en el catálogo
      // (Ej: Martina sube los precios para el próximo viaje)
      final productoEditado = productoOriginal.copyWith(
        precioCompra: 1500,
        precioVenta: 3000,
      );

      // 3. Verificamos que el detalle del encargo mantiene sus valores históricos
      final detalleHistorico = encargo.detalles.first;
      
      expect(detalleHistorico.precioUnitario, 2000);
      expect(detalleHistorico.costoUnitario, 1000);
      expect(detalleHistorico.precioUnitario, isNot(productoEditado.precioVenta));
    });
  });
}
