import '../entities/categoria_entity.dart';
import '../repositories/producto_repository.dart';

class GetCategoriasUseCase {
  final ProductoRepository _repository;

  GetCategoriasUseCase(this._repository);

  Stream<List<Categoria>> call() => _repository.watchCategorias();
}