import 'package:drift/drift.dart';
import 'clientes.dart';

class Encargos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().nullable().references(Clientes, #id)();

  /// Regla 8.6: Numeración local al cliente (ENC-1, ENC-2...)
  IntColumn get correlativoCliente =>
      integer().withDefault(const Constant(1))();

  DateTimeColumn get fecha => dateTime()();
  DateTimeColumn get fechaEntregaReal => dateTime().nullable()();
  DateTimeColumn get fechaEntregaEstimada => dateTime().nullable()();
  TextColumn get estado =>
      text()(); // PENDIENTE, COMPRADO, ENTREGADO, FINALIZADO
  TextColumn get observaciones => text().nullable()();
  TextColumn get tipoVenta =>
      text().withDefault(const Constant('Por encargo'))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}
