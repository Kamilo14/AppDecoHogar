import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  AuthRepositoryImpl(this._db, this._secureStorage, this._localAuth);

  static const String _hashKey = 'auth_password_hash';
  static const String _saltKey = 'auth_password_salt';

  @override
  Future<void> registrarUsuario(Usuario usuario, String password) async {
    // 1. Generar Salt aleatorio
    final salt = _generateSalt();
    
    // 2. Generar Hash SHA-256
    final hash = _generateHash(password, salt);

    // 3. Guardar credenciales de forma segura
    await _secureStorage.write(key: _hashKey, value: hash);
    await _secureStorage.write(key: _saltKey, value: salt);

    // 4. Guardar perfil en base de datos (reemplazando cualquier anterior)
    await _db.delete(_db.perfilUsuario).go();
    await _db.into(_db.perfilUsuario).insert(
      PerfilUsuarioCompanion.insert(
        nombre: usuario.nombre,
        fechaNacimiento: usuario.fechaNacimiento,
      ),
    );
  }

  @override
  Future<bool> verificarPassword(String password) async {
    final storedHash = await _secureStorage.read(key: _hashKey);
    final storedSalt = await _secureStorage.read(key: _saltKey);

    if (storedHash == null || storedSalt == null) return false;

    final inputHash = _generateHash(password, storedSalt);
    return inputHash == storedHash;
  }

  @override
  Future<Usuario?> getPerfil() async {
    final row = await _db.select(_db.perfilUsuario).getSingleOrNull();
    if (row == null) return null;
    return Usuario(
      nombre: row.nombre,
      fechaNacimiento: row.fechaNacimiento,
    );
  }

  @override
  Future<bool> existePerfil() async {
    final countExp = _db.perfilUsuario.id.count();
    final query = _db.selectOnly(_db.perfilUsuario)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return (result ?? 0) > 0;
  }

  @override
  Future<bool> autenticarBiometria() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Accede a tu aplicación',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> esBiometriaDisponible() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }

  // --- Helpers Privados ---

  String _generateSalt([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  String _generateHash(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }
}
