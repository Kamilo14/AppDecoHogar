import 'package:drift/drift.dart';

import '../../../../core/database/database.dart' as db;
import '../../domain/entities/producto_entity.dart' as domain;

class ProductoLocalDataSource {
  final db.AppDatabase _db;

  ProductoLocalDataSource(this._db);

  Stream<List<domain.Producto>> watchProductos() {
    return (_db.select(_db.productos)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .watch()
        .map((List<db.Producto> rows) => rows.map(_toEntity).toList());
  }

  Future<void> saveProducto(domain.Producto producto) async {
    final companion = db.ProductosCompanion(
      id: producto.id == null ? const Value.absent() : Value(producto.id!),
      categoriaId: Value(producto.categoriaId),
      viajeId: Value(producto.viajeId),
      nombre: Value(producto.nombre),
      descripcion: Value(producto.descripcion),
      precioCompra: Value(producto.precioCompra),
      comisionViaje: Value(producto.comisionViaje),
      precioVenta: Value(producto.precioVenta),
      cantidadDisponible: Value(producto.cantidadDisponible),
      fotoPath: Value(producto.fotoPath),
      activo: Value(producto.activo),
    );

    if (producto.id == null) {
      await _db.into(_db.productos).insert(companion);
    } else {
      await (_db.update(_db.productos)..where((p) => p.id.equals(producto.id!))).write(companion);
    }
  }

  Future<void> deleteProducto(int id) async {
    await (_db.update(_db.productos)..where((p) => p.id.equals(id)))
        .write(const db.ProductosCompanion(activo: Value(false)));
  }

  Future<domain.Producto?> getProductoById(int id) async {
    final row = await (_db.select(_db.productos)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  domain.Producto _toEntity(db.Producto row) {
    return domain.Producto(
      id: row.id,
      categoriaId: row.categoriaId,
      viajeId: row.viajeId,
      nombre: row.nombre,
      descripcion: row.descripcion,
      precioCompra: row.precioCompra,
      comisionViaje: row.comisionViaje,
      precioVenta: row.precioVenta,
      cantidadDisponible: row.cantidadDisponible,
      fotoPath: row.fotoPath,
      activo: row.activo,
    );
  }
}
