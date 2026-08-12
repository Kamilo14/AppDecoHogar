import '../entities/categoria_entity.dart';
import '../entities/producto_entity.dart';

/// Contrato abstracto del repositorio de productos y categorías.
abstract class ProductoRepository {
  Stream<List<Producto>> watchProductos();

  Future<void> saveProducto(Producto producto);

  Future<void> deleteProducto(int id);

  Future<Producto?> getProductoById(int id);

  Stream<List<Categoria>> watchCategorias();

  Future<void> saveCategoria(Categoria categoria);

  Future<Categoria?> getCategoriaById(int id);
}