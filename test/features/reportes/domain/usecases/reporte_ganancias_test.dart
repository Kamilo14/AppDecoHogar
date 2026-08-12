import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/productos/domain/entities/producto_entity.dart';
import 'package:app_deco_hogar/features/reportes/domain/usecases/get_reporte_ganancias_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GetReporteGananciasUseCase useCase;

  setUp(() {
    useCase = GetReporteGananciasUseCase();
  });

  group('Pruebas de Reporte de Ganancias (Regla 8.2 y 8.3)', () {
    test('Debe calcular la ganancia neta usando el precio inmutable del encargo', () {
      // 1. Definimos un producto con un costo real de $5.000
      final productos = [
        const Producto(
          id: 1,
          nombre: 'Cortina',
          precioCompra: 4000,
          comisionViaje: 1000, // Costo real = 5.000
          precioVenta: 10000,
          cantidadDisponible: 5,
        ),
      ];

      // 2. Creamos un encargo que ya se vendió por $10.000
      final encargos = [
        Encargo(
          id: 1,
          clienteId: 1,
          fecha: DateTime.now(),
          estado: 'ENTREGADO', // Se considera venta
          detalles: [
            const EncargoDetalle(
              productoId: 1,
              cantidad: 1,
              precioUnitario: 10000, // Precio pactado en la venta
            ),
          ],
        ),
      ];

      final resultado = useCase.call(productos, [], encargos);

      // Verificación:
      // Venta: $10.000
      // Costo (Compra 4k + Viaje 1k): $5.000
      // Ganancia Neta: $5.000
      expect(resultado.totalVendido, 10000);
      expect(resultado.gananciaNeta, 5000);
    });

    test('No debe incluir encargos PENDIENTES en la ganancia neta', () {
      final productos = [
        const Producto(id: 1, nombre: 'A', precioCompra: 1000, precioVenta: 2000),
      ];

      final encargos = [
        Encargo(
          id: 1,
          clienteId: 1,
          fecha: DateTime.now(),
          estado: 'PENDIENTE', // No es venta todavía
          detalles: [const EncargoDetalle(productoId: 1, cantidad: 1, precioUnitario: 2000)],
        ),
      ];

      final resultado = useCase.call(productos, [], encargos);

      expect(resultado.totalVendido, 0);
      expect(resultado.gananciaNeta, 0);
    });
  });
}
