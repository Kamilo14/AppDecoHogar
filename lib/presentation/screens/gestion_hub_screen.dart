import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/catalogo/presentation/screens/catalogo_screen.dart';
import '../../features/gastos/presentation/screens/viajes_list_screen.dart';
import '../../features/pagos/presentation/screens/pagos_list_screen.dart';
import '../../features/productos/presentation/screens/productos_list_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/encargos/presentation/widgets/encargo_form_screen.dart';

class GestionHubScreen extends ConsumerWidget {
  const GestionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            // Encabezado Premium
            Text(
              'Configuración',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestión avanzada, finanzas y sistema.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            
            const _SectionLabel(title: 'Ventas y Negocio'),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Venta Directa', 
              subtitle: 'Registro rápido sin encargo',
              icon: Icons.bolt_rounded, 
              iconColor: AppColors.primary,
              onTap: () => _open(context, const EncargoFormScreen(esVentaDirecta: true)),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Catálogo', 
              subtitle: 'Generar PDF para clientes',
              icon: Icons.storefront_rounded, 
              iconColor: AppColors.tertiary,
              onTap: () => _open(context, const CatalogoScreen()),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Productos', 
              subtitle: 'Gestión de inventario y stock',
              icon: Icons.inventory_2_rounded, 
              iconColor: AppColors.primary,
              onTap: () => _open(context, const ProductosListScreen()),
            ),
            
            const SizedBox(height: 32),
            const _SectionLabel(title: 'Finanzas y Operaciones'),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Pagos Recibidos', 
              subtitle: 'Historial de abonos y saldos',
              icon: Icons.account_balance_wallet_rounded, 
              iconColor: AppColors.secondary,
              onTap: () => _open(context, const PagosListScreen()),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Viajes y Logística', 
              subtitle: 'Gastos y compras en Santiago',
              icon: Icons.local_shipping_rounded, 
              iconColor: AppColors.tertiary,
              onTap: () => _open(context, const ViajesListScreen()),
            ),
            
            const SizedBox(height: 32),
            const _SectionLabel(title: 'Sistema'),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Copia de Seguridad', 
              subtitle: 'Exportar e importar datos (JSON)',
              icon: Icons.cloud_upload_rounded, 
              iconColor: AppColors.secondary,
              onTap: () => _open(context, const BackupScreen()),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Cerrar sesión', 
              subtitle: 'Salir de la cuenta actual',
              icon: Icons.logout_rounded, 
              iconColor: AppColors.primary,
              onTap: () {
                ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title, 
      style: GoogleFonts.outfit(
        fontSize: 18, 
        fontWeight: FontWeight.w800, 
        color: AppColors.secondary
      )
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _ModuleTile({
    required this.title, 
    required this.subtitle,
    required this.icon, 
    required this.onTap, 
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icono en contenedor circular con fondo suave
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded, 
                  color: AppColors.textSecondary.withValues(alpha: 0.3), 
                  size: 20
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
