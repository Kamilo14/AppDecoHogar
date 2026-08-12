import '../../../../core/errors/failures.dart';
import '../../domain/entities/categoria_entity.dart';
import '../../domain/entities/producto_entity.dart';
import '../../domain/repositories/producto_repository.dart';
import '../datasources/categoria_local_datasource.dart';
import '../datasources/producto_local_datasource.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoLocalDataSource _productoDataSource;
  final CategoriaLocalDataSource _categoriaDataSource;

  ProductoRepositoryImpl(
    this._productoDataSource,
    this._categoriaDataSource,
  );

  @override
  Stream<List<Producto>> watchProductos() {
    return _productoDataSource.watchProductos();
  }

  @override
  Future<void> saveProducto(Producto producto) async {
    try {
      await _productoDataSource.saveProducto(producto);
    } catch (e) {
      throw DatabaseFailure('Error al guardar el producto: $e');
    }
  }

  @override
  Future<void> deleteProducto(int id) async {
    try {
      await _productoDataSource.deleteProducto(id);
    } catch (e) {
      throw DatabaseFailure('Error al eliminar el producto: $e');
    }
  }

  @override
  Future<Producto?> getProductoById(int id) async {
    try {
      return await _productoDataSource.getProductoById(id);
    } catch (e) {
      throw DatabaseFailure('Error al obtener el producto: $e');
    }
  }

  @override
  Stream<List<Categoria>> watchCategorias() {
    return _categoriaDataSource.watchCategorias();
  }

  @override
  Future<void> saveCategoria(Categoria categoria) async {
    try {
      await _categoriaDataSource.saveCategoria(categoria);
    } catch (e) {
      throw DatabaseFailure('Error al guardar la categoría: $e');
    }
  }

  @override
  Future<Categoria?> getCategoriaById(int id) async {
    try {
      return await _categoriaDataSource.getCategoriaById(id);
    } catch (e) {
      throw DatabaseFailure('Error al obtener la categoría: $e');
    }
  }
}