import '../../../../core/errors/failures.dart';
import '../entities/categoria_entity.dart';
import '../repositories/producto_repository.dart';

class SaveCategoriaUseCase {
  final ProductoRepository _repository;

  SaveCategoriaUseCase(this._repository);

  Future<void> call(Categoria categoria) async {
    if (categoria.nombre.trim().isEmpty) {
      throw ValidationFailure('El nombre de la categoría no puede estar vacío.');
    }

    await _repository.saveCategoria(categoria);
  }
}