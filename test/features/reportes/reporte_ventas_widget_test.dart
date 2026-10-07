import 'package:app_deco_hogar/features/clientes/domain/entities/cliente_entity.dart';
import 'package:app_deco_hogar/features/clientes/presentation/providers/cliente_providers.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/encargos/presentation/providers/encargo_providers.dart';
import 'package:app_deco_hogar/features/gastos/presentation/providers/viaje_providers.dart';
import 'package:app_deco_hogar/features/productos/presentation/providers/producto_providers.dart';
import 'package:app_deco_hogar/features/reportes/presentation/screens/reporte_ventas_detalle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Filtra por entrega y muestra productos del cliente',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final hoy = DateTime.now();
    final ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);
    await tester.pumpWidget(ProviderScope(overrides: [
      productosStreamProvider.overrideWith((ref) => Stream.value([])),
      comprasStreamProvider.overrideWith((ref) => Stream.value([])),
      viajesStreamProvider.overrideWith((ref) => Stream.value([])),
      clientesStreamProvider.overrideWith((ref) => Stream.value([
            Cliente(id: 1, nombre: 'Camilo', fechaRegistro: ayer),
            Cliente(id: 2, nombre: 'Andrea', fechaRegistro: ayer),
          ])),
      encargosStreamProvider.overrideWith((ref) => Stream.value([
            Encargo(
                id: 1,
                clienteId: 1,
                fecha: ayer,
                fechaEntregaReal: hoy,
                estado: 'ENTREGADO',
                tipoVenta: 'Venta directa',
                detalles: const [
                  EncargoDetalle(
                      nombreTemporal: 'Bandas',
                      cantidad: 10,
                      precioUnitario: 2500,
                      costoUnitario: 1000,
                      costoLogistica: 0),
                ]),
            Encargo(
                id: 2,
                clienteId: 2,
                fecha: ayer,
                fechaEntregaReal: ayer,
                estado: 'ENTREGADO',
                tipoVenta: 'Venta directa',
                detalles: const [
                  EncargoDetalle(
                      nombreTemporal: 'Poleas',
                      cantidad: 1,
                      precioUnitario: 2000,
                      costoUnitario: 500,
                      costoLogistica: 0),
                ]),
          ])),
    ], child: const MaterialApp(home: Scaffold(body: ReporteVentasDetalle()))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.textContaining('Camilo'), findsOneWidget);
    expect(find.textContaining('Andrea'), findsOneWidget);
    await tester.tap(find.text('Día'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.textContaining('Camilo'), findsOneWidget);
    expect(find.textContaining('Andrea'), findsNothing);
    await tester.tap(find.textContaining('Camilo'));
    await tester.pumpAndSettle();
    expect(find.text('Bandas · 10 unidades'), findsOneWidget);
    expect(find.textContaining('Costo:'), findsOneWidget);
    expect(find.text('Ver venta y pagos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
