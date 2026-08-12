import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../../gastos/presentation/providers/viaje_providers.dart';
import '../../../pagos/presentation/providers/pago_providers.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../domain/usecases/get_reporte_deudas_usecase.dart';
import '../../domain/usecases/get_reporte_ganancias_usecase.dart';
import '../../domain/usecases/get_reporte_ventas_usecase.dart';
import '../../domain/usecases/get_top_productos_vendidos_usecase.dart';
import '../../domain/usecases/get_ventas_por_dia_mes_usecase.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> with SingleTickerProviderStateMixin {
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

    final bool isLoading = clientesAsync.isLoading || 
                         encargosAsync.isLoading || 
                         pagosAsync.isLoading || 
                         productosAsync.isLoading || 
                         viajesAsync.isLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final clientes = clientesAsync.asData?.value ?? [];
    final encargos = encargosAsync.asData?.value ?? [];
    final pagos = pagosAsync.asData?.value ?? [];
    final productos = productosAsync.asData?.value ?? [];
    final viajes = viajesAsync.asData?.value ?? [];

    final ventas = GetReporteVentasUseCase().call(encargos);
    final deudas = GetReporteDeudasUseCase().call(clientes, encargos, pagos);
    final ganancias = GetReporteGananciasUseCase().call(productos, viajes, encargos);
    final totalRecuperado = pagos.fold<int>(0, (sum, pago) => sum + pago.monto);

    final ventasPorPeriodo = GetVentasPorDiaMesUseCase().call(encargos, _periodoSeleccionado);
    final labels = ventasPorPeriodo.keys.toList();
    final values = ventasPorPeriodo.values.toList();
    
    final maxVenta = values.isEmpty ? 0 : values.reduce((curr, next) => curr > next ? curr : next);
    final chartMaxY = (maxVenta == 0 || !maxVenta.isFinite) ? 1000.0 : maxVenta * 1.2;

    final barGroups = List.generate(labels.length, (i) {
      final double val = values[i].toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val.isFinite ? val : 0,
            color: const Color(0xFF6E7E52),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
    
    final topProductos = GetTopProductosVendidosUseCase().call(encargos, productos);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de Gestión')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EFE6), Color(0xFFFFFDF9)],
          ),
        ),
        child: Column(
          children: [
            WarmTabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Ventas'),
                Tab(text: 'Deudas'),
                Tab(text: 'Inventario'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Resumen
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Día', label: Text('Hoy')),
                          ButtonSegment(value: 'Semana', label: Text('Semana')),
                          ButtonSegment(value: 'Mes', label: Text('Mes')),
                        ],
                        selected: {_periodoSeleccionado},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _periodoSeleccionado = newSelection.first);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: WarmStatCard(
                              icon: Icons.point_of_sale_outlined,
                              label: 'Ventas (Cerradas)',
                              value: formatCurrencyClp(ganancias.totalVendido),
                              tint: const Color(0xFF6E7E52),
                              caption: 'período actual',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: WarmStatCard(
                              icon: Icons.savings_outlined,
                              label: 'Ganancia Neta',
                              value: formatCurrencyClp(ganancias.gananciaNeta),
                              tint: const Color(0xFFD67C52),
                              caption: 'margen real',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Rendimiento de Ventas', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      WarmSurfaceCard(
                        child: SizedBox(
                          height: 200,
                          child: values.every((v) => v == 0) 
                            ? const Center(child: Text('Sin ventas entregadas aún', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)))
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
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(labels[idx], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                                          if (!value.isFinite || value == 0) return const Text('');
                                          return Text(formatCurrencyClp(value.toInt(), compact: true), style: const TextStyle(fontSize: 9));
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: barGroups,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Top productos más vendidos', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      WarmSurfaceCard(
                        child: topProductos.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: Text('Sin ventas registradas')),
                              )
                            : Column(
                                children: topProductos.map((item) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.star_border, color: Color(0xFFBFA995)),
                                    title: Text(item.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
                                    subtitle: Text('${item.unidades} unidades'),
                                    trailing: Text(formatCurrencyClp(item.montoTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                  // Tab Ventas
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      WarmSurfaceCard(
                        child: Column(
                          children: [
                            WarmInfoRow(label: 'Total de Ventas', value: formatCurrencyClp(ganancias.totalVendido)),
                            WarmInfoRow(label: 'Costo Mercaderia Vendida', value: formatCurrencyClp(ganancias.costoMercaderiaVendida)),
                            const Divider(height: 32),
                            WarmInfoRow(label: 'Ganancia Bruta', value: formatCurrencyClp(ganancias.gananciaNeta), isBoldValue: true),
                          ],
                        ),
                      )
                    ],
                  ),
                  // Tab Deudas
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      WarmSurfaceCard(
                        child: Column(
                          children: [
                            WarmInfoRow(label: 'Total por Cobrar', value: formatCurrencyClp(deudas.fold<int>(0, (sum, d) => sum + d.deuda))),
                            WarmInfoRow(label: 'Total Recuperado', value: formatCurrencyClp(totalRecuperado)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (deudas.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No hay deudas pendientes'),
                        ))
                      else
                        ...deudas.map((item) => ListTile(
                          title: Text(item.cliente.nombre),
                          trailing: Text(formatCurrencyClp(item.deuda), style: const TextStyle(color: Color(0xFFD67C52), fontWeight: FontWeight.bold)),
                        )),
                    ],
                  ),
                  // Tab Inventario
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      WarmSurfaceCard(
                        child: Column(
                          children: [
                            WarmInfoRow(label: 'Valor Invertido en Stock', value: formatCurrencyClp(ganancias.totalInvertidoEnStock)),
                            WarmInfoRow(label: 'Variedad de Productos', value: '${productos.where((p) => p.activo).length} items'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Listado de Existencias', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      ...productos.where((p) => p.activo && p.cantidadDisponible > 0).map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Inversión: ${formatCurrencyClp(p.precioCompra ?? 0)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${p.cantidadDisponible} un.', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF8A6B4F))),
                              Text('Total: ${formatCurrencyClp((p.precioCompra ?? 0) * p.cantidadDisponible)}', style: const TextStyle(fontSize: 10)),
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
      ),
    );
  }
}
