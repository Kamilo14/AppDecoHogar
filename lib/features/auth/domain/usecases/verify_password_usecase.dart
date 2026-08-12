import '../repositories/auth_repository.dart';

class VerifyPasswordUseCase {
  final AuthRepository _repository;

  VerifyPasswordUseCase(this._repository);

  Future<bool> call(String password) async {
    return await _repository.verificarPassword(password);
  }
}
