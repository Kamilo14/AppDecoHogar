import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_detalle_entity.dart';
import 'package:app_deco_hogar/features/encargos/domain/entities/encargo_entity.dart';
import 'package:app_deco_hogar/features/encargos/presentation/providers/encargo_providers.dart';
import 'package:app_deco_hogar/features/productos/domain/entities/producto_entity.dart';
import 'package:app_deco_hogar/features/productos/presentation/providers/producto_providers.dart';
import 'package:app_deco_hogar/features/productos/presentation/widgets/seleccionar_productos_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Lista productos libres, busca y devuelve selección sin aceptar texto libre',
      (tester) async {
    List<Producto>? seleccion;
    await tester.pumpWidget(ProviderScope(
        overrides: [
          productosStreamProvider.overrideWith((ref) => Stream.value([
                const Producto(
                    id: 1,
                    nombre: 'Bandas',
                    cantidadDisponible: 15,
                    precioVenta: 2500),
                const Producto(
                    id: 2,
                    nombre: 'Poleas',
                    cantidadDisponible: 3,
                    precioVenta: 4000),
                const Producto(
                    id: 3,
                    nombre: 'Reservado',
                    cantidadDisponible: 10,
                    precioVenta: 1000),
                const Producto(
                    id: 4,
                    nombre: 'Sin stock',
                    cantidadDisponible: 0,
                    precioVenta: 1000),
              ])),
          encargosStreamProvider.overrideWith((ref) => Stream.value([
                Encargo(fecha: DateTime(2026), estado: 'COMPRADO', detalles: [
                  const EncargoDetalle(
                      productoId: 1, cantidad: 10, comprado: true),
                  const EncargoDetalle(
                      productoId: 3, cantidad: 10, comprado: true),
                ]),
              ])),
        ],
        child: MaterialApp(
            home: Scaffold(
                body: Builder(
                    builder: (context) => TextButton(
                        onPressed: () async {
                          seleccion = await showDialog<List<Producto>>(
                              context: context,
                              builder: (_) =>
                                  const SeleccionarProductosDialog());
                        },
                        child: const Text('Abrir')))))));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Bandas'), findsOneWidget);
    expect(find.text('Poleas'), findsOneWidget);
    expect(find.text('Reservado'), findsNothing);
    expect(find.text('Sin stock'), findsNothing);
    expect(find.textContaining('5 disponibles'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'band');
    await tester.pumpAndSettle();
    expect(find.text('Poleas'), findsNothing);
    await tester.tap(find.text('Bandas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar (1)'));
    await tester.pumpAndSettle();
    expect(seleccion!.single.id, 1);
    expect(tester.takeException(), isNull);
  });
}
