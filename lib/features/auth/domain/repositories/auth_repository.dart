import '../entities/usuario_entity.dart';

abstract class AuthRepository {
  /// Registra un nuevo usuario: guarda perfil en DB y credenciales en Secure Storage
  Future<void> registrarUsuario(Usuario usuario, String password);

  /// Verifica si la contraseña ingresada coincide con la guardada
  Future<bool> verificarPassword(String password);

  /// Obtiene el perfil del usuario si existe
  Future<Usuario?> getPerfil();

  /// Verifica si existe un perfil registrado
  Future<bool> existePerfil();

  /// Intenta autenticar mediante biometría (huella/rostro)
  Future<bool> autenticarBiometria();
  
  /// Verifica si el dispositivo soporta biometría
  Future<bool> esBiometriaDisponible();
}
