import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../encargos/domain/entities/encargo_entity.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../../encargos/presentation/screens/encargo_detail_screen.dart';
import '../../../encargos/presentation/widgets/encargo_form_screen.dart';
import '../../../pagos/presentation/providers/pago_providers.dart';

class VentasListScreen extends ConsumerStatefulWidget {
  const VentasListScreen({super.key});

  @override
  ConsumerState<VentasListScreen> createState() => _VentasListScreenState();
}

class _VentasListScreenState extends ConsumerState<VentasListScreen> {
  String _periodoSeleccionado = 'Todos';
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ventasAsync = ref.watch(encargosStreamProvider);
    final clientes =
        ref.watch(clientesStreamProvider).asData?.value ?? const [];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ventasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (encargos) {
              final todasLasVentas = encargos
                  .where((e) => e.activo && e.tipoVenta != 'Por encargo')
                  .toList();
              bool enPeriodo(DateTime fecha) {
                if (_periodoSeleccionado == 'Todos') return true;
                if (_periodoSeleccionado == 'Día') {
                  return fecha.year == _fechaSeleccionada.year &&
                      fecha.month == _fechaSeleccionada.month &&
                      fecha.day == _fechaSeleccionada.day;
                }
                return fecha.year == _fechaSeleccionada.year &&
                    fecha.month == _fechaSeleccionada.month;
              }

              final ventas = todasLasVentas
                  .where((venta) => enPeriodo(venta.fecha))
                  .toList()
                ..sort((a, b) => b.fecha.compareTo(a.fecha));
              final totalVentas =
                  ventas.fold<int>(0, (s, venta) => s + venta.total);

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  Text(
                    'Ventas',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra ventas reales, abonos y saldos pendientes.',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<String>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      selectedBackgroundColor: AppColors.primary,
                      selectedForegroundColor: Colors.white,
                      textStyle: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    segments: const [
                      ButtonSegment(value: 'Todos', label: Text('Todas')),
                      ButtonSegment(value: 'Día', label: Text('Día')),
                      ButtonSegment(value: 'Mes', label: Text('Mes')),
                    ],
                    selected: {_periodoSeleccionado},
                    onSelectionChanged: (seleccion) =>
                        setState(() => _periodoSeleccionado = seleccion.first),
                  ),
                  const SizedBox(height: 16),
                  if (_periodoSeleccionado != 'Todos') ...[
                    _DateSelector(
                      fecha: _fechaSeleccionada,
                      esMes: _periodoSeleccionado == 'Mes',
                      onAnterior: () => setState(() {
                        _fechaSeleccionada = _periodoSeleccionado == 'Mes'
                            ? DateTime(_fechaSeleccionada.year,
                                _fechaSeleccionada.month - 1, 1)
                            : _fechaSeleccionada
                                .subtract(const Duration(days: 1));
                      }),
                      onSiguiente: () => setState(() {
                        _fechaSeleccionada = _periodoSeleccionado == 'Mes'
                            ? DateTime(_fechaSeleccionada.year,
                                _fechaSeleccionada.month + 1, 1)
                            : _fechaSeleccionada.add(const Duration(days: 1));
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                  WarmStatCard(
                    icon: Icons.point_of_sale_outlined,
                    label: 'Total de ventas',
                    value: formatCurrencyClp(totalVentas),
                    tint: AppColors.secondary,
                    caption: '${ventas.length} venta(s) en el período',
                  ),
                  const SizedBox(height: 24),
                  if (ventas.isEmpty)
                    _buildEmptyState(context,
                        hayVentas: todasLasVentas.isNotEmpty)
                  else
                    ...ventas.map((venta) {
                      final cliente = clientes.firstWhere(
                        (c) => c.id == venta.clienteId,
                        orElse: () => Cliente(
                          nombre: 'Venta sin cliente',
                          fechaRegistro: DateTime.now(),
                        ),
                      );
                      return _VentaCard(venta: venta, cliente: cliente);
                    }),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EncargoFormScreen(esVentaDirecta: true),
              ),
            );
          },
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool hayVentas}) {
    return WarmSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.point_of_sale_rounded,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              hayVentas
                  ? 'No hay ventas en el período seleccionado'
                  : 'Aún no hay ventas registradas',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!hayVentas) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const EncargoFormScreen(esVentaDirecta: true),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nueva venta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime fecha;
  final bool esMes;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;

  const _DateSelector({
    required this.fecha,
    required this.esMes,
    required this.onAnterior,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    final etiqueta = esMes
        ? '${meses[fecha.month - 1]} ${fecha.year}'
        : '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onAnterior, icon: const Icon(Icons.chevron_left_rounded)),
          Text(etiqueta, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          IconButton(onPressed: onSiguiente, icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

class _VentaCard extends ConsumerWidget {
  final Encargo venta;
  final Cliente cliente;

  const _VentaCard({required this.venta, required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagoResumen = ref.watch(resumenPagoEncargoProvider(venta));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: WarmSurfaceCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EncargoDetailScreen(encargo: venta),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDateCl(venta.fechaVenta)} · ${venta.detalles.length} producto(s)',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrencyClp(venta.total),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                WarmPagoStatusChip(estadoPago: pagoResumen.estadoPago),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
