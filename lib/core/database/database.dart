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
import 'tables/compras.dart';

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
  Compras,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor para pruebas (in-memory)
  AppDatabase.at(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 12;

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
        } else {
          if (from < 9) {
            await m.addColumn(encargoDetalle, encargoDetalle.comprado);
            await customStatement(
                "UPDATE encargo_detalle SET comprado = 1 WHERE encargo_id IN (SELECT id FROM encargos WHERE estado IN ('COMPRADO', 'ENTREGADO', 'FINALIZADO'))");
          }
          if (from < 10) {
            await m.addColumn(encargoDetalle, encargoDetalle.cantidadComprada);
          }
          if (from < 11) {
            await m.createTable(compras);
            await m.addColumn(encargoDetalle, encargoDetalle.compraId);
            await m.addColumn(encargoDetalle, encargoDetalle.costoLogistica);
            await m.addColumn(encargos, encargos.fechaEntregaReal);
            await m.addColumn(viajes, viajes.montoDistribuido);
            // La fecha exacta de entrega no estaba guardada en versiones anteriores.
            await customStatement(
                "UPDATE encargos SET fecha_entrega_real = fecha WHERE estado IN ('ENTREGADO', 'FINALIZADO')");
            await customStatement(
                'UPDATE encargo_detalle SET costo_logistica = cantidad * COALESCE((SELECT comision_viaje FROM productos WHERE productos.id = encargo_detalle.producto_id), 0)');
            await customStatement(
                'UPDATE viajes SET monto_distribuido = COALESCE((SELECT SUM(monto) FROM gastos WHERE gastos.viaje_id = viajes.id), 0) WHERE distribuido = 1');
          }
          // Desde v10, createTable(compras) ya crea la columna actual.
          if (from >= 11 && from < 12) {
            await m.addColumn(compras, compras.inventarioActualizado);
            // Las compras previas ya habían modificado existencias al crearse.
            await customStatement(
                'UPDATE compras SET inventario_actualizado = 1');
          }
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
