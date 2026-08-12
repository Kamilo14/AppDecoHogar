import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/entities/pago_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/usecases/calcular_deuda_cliente_usecase.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalcularDeudaClienteUseCase useCase;

  setUp(() {
    useCase = CalcularDeudaClienteUseCase();
  });

  group('Pruebas de Cálculo de Deuda (Regla 8.1 y 8.5)', () {
    const clienteId = 1;

    test('Debe calcular la deuda correctamente con abonos parciales', () {
      // Caso: Compra de $10.000 y abona $7.000
      final encargos = [
        Encargo(
          id: 1,
          clienteId: clienteId,
          fecha: DateTime.now(),
          estado: 'PENDIENTE',
          detalles: [
            const EncargoDetalle(productoId: 1, cantidad: 1, precioUnitario: 10000),
          ],
        ),
      ];

      final pagos = [
        Pago(id: 1, clienteId: clienteId, monto: 7000, fecha: DateTime.now(), metodo: 'Efectivo', tipo: 'ABONO'),
      ];

      final resultado = useCase.call(encargos, pagos, clienteId);

      expect(resultado, 3000); // 10.000 - 7.000 = 3.000
    });

    test('Debe reflejar saldo a favor si los pagos superan la deuda', () {
      // Caso: Debe $5.000 pero paga $6.000
      final encargos = [
        Encargo(
          id: 2,
          clienteId: clienteId,
          fecha: DateTime.now(),
          estado: 'ENTREGADO',
          detalles: [
            const EncargoDetalle(productoId: 1, cantidad: 1, precioUnitario: 5000),
          ],
        ),
      ];

      final pagos = [
        Pago(id: 2, clienteId: clienteId, monto: 6000, fecha: DateTime.now(), metodo: 'Transferencia', tipo: 'ABONO'),
      ];

      final resultado = useCase.call(encargos, pagos, clienteId);

      expect(resultado, -1000); // 5.000 - 6.000 = -1.000 (A favor)
    });

    test('No debe sumar encargos eliminados (soft-delete)', () {
      final encargos = [
        Encargo(
          id: 3,
          clienteId: clienteId,
          fecha: DateTime.now(),
          estado: 'PENDIENTE',
          activo: false, // ELIMINADO
          detalles: [
            const EncargoDetalle(productoId: 1, cantidad: 1, precioUnitario: 5000),
          ],
        ),
      ];

      final pagos = <Pago>[];

      final resultado = useCase.call(encargos, pagos, clienteId);

      expect(resultado, 0); // Al estar inactivo, la deuda es 0
    });
  });
}
