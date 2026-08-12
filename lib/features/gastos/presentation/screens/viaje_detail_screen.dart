import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../providers/viaje_providers.dart';
import '../widgets/distribuir_gastos_dialog.dart';
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
      appBar: AppBar(title: const Text('Simulador de Logística')),
      body: viajeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (viaje) {
          if (viaje == null) return const Center(child: Text('Viaje no encontrado'));

          if (!_initialized) {
            _montoADistribuir = viaje.totalGastos.toDouble();
            _initialized = true;
          }

          // Cálculo de base de inversión segura (Blindaje ERR-20)
          double totalInversion = 0;
          for (final p in productosDelViaje) {
            final pesoPrecio = (p.precioCompra ?? 1000).toDouble();
            final pesoCantidad = p.cantidadDisponible <= 0 ? 1.0 : p.cantidadDisponible.toDouble();
            totalInversion += (pesoPrecio * pesoCantidad);
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5EFE6), Color(0xFFFFFDF9)],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                WarmSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(viaje.destino, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8A6B4F)),
                            onPressed: () => showDialog(context: context, builder: (_) => GastoFormDialog(viajeId: widget.viajeId)),
                          ),
                        ],
                      ),
                      Text(formatDateCl(viaje.fecha), style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF2C221E).withAlpha(150))),
                      const Divider(height: 32),
                      WarmInfoRow(label: 'Gastos registrados:', value: formatCurrencyClp(viaje.totalGastos), isBoldValue: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Simulador de Recuperación', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                WarmSurfaceCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monto a distribuir:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(formatCurrencyClp(_montoADistribuir.isFinite ? _montoADistribuir.toInt() : 0), 
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Slider(
                        value: (_montoADistribuir.isFinite && _montoADistribuir >= 0) ? _montoADistribuir : 0,
                        min: 0,
                        max: (viaje.totalGastos > 0) ? viaje.totalGastos.toDouble() : 100,
                        onChanged: (val) => setState(() => _montoADistribuir = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Precios resultantes', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF8A6B4F)),
                      onPressed: () => showDialog(context: context, builder: (_) => CompraViajeDialog(viajeId: widget.viajeId)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (productosDelViaje.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Carga productos para simular sus precios.'),
                  ))
                else
                  ...productosDelViaje.map((p) {
                    double comisionUnitaria = 0;
                    if (totalInversion > 0 && _montoADistribuir.isFinite) {
                      final pesoPrecio = (p.precioCompra ?? 1000).toDouble();
                      final pesoCantidad = p.cantidadDisponible <= 0 ? 1.0 : p.cantidadDisponible.toDouble();
                      final pesoTotalProducto = pesoPrecio * pesoCantidad;
                      
                      final comisionTotalEsteProducto = (_montoADistribuir * (pesoTotalProducto / totalInversion));
                      comisionUnitaria = comisionTotalEsteProducto / pesoCantidad;
                    }
                    
                    final int roundComision = comisionUnitaria.isFinite ? comisionUnitaria.round() : 0;
                    final precioFinal = (p.precioVenta ?? 0) + roundComision;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: Colors.white.withAlpha(180),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: const Color(0xFFEFE6D9), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFF5EFE6),
                              radius: 20,
                              child: Text(p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF8A6B4F), fontSize: 14)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
                                  Text('Base: ${p.precioVenta != null ? formatCurrencyClp(p.precioVenta!) : "Pendiente"} + ${formatCurrencyClp(roundComision)}', 
                                    style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Precio Final', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                Text(formatCurrencyClp(precioFinal), 
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 32),

                if (!viaje.distribuido && productosDelViaje.isNotEmpty)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Agregar Distribución de precios'),
                          content: const Text('¿Desea agregar estos precios a los productos? Esto actualizará el inventario.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, Aplicar')),
                          ],
                        ),
                      );

                      if (confirmar == true && mounted) {
                        await ref.read(distribuirGastosUseCaseProvider).call(widget.viajeId, _montoADistribuir.toInt());
                        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Precios actualizados')));
                      }
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Agregar Distribución de precios'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
