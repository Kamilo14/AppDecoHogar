import '../../../../core/errors/failures.dart';
import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<void> call(Usuario usuario, String password, String confirmPassword) async {
    if (usuario.nombre.trim().isEmpty) {
      throw ValidationFailure('El nombre no puede estar vacío.');
    }

    if (password.length < 4) {
      throw ValidationFailure('La contraseña debe tener al menos 4 caracteres.');
    }

    if (password != confirmPassword) {
      throw ValidationFailure('Las contraseñas no coinciden.');
    }

    await _repository.registrarUsuario(usuario, password);
  }
}
