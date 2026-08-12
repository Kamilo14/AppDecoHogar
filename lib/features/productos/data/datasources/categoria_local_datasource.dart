import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/categoria_entity.dart' as domain;

class CategoriaLocalDataSource {
  final AppDatabase _db;

  CategoriaLocalDataSource(this._db);

  Stream<List<domain.Categoria>> watchCategorias() {
    return (_db.select(_db.categorias)
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .watch()
        .map((List<Categoria> rows) => rows.map(_toEntity).toList());
  }

  Future<void> saveCategoria(domain.Categoria categoria) async {
    if (categoria.id == null) {
      await _db.into(_db.categorias).insert(
            CategoriasCompanion.insert(nombre: categoria.nombre),
          );
    } else {
      await (_db.update(_db.categorias)
            ..where((c) => c.id.equals(categoria.id!)))
          .write(
        CategoriasCompanion(
          nombre: Value(categoria.nombre),
        ),
      );
    }
  }

  Future<domain.Categoria?> getCategoriaById(int id) async {
    final row = await (_db.select(_db.categorias)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  domain.Categoria _toEntity(Categoria row) {
    return domain.Categoria(
      id: row.id,
      nombre: row.nombre,
    );
  }
}