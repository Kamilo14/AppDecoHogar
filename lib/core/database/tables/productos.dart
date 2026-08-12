import 'package:drift/drift.dart';
import 'categorias.dart';
import 'viajes.dart';

class Productos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoriaId => integer().nullable().references(Categorias, #id)();
  IntColumn get viajeId => integer().nullable().references(Viajes, #id)();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  
  // Regla 8.3: Nulables para permitir creación sin precio inicial (Santiago)
  IntColumn get precioCompra => integer().nullable()();
  IntColumn get comisionViaje => integer().withDefault(const Constant(0))();
  IntColumn get precioVenta => integer().nullable()();
  
  IntColumn get cantidadDisponible => integer().withDefault(const Constant(0))();
  TextColumn get fotoPath => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}
