import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EFE6), Color(0xFFFFFDF9)],
          ),
        ),
        child: SafeArea(
          child: viajesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (viajes) {
              final activeViaje = viajes.isNotEmpty ? viajes.first : null;
              final activeViajeId = activeViaje?.id;
              final productosDelViaje = activeViajeId == null
                  ? const <Producto>[]
                  : productos.where((p) => p.viajeId == activeViajeId).toList();

              int comisionObtenida = 0;
              if (activeViaje != null) {
                for (final g in activeViaje.gastos) {
                  if (g.tipo.toLowerCase().contains('comisi')) {
                    comisionObtenida = comisionObtenida + g.monto.toInt();
                  }
                }
              }

              int comisionProductosTotal = 0;
              for (final p in productosDelViaje) {
                final int valorComision = p.comisionViaje;
                comisionProductosTotal = comisionProductosTotal + valorComision;
              }

              final comisionTotal = comisionObtenida > 0 ? comisionObtenida : comisionProductosTotal;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Viajes de Compra',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 28),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const ViajeFormDialog(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra tus viajes y distribuye los gastos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2C221E).withAlpha(150),
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (activeViaje != null) ...[
                    Text(
                      'Último viaje',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                    ),
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
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18)),
                              WarmPill(
                                label: activeViaje.distribuido ? 'Cerrado' : 'Pendiente',
                                color: activeViaje.distribuido ? const Color(0xFF6E7E52) : const Color(0xFFD67C52),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(formatDateCl(activeViaje.fecha),
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: const Color(0xFF2C221E).withAlpha(150))),
                          const Divider(height: 24),
                          WarmInfoRow(label: 'Total gastos registrados', value: formatCurrencyClp(activeViaje.totalGastos)),
                          WarmInfoRow(label: 'Comisión asignada', value: formatCurrencyClp(comisionTotal)),
                          WarmInfoRow(
                            label: 'Productos vinculados',
                            value: '${productosDelViaje.length} prod.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Historial de viajes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 12),

                  if (viajes.length <= 1 && activeViaje != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No hay más viajes registrados',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  else if (viajes.isEmpty)
                    WarmSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.directions_car_filled_outlined, size: 48, color: Color(0xFFBFA995)),
                              const SizedBox(height: 12),
                              Text(
                                'Aún no hay viajes registrados',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...viajes.skip(1).map(
                          (viaje) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: WarmSurfaceCard(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ViajeDetailScreen(viajeId: viaje.id!)),
                                );
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withAlpha(25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.directions_car_outlined,
                                        color: Theme.of(context).colorScheme.primary, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(viaje.destino,
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(formatDateCl(viaje.fecha),
                                            style: GoogleFonts.outfit(
                                                fontSize: 11, color: const Color(0xFF2C221E).withAlpha(150))),
                                      ],
                                    ),
                                  ),
                                  WarmPill(
                                    label: viaje.distribuido ? 'Cerrado' : 'Pendiente',
                                    color: viaje.distribuido ? const Color(0xFF6E7E52) : const Color(0xFFD67C52),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: Color(0xFFBFA995), size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
