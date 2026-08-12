import 'package:drift/drift.dart';

@DataClassName('ClienteRow')
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get direccion => text().nullable()();
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get fechaRegistro => dateTime()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}
