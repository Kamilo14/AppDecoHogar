import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_deco_hogar/main.dart';
import 'package:app_deco_hogar/core/providers/core_providers.dart';
import 'package:app_deco_hogar/core/database/database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('App smoke test - Verifica que la app inicie sin errores', (WidgetTester tester) async {
    // Creamos una base de datos en memoria para el test
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase.at(NativeDatabase.memory())),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AppDecoHogar(),
      ),
    );

    // Verificamos que al menos cargue el MaterialApp o el Scaffold inicial
    expect(find.byType(AppDecoHogar), findsOneWidget);
    
    // Esperamos a que terminen las animaciones iniciales
    await tester.pumpAndSettle();
  });
}
