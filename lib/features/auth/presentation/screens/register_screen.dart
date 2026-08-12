import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/usuario_entity.dart';
import '../providers/auth_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  DateTime _fechaNacimiento = DateTime(2000, 1, 1);
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final usuario = Usuario(
        nombre: _nombreCtrl.text.trim(),
        fechaNacimiento: _fechaNacimiento,
      );

      await ref.read(registerUserUseCaseProvider).call(
        usuario,
        _passCtrl.text,
        _confirmPassCtrl.text,
      );

      ref.invalidate(usuarioProfileProvider);
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '¡Bienvenida!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Configura tu perfil para empezar a organizar tu negocio de forma profesional.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Form Fields
                  TextFormField(
                    controller: _nombreCtrl,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Ej: Martina García',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    validator: (v) => v!.isEmpty ? 'Por favor, ingresa tu nombre' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaNacimiento,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => _fechaNacimiento = picked);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        prefixIcon: const Icon(Icons.cake_outlined),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      child: Text(
                        DateFormat('dd MMMM, yyyy').format(_fechaNacimiento),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Pin de acceso',
                      hintText: 'Mínimo 4 caracteres',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    validator: (v) => v!.length < 4 ? 'Mínimo 4 caracteres' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Pin',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    validator: (v) => v != _passCtrl.text ? 'Las contraseñas no coinciden' : null,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  FilledButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Comenzar ahora'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Toda tu información se guarda de forma segura únicamente en tu dispositivo.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
