import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../../gastos/presentation/providers/viaje_providers.dart';
import '../../../pagos/presentation/providers/pago_providers.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../domain/usecases/get_reporte_deudas_usecase.dart';
import '../../domain/usecases/get_reporte_ganancias_usecase.dart';
import 'reporte_ventas_detalle.dart';
import '../../domain/usecases/periodo_reporte.dart';
import '../../domain/usecases/get_top_productos_vendidos_usecase.dart';
import '../../domain/usecases/get_ventas_por_dia_mes_usecase.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _periodoSeleccionado = 'Mes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesStreamProvider);
    final encargosAsync = ref.watch(encargosStreamProvider);
    final pagosAsync = ref.watch(pagosStreamProvider);
    final productosAsync = ref.watch(productosStreamProvider);
    final viajesAsync = ref.watch(viajesStreamProvider);
    final stockLibre = ref.watch(stockLibreProvider);

    final bool isLoading = clientesAsync.isLoading ||
        encargosAsync.isLoading ||
        pagosAsync.isLoading ||
        productosAsync.isLoading ||
        viajesAsync.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final clientes = clientesAsync.asData?.value ?? [];
    final encargos = encargosAsync.asData?.value ?? [];
    final pagos = pagosAsync.asData?.value ?? [];
    final productos = productosAsync.asData?.value ?? [];
    final viajes = viajesAsync.asData?.value ?? [];

    final deudas = GetReporteDeudasUseCase().call(clientes, encargos, pagos);
    final ahora = DateTime.now();
    final periodo = PeriodoReporte(_periodoSeleccionado, ahora);
    bool contiene(DateTime f) => _periodoSeleccionado == 'Semana'
        ? !f.isBefore(DateTime(ahora.year, ahora.month, ahora.day - 6)) &&
            f.isBefore(DateTime(ahora.year, ahora.month, ahora.day + 1))
        : periodo.contiene(f);
    final encargosPeriodo =
        encargos.where((e) => contiene(e.fechaVenta)).toList();
    final ganancias = GetReporteGananciasUseCase().call(productos,
        viajes.where((v) => contiene(v.fecha)).toList(), encargosPeriodo);
    final totalRecuperado = pagos.fold<int>(0, (sum, pago) => sum + pago.monto);

    final ventasPorPeriodo =
        GetVentasPorDiaMesUseCase().call(encargos, _periodoSeleccionado);
    final labels = ventasPorPeriodo.keys.toList();
    final values = ventasPorPeriodo.values.toList();

    final maxVenta = values.isEmpty
        ? 0
        : values.reduce((curr, next) => curr > next ? curr : next);
    final chartMaxY =
        (maxVenta == 0 || !maxVenta.isFinite) ? 1000.0 : maxVenta * 1.2;

    final barGroups = List.generate(labels.length, (i) {
      final double val = values[i].toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val.isFinite ? val : 0,
            color: AppColors.secondary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final topProductos =
        GetTopProductosVendidosUseCase().call(encargosPeriodo, productos);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Reportes de Gestión',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.background,
            child: WarmTabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Ventas'),
                Tab(text: 'Deudas'),
                Tab(text: 'Inventario'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Resumen
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    SegmentedButton<String>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        selectedBackgroundColor: AppColors.primary,
                        selectedForegroundColor: Colors.white,
                        textStyle: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      segments: const [
                        ButtonSegment(value: 'Día', label: Text('Hoy')),
                        ButtonSegment(value: 'Semana', label: Text('Semana')),
                        ButtonSegment(value: 'Mes', label: Text('Mes')),
                      ],
                      selected: {_periodoSeleccionado},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(
                            () => _periodoSeleccionado = newSelection.first);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: WarmStatCard(
                            icon: Icons.point_of_sale_outlined,
                            label: 'Ventas (Cerradas)',
                            value: formatCurrencyClp(ganancias.totalVendido),
                            tint: AppColors.secondary,
                            caption: 'período actual',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: WarmStatCard(
                            icon: Icons.savings_outlined,
                            label: 'Ganancia Neta',
                            value: formatCurrencyClp(ganancias.gananciaNeta),
                            tint: AppColors.primary,
                            caption: 'margen real',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Rendimiento de Ventas',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.5)),
                      ),
                      child: SizedBox(
                        height: 200,
                        child: values.every((v) => v == 0)
                            ? const Center(
                                child: Text('Sin ventas entregadas aún',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12)))
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: chartMaxY,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx >= 0 && idx < labels.length) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(labels[idx],
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors
                                                          .textSecondary)),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          if (!value.isFinite || value == 0)
                                            return const Text('');
                                          return Text(
                                              formatCurrencyClp(value.toInt(),
                                                  compact: true),
                                              style: GoogleFonts.outfit(
                                                  fontSize: 9,
                                                  color:
                                                      AppColors.textSecondary));
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                              color: AppColors.outline,
                                              strokeWidth: 1)),
                                  borderData: FlBorderData(show: false),
                                  barGroups: barGroups,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Top productos más vendidos',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.5)),
                      ),
                      child: topProductos.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child:
                                  Center(child: Text('Sin ventas registradas')),
                            )
                          : Column(
                              children: topProductos.map((item) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    child: const Icon(Icons.star_rounded,
                                        color: AppColors.primary, size: 20),
                                  ),
                                  title: Text(item.nombre,
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                  subtitle: Text('${item.unidades} unidades',
                                      style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                  trailing: Text(
                                      formatCurrencyClp(item.montoTotal),
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary)),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
                const ReporteVentasDetalle(),
                // Tab Deudas
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          WarmInfoRow(
                              label: 'Total por Cobrar',
                              value: formatCurrencyClp(deudas.fold<int>(
                                  0, (sum, d) => sum + d.deuda))),
                          const Divider(height: 32, color: AppColors.outline),
                          WarmInfoRow(
                              label: 'Total Recuperado',
                              value: formatCurrencyClp(totalRecuperado)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (deudas.isEmpty)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No hay deudas pendientes'),
                      ))
                    else
                      ...deudas.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      AppColors.outline.withValues(alpha: 0.5)),
                            ),
                            child: ListTile(
                              title: Text(item.cliente.nombre,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                              trailing: Text(formatCurrencyClp(item.deuda),
                                  style: GoogleFonts.outfit(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w800)),
                            ),
                          )),
                  ],
                ),
                // Tab Inventario
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          WarmInfoRow(
                              label: 'Valor Invertido en Stock',
                              value: formatCurrencyClp(
                                  ganancias.totalInvertidoEnStock)),
                          const Divider(height: 32, color: AppColors.outline),
                          WarmInfoRow(
                              label: 'Variedad de Productos',
                              value:
                                  '${productos.where((p) => p.activo).length} items'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Listado de Existencias',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    ...productos
                        .where((p) => p.activo && p.cantidadDisponible > 0)
                        .map((p) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.outline
                                        .withValues(alpha: 0.5)),
                              ),
                              child: ListTile(
                                title: Text(p.nombre,
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                subtitle: Text(
                                    'Inversión: ${formatCurrencyClp(p.precioCompra ?? 0)}',
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${stockLibre[p.id] ?? 0} disponibles',
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.secondary)),
                                    Text(
                                        '${p.cantidadDisponible - (stockLibre[p.id] ?? 0)} reservadas',
                                        style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                    Text(
                                        'Total: ${formatCurrencyClp((p.precioCompra ?? 0) * p.cantidadDisponible)}',
                                        style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
