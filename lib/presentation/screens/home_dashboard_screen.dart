import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/currency_formatter.dart';
import '../../features/clientes/presentation/providers/cliente_providers.dart';
import '../../features/encargos/presentation/providers/encargo_providers.dart';
import '../../features/pagos/presentation/providers/pago_providers.dart';
import '../../features/productos/presentation/providers/producto_providers.dart';
import '../../features/clientes/presentation/screens/clientes_list_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/encargos/presentation/widgets/encargo_form_screen.dart';
import '../../features/pagos/presentation/screens/pagos_list_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/catalogo/presentation/screens/catalogo_screen.dart';
import '../../features/productos/presentation/screens/productos_list_screen.dart';
import '../../features/gastos/presentation/screens/viajes_list_screen.dart';

// PALETA OBLIGATORIA
abstract class DashboardTheme {
  static const Color background = Color(0xFFFAF8F5); // Crema
  static const Color surface = Color(0xFFFFFCF9);    // Blanco
  static const Color olive = Color(0xFF748363);      // Verde Oliva
  static const Color terracota = Color(0xFFC86442); // Terracota
  static const Color beige = Color(0xFFC9A77D);      // Beige
  static const Color textPrimary = Color(0xFF2A2724);
  static const Color textSecondary = Color(0xFF8E867C);
  static const Color border = Color(0xFFF0EAE4);
  static const Color iconBg = Color(0xFFF3EAE0);
}

final dashboardStatsProvider = Provider((ref) {
  final clientesAsync = ref.watch(clientesStreamProvider);
  final encargosAsync = ref.watch(encargosStreamProvider);
  final pagosAsync = ref.watch(pagosStreamProvider);
  final productosAsync = ref.watch(productosStreamProvider);

  final clientes = clientesAsync.asData?.value ?? [];
  final encargos = encargosAsync.asData?.value ?? [];
  final pagos = pagosAsync.asData?.value ?? [];
  final productos = productosAsync.asData?.value ?? [];

  int conDeuda = 0;
  for (final c in clientes) {
    if (c.id != null) {
      final totalE = encargos
          .where((e) => e.clienteId == c.id && e.activo && e.estado != 'PENDIENTE')
          .fold(0, (sum, e) => sum + e.total);
      final totalP = pagos.where((p) => p.clienteId == c.id).fold(0, (sum, p) => sum + p.monto);
      if (totalE - totalP > 0) conDeuda++;
    }
  }

  final encargosActivos = encargos.where((e) => e.activo && (e.estado == 'PENDIENTE' || e.estado == 'COMPRADO')).length;
  final entregasPendientes = encargos.where((e) => e.activo && e.estado == 'COMPRADO').length;

  final ahora = DateTime.now();
  int gananciaMes = 0;
  final encargosMes = encargos.where((e) => 
    e.activo && 
    (e.estado == 'ENTREGADO' || e.estado == 'FINALIZADO') &&
    e.fecha.month == ahora.month && e.fecha.year == ahora.year
  );
  
  for (final e in encargosMes) {
    for (final d in e.detalles) {
      final p = productos.where((prod) => prod.id == d.productoId).firstOrNull;
      if (p != null) {
        gananciaMes += ((d.precioUnitario ?? 0) - (d.costoUnitario ?? 0)) * d.cantidad;
      }
    }
  }

  return {
    'encargos': encargosActivos,
    'clientes': conDeuda,
    'entregas': entregasPendientes,
    'ganancia': gananciaMes,
  };
});

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final usuarioAsync = ref.watch(usuarioProfileProvider);

    return Scaffold(
      backgroundColor: DashboardTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                // 1. HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.sort_rounded, size: 30, color: DashboardTheme.textPrimary),
                    _NotificationBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 2. GREETING
                usuarioAsync.when(
                  data: (u) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '¡Hola, ${u?.primerNombre ?? "Camilo"}!',
                            style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w800, color: DashboardTheme.textPrimary, letterSpacing: -0.8),
                          ),
                          const SizedBox(width: 8),
                          const Text('👋', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      Text(
                        'Resumen de tu negocio',
                        style: GoogleFonts.outfit(fontSize: 15, color: DashboardTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(height: 50),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),

                // 3. HERO CARD
                _HeroGananciaCard(ganancia: stats['ganancia'] as int),
                const SizedBox(height: 32),

                // 4. RESUMEN RÁPIDO
                const _SectionHeader(title: 'Resumen rápido'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _StatItem(label: 'Encargos\nactivos', value: '${stats['encargos']}')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatItem(label: 'Clientes\ncon deuda', value: '${stats['clientes']}')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatItem(label: 'Entregas\npendientes', value: '${stats['entregas']}')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatItem(label: 'Ganancia\neste mes', value: formatCurrencyClp(stats['ganancia'] as int, compact: true), isPrice: true)),
                  ],
                ),
                const SizedBox(height: 32),

                // 5. ACCESOS RÁPIDOS (Cuadrados con texto dentro)
                const _SectionHeader(title: 'Accesos rápidos'),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85, // Ajustado para que el cuadrado sea casi perfecto y quepa el texto
                  children: [
                    _QuickAccess(icon: Icons.assignment_add, label: 'Nuevo encargo', color: DashboardTheme.terracota, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EncargoFormScreen()))),
                    _QuickAccess(icon: Icons.flash_on_rounded, label: 'Venta directa', color: DashboardTheme.terracota, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EncargoFormScreen(esVentaDirecta: true)))),
                    _QuickAccess(icon: Icons.account_balance_wallet_rounded, label: 'Registrar pago', color: DashboardTheme.olive, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PagosListScreen()))),
                    _QuickAccess(icon: Icons.storefront_rounded, label: 'Catálogo', color: DashboardTheme.terracota, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogoScreen()))),
                    _QuickAccess(icon: Icons.people_alt_rounded, label: 'Clientes', color: DashboardTheme.olive, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClientesListScreen()))),
                    _QuickAccess(icon: Icons.inventory_2_rounded, label: 'Productos', color: DashboardTheme.olive, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductosListScreen()))),
                    _QuickAccess(icon: Icons.local_shipping_rounded, label: 'Gastos viaje', color: DashboardTheme.beige, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ViajesListScreen()))),
                    _QuickAccess(icon: Icons.bar_chart_rounded, label: 'Reportes', color: DashboardTheme.olive, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportesScreen()))),
                  ],
                ),
                const SizedBox(height: 32),

                // 6. RECORDATORIOS
                const _SectionHeader(title: 'Recordatorios'),
                const SizedBox(height: 16),
                _ReminderTile(icon: Icons.access_time_filled_rounded, title: '${stats['clientes']} pagos vencidos', subtitle: 'Clientes con deuda', color: DashboardTheme.terracota, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClientesListScreen()))),
                const SizedBox(height: 12),
                _ReminderTile(icon: Icons.shopping_bag_rounded, title: '${stats['entregas']} entregas hoy', subtitle: 'Encargos por entregar', color: DashboardTheme.beige, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportesScreen()))),
                const SizedBox(height: 120),
              ],
            ),
            // FAB
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                backgroundColor: DashboardTheme.olive,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EncargoFormScreen())),
                child: const Icon(Icons.add, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: DashboardTheme.border.withValues(alpha: 0.5)),
      ),
      child: const Icon(Icons.notifications_none_rounded, size: 24, color: DashboardTheme.textPrimary),
    );
  }
}

