import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/entities/pago_entity.dart';
import 'package:app_deco_hogar/features/pagos/domain/usecases/calcular_pago_encargo_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalcularPagoEncargoUseCase useCase;

  setUp(() {
    useCase = CalcularPagoEncargoUseCase();
  });

  group('Pruebas de Asignación FIFO de Pagos por Venta', () {
    const clienteId = 1;

    test(
        'Caso de Usuario: Venta 1 con Abono 500, luego Venta 2 con Pago 1500 -> Ambas quedan PAGADAS',
        () {
      // Venta 1 realizada el 10-11-2026
      final venta1 = Encargo(
        id: 10,
        clienteId: clienteId,
        fecha: DateTime(2026, 11, 10),
        estado: 'ENTREGADO',
        tipoVenta: 'Venta directa',
        detalles: const [
          EncargoDetalle(
              productoId: 1, cantidad: 10, precioUnitario: 100, comprado: true),
        ], // Total = 1000
      );

      // Venta 2 realizada el 20-11-2026
      final venta2 = Encargo(
        id: 20,
        clienteId: clienteId,
        fecha: DateTime(2026, 11, 20),
        estado: 'ENTREGADO',
        tipoVenta: 'Venta directa',
        detalles: const [
          EncargoDetalle(
              productoId: 2, cantidad: 10, precioUnitario: 100, comprado: true),
        ], // Total = 1000
      );

      final todosEncargos = [venta1, venta2];

      // Pago 1: $500 el 10-11-2026
      final pago1 = Pago(
        id: 101,
        clienteId: clienteId,
        encargoId: 10,
        monto: 500,
        fecha: DateTime(2026, 11, 10),
        metodo: 'Efectivo',
        tipo: 'ABONO',
      );

      // Pago 2: $1500 el 20-11-2026
      final pago2 = Pago(
        id: 102,
        clienteId: clienteId,
        encargoId: 20,
        monto: 1500,
        fecha: DateTime(2026, 11, 20),
        metodo: 'Efectivo',
        tipo: 'ABONO',
      );

      final todosPagos = [pago1, pago2];

      // Calcular resumen para Venta 1
      final resumen1 = useCase.call(
        encargo: venta1,
        todosEncargos: todosEncargos,
        todosPagos: todosPagos,
      );

      // Calcular resumen para Venta 2
      final resumen2 = useCase.call(
        encargo: venta2,
        todosEncargos: todosEncargos,
        todosPagos: todosPagos,
      );

      // Venta 1 debe recibir $1,000 en total ($500 inicial + $500 del abono posterior)
      expect(resumen1.montoAbonado, 1000);
      expect(resumen1.saldoPendiente, 0);
      expect(resumen1.estaSaldado, isTrue);
      expect(resumen1.estadoPago, 'PAGADO');

      // Venta 2 debe recibir los $1,000 restantes del pago de $1,500
      expect(resumen2.montoAbonado, 1000);
      expect(resumen2.saldoPendiente, 0);
      expect(resumen2.estaSaldado, isTrue);
      expect(resumen2.estadoPago, 'PAGADO');
    });

    test('Pago parcial asigna fondos en orden cronológico FIFO', () {
      final venta1 = Encargo(
        id: 1,
        clienteId: clienteId,
        fecha: DateTime(2026, 10, 1),
        estado: 'ENTREGADO',
        tipoVenta: 'Venta directa',
        detalles: const [
          EncargoDetalle(
              productoId: 1, cantidad: 1, precioUnitario: 5000, comprado: true),
        ],
      );

      final venta2 = Encargo(
        id: 2,
        clienteId: clienteId,
        fecha: DateTime(2026, 10, 5),
        estado: 'ENTREGADO',
        tipoVenta: 'Venta directa',
        detalles: const [
          EncargoDetalle(
              productoId: 2, cantidad: 1, precioUnitario: 5000, comprado: true),
        ],
      );

      final todosEncargos = [venta1, venta2];

      // El cliente abonó un total de $7,000 (cubre la Venta 1 entera y $2,000 de Venta 2)
      final pagos = [
        Pago(
          id: 1,
          clienteId: clienteId,
          monto: 7000,
          fecha: DateTime(2026, 10, 10),
          metodo: 'Transferencia',
          tipo: 'ABONO',
        ),
      ];

      final res1 = useCase.call(
          encargo: venta1, todosEncargos: todosEncargos, todosPagos: pagos);
      final res2 = useCase.call(
          encargo: venta2, todosEncargos: todosEncargos, todosPagos: pagos);

      // Venta 1: Pagada por completo
      expect(res1.montoAbonado, 5000);
      expect(res1.saldoPendiente, 0);
      expect(res1.estadoPago, 'PAGADO');

      // Venta 2: Parcialmente abonada ($2,000 abonados, $3,000 pendientes)
      expect(res2.montoAbonado, 2000);
      expect(res2.saldoPendiente, 3000);
      expect(res2.estadoPago, 'PARCIAL');
    });

    test('Venta sin cliente registrado evalúa solo sus pagos directos', () {
      final ventaSinCliente = Encargo(
        id: 99,
        clienteId: null,
        fecha: DateTime.now(),
        estado: 'ENTREGADO',
        tipoVenta: 'Venta directa',
        detalles: const [
          EncargoDetalle(
              productoId: 1, cantidad: 1, precioUnitario: 3000, comprado: true),
        ],
      );

      final pagos = [
        Pago(
          id: 1,
          clienteId: 1,
          encargoId: 99,
          monto: 3000,
          fecha: DateTime.now(),
          metodo: 'Efectivo',
          tipo: 'PAGO_TOTAL',
        ),
      ];

      final res = useCase.call(
        encargo: ventaSinCliente,
        todosEncargos: [ventaSinCliente],
        todosPagos: pagos,
      );

      expect(res.montoAbonado, 3000);
      expect(res.saldoPendiente, 0);
      expect(res.estadoPago, 'PAGADO');
    });
  });
}
