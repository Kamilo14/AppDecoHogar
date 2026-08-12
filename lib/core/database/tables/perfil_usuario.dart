import 'package:drift/drift.dart';

class PerfilUsuario extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  DateTimeColumn get fechaNacimiento => dateTime()();
}
