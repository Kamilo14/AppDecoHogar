import 'package:app_deco_hogar/core/errors/failures.dart';
import 'package:app_deco_hogar/features/auth/domain/entities/usuario_entity.dart';
import 'package:app_deco_hogar/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_deco_hogar/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUserUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUserUseCase(mockRepository);
  });

  group('Validaciones de Registro de Usuario', () {
    final tUsuario = Usuario(
      nombre: 'Martina',
      fechaNacimiento: DateTime(1990, 1, 1),
    );

    test('Debe fallar si las contraseñas no coinciden', () async {
      expect(
        () => useCase.call(tUsuario, '1234', '1235'),
        throwsA(isA<ValidationFailure>().having((e) => e.message, 'message', 'Las contraseñas no coinciden.')),
      );
    });

    test('Debe fallar si la contraseña tiene menos de 4 caracteres', () async {
      expect(
        () => useCase.call(tUsuario, '123', '123'),
        throwsA(isA<ValidationFailure>().having((e) => e.message, 'message', 'La contraseña debe tener al menos 4 caracteres.')),
      );
    });

    test('Debe llamar al repositorio si las validaciones pasan', () async {
      when(() => mockRepository.registrarUsuario(any(), any()))
          .thenAnswer((_) async => {});
      
      registerFallbackValue(tUsuario);

      await useCase.call(tUsuario, '1234', '1234');

      verify(() => mockRepository.registrarUsuario(any(), '1234')).called(1);
    });
  });
}
