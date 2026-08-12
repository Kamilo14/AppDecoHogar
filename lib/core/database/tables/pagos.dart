import 'package:drift/drift.dart';
import 'clientes.dart';
import 'encargos.dart';

class Pagos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  IntColumn get encargoId => integer().nullable().references(Encargos, #id)();
  IntColumn get monto => integer()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get metodo => text()(); // Transferencia, Efectivo, etc.
  TextColumn get tipo => text()(); // ABONO, PAGO_TOTAL, AJUSTE
  TextColumn get concepto => text().nullable()();
}
