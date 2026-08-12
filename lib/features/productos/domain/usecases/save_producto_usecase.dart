import '../../../../core/errors/failures.dart';
import '../entities/producto_entity.dart';
import '../repositories/producto_repository.dart';

class SaveProductoUseCase {
  final ProductoRepository _repository;

  SaveProductoUseCase(this._repository);

  Future<void> call(Producto producto) async {
    if (producto.nombre.trim().isEmpty) {
      throw ValidationFailure('El nombre del producto no puede estar vacío.');
    }
    // Permitir nulos pero validar si hay valor
    if (producto.precioCompra != null && producto.precioCompra! < 0) {
      throw ValidationFailure('El precio de compra no puede ser negativo.');
    }
    if (producto.precioVenta != null && producto.precioVenta! < 0) {
      throw ValidationFailure('El precio de venta no puede ser negativo.');
    }
    if (producto.cantidadDisponible < 0) {
      throw ValidationFailure('La cantidad disponible no puede ser negativa.');
    }

    await _repository.saveProducto(producto);
  }
}