class _HeroGananciaCard extends StatelessWidget {
  final int ganancia;
  const _HeroGananciaCard({required this.ganancia});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: DashboardTheme.border.withValues(alpha: 0.3)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ganancia este mes', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: DashboardTheme.textSecondary)),
              const SizedBox(height: 8),
              Text(formatCurrencyClp(ganancia), style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w900, color: DashboardTheme.textPrimary)),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE8EEDC), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up_rounded, size: 14, color: DashboardTheme.olive),
                  const SizedBox(width: 4),
                  Text('+12.5%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: DashboardTheme.olive)),
                ],
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: -15,
            child: Icon(Icons.eco_rounded, size: 70, color: DashboardTheme.olive.withValues(alpha: 0.06)),
          )
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: DashboardTheme.textPrimary)),
        Text('Ver todo', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: DashboardTheme.olive)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrice;
  const _StatItem({required this.label, required this.value, this.isPrice = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      decoration: BoxDecoration(
        color: DashboardTheme.surface, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: DashboardTheme.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: isPrice ? 12 : 20, fontWeight: FontWeight.w900, color: DashboardTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w600, color: DashboardTheme.textSecondary, height: 1.1)),
        ],
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccess({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: DashboardTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DashboardTheme.border.withValues(alpha: 0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), 
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label, 
                textAlign: TextAlign.center, 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 10, 
                  fontWeight: FontWeight.w700, 
                  color: DashboardTheme.textPrimary, 
                  height: 1.0
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReminderTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashboardTheme.border.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: DashboardTheme.textPrimary)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: DashboardTheme.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: DashboardTheme.textSecondary, size: 20),
      ),
    );
  }
}
