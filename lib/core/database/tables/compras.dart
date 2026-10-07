import 'package:drift/drift.dart';
import 'viajes.dart';
import 'productos.dart';

class Compras extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get viajeId => integer().references(Viajes, #id)();
  IntColumn get productoId => integer().references(Productos, #id)();
  TextColumn get nombreProducto => text()();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get cantidad => integer()();
  IntColumn get costoUnitario => integer()();
  IntColumn get precioVenta => integer()();
  IntColumn get gastoAsignado => integer().withDefault(const Constant(0))();
  // La compra se registra primero y solo impacta el stock tras confirmación.
  BoolColumn get inventarioActualizado =>
      boolean().withDefault(const Constant(false))();
}
