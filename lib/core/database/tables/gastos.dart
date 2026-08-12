import 'package:drift/drift.dart';
import 'viajes.dart';

class Gastos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get viajeId => integer().references(Viajes, #id)();
  TextColumn get tipo => text()();
  IntColumn get monto => integer()();
}
