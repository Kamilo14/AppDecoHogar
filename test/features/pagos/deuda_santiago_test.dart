import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/entities/pago_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/usecases/calcular_deuda_cliente_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalcularDeudaClienteUseCase useCase;

  setUp(() {
    useCase = CalcularDeudaClienteUseCase();
  });

  group('Pruebas de Deuda - Flujo Santiago (Regla 8.3)', () {
    const clienteId = 1;

    test('Debe ignorar encargos en estado PENDIENTE aunque tengan productos', () {
      final encargos = [
        Encargo(
          id: 1,
          clienteId: clienteId,
          fecha: DateTime.now(),
          estado: 'PENDIENTE', // No debe sumar
          detalles: [
            const EncargoDetalle(productoId: 1, cantidad: 5, precioUnitario: null),
          ],
        ),
      ];

      final pagos = <Pago>[];

      final resultado = useCase.call(encargos, pagos, clienteId);

      expect(resultado, 0);
    });

    test('Debe sumar solo encargos en estado COMPRADO o superior', () {
      final encargos = [
        Encargo(
          id: 1,
          clienteId: clienteId,
          fecha: DateTime.now(),
          estado: 'PENDIENTE',
          detalles: [const EncargoDetalle(productoId: 1, cantidad: 1, precioUnitario: null)],
        ),
        Encargo(
          id: 2,
          clienteId: clienteId,
          fecha: DateTime.now(),
          estado: 'COMPRADO', // Debe sumar
          detalles: [const EncargoDetalle(productoId: 2, cantidad: 1, precioUnitario: 5000)],
        ),
      ];

      final resultado = useCase.call(encargos, [], clienteId);

      expect(resultado, 5000);
    });
  });
}
