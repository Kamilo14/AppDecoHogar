import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Intentar biometría automáticamente al cargar si está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) => _intentarBiometria());
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _intentarBiometria() async {
    final disponible = await ref.read(esBiometriaDisponibleProvider.future);
    if (disponible) {
      final exito = await ref.read(authRepositoryProvider).autenticarBiometria();
      if (exito) {
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;
      }
    }
  }

  Future<void> _login() async {
    if (_passCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    final esValida = await ref.read(verifyPasswordUseCaseProvider).call(_passCtrl.text);

    if (esValida) {
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña incorrecta')),
        );
        _passCtrl.clear();
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _mostrarAyudaPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Olvidaste tu contraseña?'),
        content: const Text(
          'Por seguridad y al ser una app 100% local, no hay forma de recuperar la contraseña.\n\n'
          'La única opción es borrar los datos de la aplicación y volver a registrarte. '
          'Podrás recuperar tu información de negocio si tienes un respaldo (Backup JSON) guardado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioAsync = ref.watch(usuarioProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F1E8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person_outlined, size: 64, color: Color(0xFFC96A4E)),
                  const SizedBox(height: 24),
                  usuarioAsync.when(
                    data: (u) => Text(
                      '¡Hola de nuevo, ${u?.primerNombre ?? ""}!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF3B2E23),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa tu contraseña para acceder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8A7863)),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number, // Recomendado para PIN
                    decoration: const InputDecoration(
                      hintText: '••••',
                      counterText: '',
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _intentarBiometria,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, size: 18),
                        SizedBox(width: 8),
                        Text('Usar huella o rostro'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextButton(
                    onPressed: _mostrarAyudaPassword,
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Color(0xFF8A7863),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
