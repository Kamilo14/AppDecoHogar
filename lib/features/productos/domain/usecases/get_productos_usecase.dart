import '../entities/producto_entity.dart';
import '../repositories/producto_repository.dart';

class GetProductosUseCase {
  final ProductoRepository _repository;

  GetProductosUseCase(this._repository);

  Stream<List<Producto>> call() => _repository.watchProductos();
}