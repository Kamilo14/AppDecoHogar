import 'package:app_deco_hogar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_deco_hogar/features/auth/domain/entities/usuario_entity.dart';
import 'package:app_deco_hogar/core/database/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}
class MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  late AppDatabase db;
  late MockSecureStorage mockSecureStorage;
  late MockLocalAuth mockLocalAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.at(NativeDatabase.memory());
    mockSecureStorage = MockSecureStorage();
    mockLocalAuth = MockLocalAuth();
    repository = AuthRepositoryImpl(db, mockSecureStorage, mockLocalAuth);
  });

  tearDown(() async {
    await db.close();
  });

  group('Lógica de Autenticación Local', () {
    final tUsuario = Usuario(
      nombre: 'Martina Pérez',
      fechaNacimiento: DateTime(1990, 1, 1),
    );
    const tPassword = 'password123';

    test('Debe generar hash y salt diferentes para la misma contraseña', () async {
      // Mocking storage writes
      when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});
      
      // Simulamos dos registros con la misma clave
      // Nota: registrarUsuario genera un salt aleatorio interno
      await repository.registrarUsuario(tUsuario, tPassword);
      final capturedSalt1 = verify(() => mockSecureStorage.write(key: 'auth_password_salt', value: captureAny())).captured.last;
      
      await repository.registrarUsuario(tUsuario, tPassword);
      final capturedSalt2 = verify(() => mockSecureStorage.write(key: 'auth_password_salt', value: captureAny())).captured.last;

      expect(capturedSalt1, isNot(capturedSalt2));
    });

    test('Debe verificar correctamente la contraseña guardada', () async {
      String? storedHash;
      String? storedSalt;

      // Interceptamos la escritura
      when(() => mockSecureStorage.write(key: 'auth_password_hash', value: any(named: 'value')))
          .thenAnswer((invocation) async {
            storedHash = invocation.namedArguments[#value];
          });
      when(() => mockSecureStorage.write(key: 'auth_password_salt', value: any(named: 'value')))
          .thenAnswer((invocation) async {
            storedSalt = invocation.namedArguments[#value];
          });

      // Interceptamos la lectura
      when(() => mockSecureStorage.read(key: 'auth_password_hash')).thenAnswer((_) async => storedHash);
      when(() => mockSecureStorage.read(key: 'auth_password_salt')).thenAnswer((_) async => storedSalt);

      await repository.registrarUsuario(tUsuario, tPassword);
      
      final esValida = await repository.verificarPassword(tPassword);
      final esInvalida = await repository.verificarPassword('wrong_pass');

      expect(esValida, true);
      expect(esInvalida, false);
    });

    test('Debe extraer el primer nombre correctamente para el saludo', () {
      expect(tUsuario.primerNombre, 'Martina');
      
      const u2 = Usuario(nombre: 'Juan Jose', fechaNacimiento: kDefaultDate);
      expect(u2.primerNombre, 'Juan');
    });
  });
}

final kDefaultDate = DateTime(2000);
