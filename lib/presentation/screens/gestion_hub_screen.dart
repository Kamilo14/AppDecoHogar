import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/catalogo/presentation/screens/catalogo_screen.dart';
import '../../features/gastos/presentation/screens/viajes_list_screen.dart';
import '../../features/pagos/presentation/screens/pagos_list_screen.dart';
import '../../features/productos/presentation/screens/productos_list_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/encargos/presentation/widgets/encargo_form_screen.dart';

// Paleta de Colores Obligatoria
abstract class HubTheme {
  static const Color background = Color(0xFFF6F2EB); // Crema
  static const Color surface = Color(0xFFFFFFFF);    // Blanco
  static const Color olive = Color(0xFF6F7F58);      // Verde Oliva
  static const Color terracota = Color(0xFFC95A32); // Terracota
  static const Color beige = Color(0xFFC9A77D);      // Beige Tostado
  
  static const Color textPrimary = Color(0xFF2E2A26);
  static const Color textSecondary = Color(0xFF8C847B);
  static const Color border = Color(0xFFE8E0D6);
  static const Color iconBg = Color(0xFFF3EAE0);
}

class GestionHubScreen extends ConsumerWidget {
  const GestionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HubTheme.background,
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
                color: HubTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestión avanzada, finanzas y sistema.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: HubTheme.textSecondary,
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
              iconColor: HubTheme.terracota,
              onTap: () => _open(context, const EncargoFormScreen(esVentaDirecta: true)),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Catálogo', 
              subtitle: 'Generar PDF para clientes',
              icon: Icons.storefront_rounded, 
              iconColor: HubTheme.beige,
              onTap: () => _open(context, const CatalogoScreen()),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Productos', 
              subtitle: 'Gestión de inventario y stock',
              icon: Icons.inventory_2_rounded, 
              iconColor: HubTheme.terracota,
              onTap: () => _open(context, const ProductosListScreen()),
            ),
            
            const SizedBox(height: 32),
            const _SectionLabel(title: 'Finanzas y Operaciones'),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Pagos Recibidos', 
              subtitle: 'Historial de abonos y saldos',
              icon: Icons.account_balance_wallet_rounded, 
              iconColor: HubTheme.olive,
              onTap: () => _open(context, const PagosListScreen()),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Viajes y Logística', 
              subtitle: 'Gastos y compras en Santiago',
              icon: Icons.local_shipping_rounded, 
              iconColor: HubTheme.beige,
              onTap: () => _open(context, const ViajesListScreen()),
            ),
            
            const SizedBox(height: 32),
            const _SectionLabel(title: 'Sistema'),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Copia de Seguridad', 
              subtitle: 'Exportar e importar datos (JSON)',
              icon: Icons.cloud_upload_rounded, 
              iconColor: HubTheme.olive,
              onTap: () => _open(context, const BackupScreen()),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              title: 'Cerrar sesión', 
              subtitle: 'Salir de la cuenta actual',
              icon: Icons.logout_rounded, 
              iconColor: HubTheme.terracota,
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
        color: HubTheme.olive
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
        color: HubTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HubTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
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
                  decoration: const BoxDecoration(
                    color: HubTheme.iconBg,
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
                          color: HubTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: HubTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded, 
                  color: HubTheme.textSecondary.withOpacity(0.3), 
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
