import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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
        backgroundColor: AppColors.surface,
        title: Text('¿Olvidaste tu contraseña?', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text(
          'Por seguridad y al ser una app 100% local, no hay forma de recuperar la contraseña.\n\n'
          'La única opción es borrar los datos de la aplicación y volver a registrarte. '
          'Podrás recuperar tu información de negocio si tienes un respaldo (Backup JSON) guardado.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioAsync = ref.watch(usuarioProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 64, color: AppColors.primary),
                ),
                const SizedBox(height: 32),
                usuarioAsync.when(
                  data: (u) => Text(
                    '¡Hola de nuevo, ${u?.primerNombre ?? ""}!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa tu contraseña para acceder.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.3)),
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Entrar', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _intentarBiometria,
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fingerprint_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Usar huella o rostro', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                TextButton(
                  onPressed: _mostrarAyudaPassword,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
