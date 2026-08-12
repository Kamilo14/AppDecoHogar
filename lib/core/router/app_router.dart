import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../presentation/screens/main_scaffold_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Si el estado es desconocido, esperamos el check inicial
      if (authState == AuthState.unknown) return null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      // 1. Si no hay perfil, forzar registro
      if (authState == AuthState.needsRegistration) {
        return isRegistering ? null : '/register';
      }

      // 2. Si no está autenticado, forzar login
      if (authState == AuthState.unauthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // 3. Si está autenticado y trata de ir a login/register, mandarlo al inicio
      if (authState == AuthState.authenticated && (isLoggingIn || isRegistering)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScaffoldScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
