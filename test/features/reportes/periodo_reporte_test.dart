import 'package:app_deco_hogar/features/reportes/domain/usecases/periodo_reporte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mes incluye el día 31 y excluye el mes siguiente', () {
    final periodo = PeriodoReporte('Mes', DateTime(2026, 10, 10));
    expect(periodo.contiene(DateTime(2026, 10, 31, 23, 59)), isTrue);
    expect(periodo.contiene(DateTime(2026, 11, 1)), isFalse);
    expect(periodo.contiene(DateTime(2025, 10, 31)), isFalse);
  });
  test('Día incluye medianoche y excluye las 00:00 del día siguiente', () {
    final periodo = PeriodoReporte('Día', DateTime(2026, 9, 30));
    expect(periodo.contiene(DateTime(2026, 9, 30)), isTrue);
    expect(periodo.contiene(DateTime(2026, 10, 1)), isFalse);
  });
}
