import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AppDecoHogar(),
    ),
  );
}

class AppDecoHogar extends ConsumerStatefulWidget {
  const AppDecoHogar({super.key});

  @override
  ConsumerState<AppDecoHogar> createState() => _AppDecoHogarState();
}

class _AppDecoHogarState extends ConsumerState<AppDecoHogar> {
  @override
  void initState() {
    super.initState();
    // Inicializar el estado de autenticación al arrancar la app
    _initAuth();
  }

  Future<void> _initAuth() async {
    final hasProfile = await ref.read(checkAuthStatusUseCaseProvider).call();
    if (hasProfile) {
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
    } else {
      ref.read(authStateProvider.notifier).state = AuthState.needsRegistration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'App Deco Hogar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
