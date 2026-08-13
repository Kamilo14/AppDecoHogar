import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../providers/viaje_providers.dart';
import '../widgets/viaje_form_dialog.dart';
import 'viaje_detail_screen.dart';

class ViajesListScreen extends ConsumerWidget {
  const ViajesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viajesAsync = ref.watch(viajesStreamProvider);
    final productos = ref.watch(productosStreamProvider).asData?.value ?? const <Producto>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: viajesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (viajes) {
            final activeViaje = viajes.isNotEmpty ? viajes.first : null;
            final activeViajeId = activeViaje?.id;
            final productosDelViaje = activeViajeId == null
                ? const <Producto>[]
                : productos.where((p) => p.viajeId == activeViajeId).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Viajes',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outline),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 24),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const ViajeFormDialog(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Registro de compras y logística.',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                if (activeViaje != null) ...[
                  Text('Último viaje', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  WarmSurfaceCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ViajeDetailScreen(viajeId: activeViaje.id!)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(activeViaje.destino,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                            WarmPill(
                              label: activeViaje.distribuido ? 'Cerrado' : 'Pendiente',
                              color: activeViaje.distribuido ? AppColors.secondary : AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(formatDateCl(activeViaje.fecha),
                            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                        const Divider(height: 24, color: AppColors.outline),
                        WarmInfoRow(label: 'Gastos registrados', value: formatCurrencyClp(activeViaje.totalGastos)),
                        const SizedBox(height: 4),
                        WarmInfoRow(label: 'Productos vinculados', value: '${productosDelViaje.length} items'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                Text('Historial', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                ...viajes.skip(1).map((viaje) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ViajeDetailScreen(viajeId: viaje.id!)),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.tertiary.withValues(alpha: 0.1),
                      child: const Icon(Icons.local_shipping_rounded, color: AppColors.tertiary, size: 20),
                    ),
                    title: Text(viaje.destino, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                    subtitle: Text(formatDateCl(viaje.fecha), style: GoogleFonts.outfit(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                  ),
                )),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }
}
