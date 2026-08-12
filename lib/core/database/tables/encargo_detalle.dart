import 'package:drift/drift.dart';
import 'encargos.dart';
import 'productos.dart';

class EncargoDetalle extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get encargoId => integer().references(Encargos, #id)();
  IntColumn get productoId => integer().nullable().references(Productos, #id)();
  TextColumn get nombreTemporal => text().nullable()(); // Para recordatorios sin producto real
  IntColumn get cantidad => integer()();
  
  // Regla 8.3: Nullable mientras sea "Pendiente"
  IntColumn get precioUnitario => integer().nullable()();
  
  // Regla 8.2: Costo inmutable fijado al comprar
  IntColumn get costoUnitario => integer().nullable()();
}
