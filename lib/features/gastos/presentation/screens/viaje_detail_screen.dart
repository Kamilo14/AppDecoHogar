import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../providers/viaje_providers.dart';
import '../widgets/gasto_form_dialog.dart';
import '../widgets/compra_viaje_dialog.dart';

class ViajeDetailScreen extends ConsumerStatefulWidget {
  final int viajeId;

  const ViajeDetailScreen({super.key, required this.viajeId});

  @override
  ConsumerState<ViajeDetailScreen> createState() => _ViajeDetailScreenState();
}

class _ViajeDetailScreenState extends ConsumerState<ViajeDetailScreen> {
  double _montoADistribuir = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final viajeAsync = ref.watch(viajeDetalleProvider(widget.viajeId));
    final productos = ref.watch(productosStreamProvider).asData?.value ?? const [];
    final productosDelViaje = productos.where((p) => p.viajeId == widget.viajeId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Logística de Viaje', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: viajeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (viaje) {
          if (viaje == null) return const Center(child: Text('Viaje no encontrado'));

          if (!_initialized) {
            _montoADistribuir = viaje.totalGastos.toDouble();
            _initialized = true;
          }

          double totalInversion = 0;
          for (final p in productosDelViaje) {
            final pesoPrecio = (p.precioCompra ?? 1000).toDouble();
            final pesoCantidad = p.cantidadDisponible <= 0 ? 1.0 : p.cantidadDisponible.toDouble();
            totalInversion += (pesoPrecio * pesoCantidad);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              // Info del Viaje
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(viaje.destino, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.textPrimary)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                          onPressed: () => showDialog(context: context, builder: (_) => GastoFormDialog(viajeId: widget.viajeId)),
                        ),
                      ],
                    ),
                    Text(formatDateCl(viaje.fecha), style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    const Divider(height: 32, color: AppColors.outline),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gastos totales:', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text(formatCurrencyClp(viaje.totalGastos), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Simulador
              Text('Simulador de Costos', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monto a recuperar:', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text(formatCurrencyClp(_montoADistribuir.toInt()), 
                          style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                      ],
                    ),
                    Slider(
                      value: _montoADistribuir,
                      min: 0,
                      max: (viaje.totalGastos > 0) ? viaje.totalGastos.toDouble() : 100,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.outline,
                      onChanged: (val) => setState(() => _montoADistribuir = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Lista de Productos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Precios Estimados', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.secondary),
                    onPressed: () => showDialog(context: context, builder: (_) => CompraViajeDialog(viajeId: widget.viajeId)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (productosDelViaje.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('Añade productos comprados en este viaje.', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                ))
              else
                ...productosDelViaje.map((p) {
                  double comisionUnitaria = 0;
                  if (totalInversion > 0) {
                    final pesoTotalProducto = (p.precioCompra ?? 1000) * (p.cantidadDisponible <= 0 ? 1 : p.cantidadDisponible);
                    final comisionTotalEsteProducto = (_montoADistribuir * (pesoTotalProducto / totalInversion));
                    comisionUnitaria = comisionTotalEsteProducto / (p.cantidadDisponible <= 0 ? 1 : p.cantidadDisponible);
                  }
                  
                  final int roundComision = comisionUnitaria.round();
                  final precioFinal = (p.precioVenta ?? 0) + roundComision;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                          child: Center(child: Text(p.nombre[0].toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                              Text('Base: ${formatCurrencyClp(p.precioVenta ?? 0)} + Costo Log.: ${formatCurrencyClp(roundComision)}', 
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Precio Final', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            Text(formatCurrencyClp(precioFinal), 
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 40),

              if (!viaje.distribuido && productosDelViaje.isNotEmpty)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text('Aplicar Distribución', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                        content: const Text('¿Deseas fijar estos precios en tu inventario?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Aplicar')),
                        ],
                      ),
                    );

                    if (confirmar == true && mounted) {
                      await ref.read(distribuirGastosUseCaseProvider).call(widget.viajeId, _montoADistribuir.toInt());
                      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventario actualizado con éxito')));
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text('Fijar Precios en Inventario', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
