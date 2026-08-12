import '../repositories/producto_repository.dart';

class SoftDeleteProductoUseCase {
  final ProductoRepository _repository;

  SoftDeleteProductoUseCase(this._repository);

  Future<void> call(int productoId) async {
    await _repository.deleteProducto(productoId);
  }
}