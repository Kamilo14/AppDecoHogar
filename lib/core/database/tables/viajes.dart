import 'package:drift/drift.dart';

class Viajes extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get destino => text()();
  TextColumn get observaciones => text().nullable()();
  BoolColumn get distribuido => boolean().withDefault(const Constant(false))();
  IntColumn get montoDistribuido => integer().withDefault(const Constant(0))();
}
