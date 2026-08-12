import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/verify_password_usecase.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final localAuth = ref.watch(localAuthProvider);
  return AuthRepositoryImpl(db, secureStorage, localAuth);
});

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  return RegisterUserUseCase(ref.watch(authRepositoryProvider));
});

final verifyPasswordUseCaseProvider = Provider<VerifyPasswordUseCase>((ref) {
  return VerifyPasswordUseCase(ref.watch(authRepositoryProvider));
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(ref.watch(authRepositoryProvider));
});

final usuarioProfileProvider = FutureProvider<Usuario?>((ref) {
  return ref.watch(authRepositoryProvider).getPerfil();
});

final esBiometriaDisponibleProvider = FutureProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).esBiometriaDisponible();
});

/// Estado de la sesión actual (No autenticado, Autenticado, Nuevo)
enum AuthState { unknown, authenticated, unauthenticated, needsRegistration }

final authStateProvider = StateProvider<AuthState>((ref) => AuthState.unknown);
