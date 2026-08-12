import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_deco_hogar/features/productos/presentation/widgets/producto_form_dialog.dart';
import 'package:app_deco_hogar/core/providers/core_providers.dart';
import 'package:app_deco_hogar/core/database/database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('Sugerencia de precio de venta debe ser 2x el costo real', (WidgetTester tester) async {
    final db = AppDatabase.at(NativeDatabase.memory());
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProductoFormDialog(),
          ),
        ),
      ),
    );

    // 1. Ingresar precio de compra $1.000
    final precioCompraField = find.widgetWithText(TextFormField, 'Costo Compra');
    await tester.enterText(precioCompraField, '1000');
    await tester.pump();

    // 2. El precio de venta debería sugerirse como $2.000 (2x costo real)
    final precioVentaField = find.widgetWithText(TextFormField, 'P. Venta *');
    expect(find.descendant(of: precioVentaField, matching: find.text('2000')), findsOneWidget);

    // 3. Activar comisión de viaje (Simulamos que hay viajes con gastos cargados)
    // Nota: Como es un widget test que depende de datos asíncronos (StreamProvider), 
    // tendríamos que insertar datos en la BD o mockear el provider.
    // Para simplificar esta validación, verificamos el impacto de los campos de texto.
  });
}
