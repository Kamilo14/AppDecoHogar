import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:drift/native.dart';

import 'tables/clientes.dart';
import 'tables/categorias.dart';
import 'tables/viajes.dart';
import 'tables/gastos.dart';
import 'tables/productos.dart';
import 'tables/encargos.dart';
import 'tables/encargo_detalle.dart';
import 'tables/pagos.dart';
import 'tables/perfil_usuario.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Clientes,
  Categorias,
  Viajes,
  Gastos,
  Productos,
  Encargos,
  EncargoDetalle,
  Pagos,
  PerfilUsuario,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor para pruebas (in-memory)
  AppDatabase.at(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 8; // Incrementado a 8 para incluir nombre_temporal en encargo_detalle

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Regla: Migración destructiva en desarrollo para limpiar esquema y aplicar cambios
        if (from < 8) {
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_deco_hogar.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
