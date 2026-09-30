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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _intentarBiometria();
    });
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _intentarBiometria() async {
    final disponible = await ref.read(esBiometriaDisponibleProvider.future);
    if (!disponible) return;
    final exito = await ref.read(authRepositoryProvider).autenticarBiometria();
    if (exito && mounted) {
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    }
  }

  Future<void> _login() async {
    if (_passCtrl.text.isEmpty || _isLoading) return;
    setState(() => _isLoading = true);
    final esValida = await ref.read(verifyPasswordUseCaseProvider).call(_passCtrl.text);
    if (esValida) {
      if (mounted) ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contraseña incorrecta', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF8B4513),
          ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '¿Olvidaste tu contraseña?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF26301F)),
        ),
        content: Text(
          'Por seguridad y al ser una app 100% local, no hay forma de recuperar la contraseña.\n\nLa única opción es borrar los datos de la aplicación y volver a registrarte.',
          style: GoogleFonts.outfit(color: const Color(0xFF3F4338), height: 1.4),
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

  Widget _buildPasswordField() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF3F4C30).withOpacity(0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _passCtrl,
        obscureText: true,
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF293020),
          letterSpacing: 4,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 23, color: Color(0xFF3F4C30)),
          hintText: 'Contraseña',
          hintStyle: GoogleFonts.outfit(
            color: const Color(0xFF4A4D42),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        ),
        onSubmitted: (_) => _login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioAsync = ref.watch(usuarioProfileProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'documentación/diseño/LoginDecoHogar.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.background),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF26301F).withOpacity(0.05),
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.44),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              usuarioAsync.when(
                                data: (u) => Text(
                                  (u?.primerNombre ?? '').isEmpty ? '¡Hola de nuevo!' : '¡Hola de nuevo, ${u!.primerNombre}!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF26301F),
                                    letterSpacing: -0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.55),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                loading: () => const SizedBox(height: 30),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ingresa tu contraseña para acceder.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3F4338),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildPasswordField(),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _mostrarAyudaPassword,
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF9A5528),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    elevation: 2,
                                  ),
                                  child: _isLoading 
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                    : Text('Iniciar sesión', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: const Color(0xFF3F4C30).withOpacity(0.2))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'o continúa con',
                                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4A4D42)),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: const Color(0xFF3F4C30).withOpacity(0.2))),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: _intentarBiometria,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF354229),
                                    backgroundColor: Colors.white.withOpacity(0.4),
                                    side: BorderSide(color: const Color(0xFF3F4C30).withOpacity(0.6), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.fingerprint_rounded, size: 28, color: Color(0xFF3F4C30)),
                                      const SizedBox(width: 10),
                                      Text('Usar huella digital', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF3F4338), fontWeight: FontWeight.w500),
                                  children: [
                                    const TextSpan(text: '¿Aún no tienes cuenta? '),
                                    TextSpan(text: 'Créala aquí', style: GoogleFonts.outfit(color: const Color(0xFF9A5528), fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
