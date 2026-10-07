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
import '../../domain/usecases/periodo_reporte.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _periodoSeleccionado = 'Mes'; // 'Día', 'Semana', 'Mes'
  DateTime _fechaSeleccionada = DateTime.now();

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

    if (clientesAsync.isLoading ||
        encargosAsync.isLoading ||
        pagosAsync.isLoading ||
        productosAsync.isLoading ||
        viajesAsync.isLoading) {
      return const AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final clientes = clientesAsync.asData?.value ?? const [];
    final encargos = encargosAsync.asData?.value ?? const [];
    final pagos = pagosAsync.asData?.value ?? const [];
    final productos = productosAsync.asData?.value ?? const [];
    final viajes = viajesAsync.asData?.value ?? const [];

    final periodo = PeriodoReporte(_periodoSeleccionado, _fechaSeleccionada);

    // Filtrar movimientos según el período seleccionado (Día, Semana, Mes)
    final ventasPeriodo = encargos
        .where((e) =>
            e.activo &&
            e.tipoVenta != 'Por encargo' &&
            periodo.contiene(e.fecha))
        .toList();
    final pagosPeriodo =
        pagos.where((p) => periodo.contiene(p.fecha)).toList();
    final viajesPeriodo =
        viajes.where((v) => periodo.contiene(v.fecha)).toList();

    final reporte =
        GetReporteGananciasUseCase()(productos, viajesPeriodo, ventasPeriodo);
    final ventasRegistradas =
        ventasPeriodo.fold<int>(0, (s, e) => s + e.total);
    final cobrosRecibidos = pagosPeriodo.fold<int>(0, (s, p) => s + p.monto);
    final egresosDirectos =
        viajesPeriodo.fold<int>(0, (s, v) => s + v.gastoSinDistribuir);

    final deudas = GetReporteDeudasUseCase()(clientes, encargos, pagos);
    final totalDeuda = deudas.fold<int>(0, (s, d) => s + d.deuda);

    // Generar datos para el gráfico de barras según el período activo
    final datosGrafico = <String, int>{};
    if (_periodoSeleccionado == 'Día') {
      datosGrafico[periodo.etiqueta] = ventasRegistradas;
    } else if (_periodoSeleccionado == 'Semana') {
      final inicio = periodo.inicio;
      for (var i = 0; i < 7; i++) {
        final f = inicio.add(Duration(days: i));
        final label = '${f.day}/${f.month}';
        datosGrafico[label] = ventasPeriodo
            .where((e) =>
                e.fecha.year == f.year &&
                e.fecha.month == f.month &&
                e.fecha.day == f.day)
            .fold<int>(0, (s, e) => s + e.total);
      }
    } else {
      // Mes
      for (var i = 0; i < 5; i++) {
        final label = 'Sem ${i + 1}';
        datosGrafico[label] = ventasPeriodo
            .where(
                (e) => e.fecha.day > i * 7 && e.fecha.day <= (i + 1) * 7)
            .fold<int>(0, (s, e) => s + e.total);
      }
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'Reportes de Gestión',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              WarmTabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Resumen'),
                  Tab(text: 'Resultado'),
                  Tab(text: 'Deudas'),
                  Tab(text: 'Inventario'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Resumen
                    ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _periodSelector(),
                        const SizedBox(height: 12),
                        _dateSelector(),
                        const SizedBox(height: 24),
                        Text(
                          'Resumen del período',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: WarmStatCard(
                                icon: Icons.point_of_sale_outlined,
                                label: 'Ventas',
                                value: formatCurrencyClp(ventasRegistradas),
                                tint: AppColors.secondary,
                                caption: '${ventasPeriodo.length} registradas',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: WarmStatCard(
                                icon: Icons.payments_outlined,
                                label: 'Cobros',
                                value: formatCurrencyClp(cobrosRecibidos),
                                tint: AppColors.primary,
                                caption: 'recibidos',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: WarmStatCard(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Por cobrar',
                                value: formatCurrencyClp(totalDeuda),
                                tint: AppColors.error,
                                caption: 'deuda actual',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: WarmStatCard(
                                icon: Icons.trending_up_rounded,
                                label: 'Resultado',
                                value: formatCurrencyClp(reporte.gananciaNeta),
                                tint: AppColors.secondary,
                                caption: 'neto estimado',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Rendimiento de ventas',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _graficoVentas(datosGrafico),
                        const SizedBox(height: 16),
                        _card([
                          WarmInfoRow(
                            label: 'Egresos del período',
                            value: formatCurrencyClp(egresosDirectos),
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Costo de mercadería',
                            value: formatCurrencyClp(
                                reporte.costoMercaderiaVendida),
                          ),
                        ]),
                      ],
                    ),

                    // Tab 2: Resultado
                    ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _periodSelector(),
                        const SizedBox(height: 12),
                        _dateSelector(),
                        const SizedBox(height: 24),
                        _sectionTitle('Reporte final del período (${periodo.etiqueta})'),
                        const SizedBox(height: 12),
                        _card([
                          WarmInfoRow(
                            label: 'Ventas realizadas',
                            value: formatCurrencyClp(ventasRegistradas),
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Cobros recibidos',
                            value: formatCurrencyClp(cobrosRecibidos),
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Deuda pendiente actual',
                            value: formatCurrencyClp(totalDeuda),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _sectionTitle('Resultado estimado'),
                        const SizedBox(height: 12),
                        _card([
                          WarmInfoRow(
                            label: 'Ventas registradas',
                            value: formatCurrencyClp(ventasRegistradas),
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Costo de mercadería vendida',
                            value:
                                '- ${formatCurrencyClp(reporte.costoMercaderiaVendida)}',
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Egresos (viajes, comidas y otros)',
                            value:
                                '- ${formatCurrencyClp(egresosDirectos)}',
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Resultado neto estimado',
                            value: formatCurrencyClp(reporte.gananciaNeta),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        Text(
                          'Las ventas se contabilizan al registrarlas. Los abonos se muestran cuando se reciben, por lo que pagar una deuda antigua no crea una venta nueva.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),

                    // Tab 3: Deudas
                    ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _card([
                          WarmInfoRow(
                            label: 'Total por cobrar',
                            value: formatCurrencyClp(totalDeuda),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        if (deudas.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text('No hay deudas pendientes'),
                            ),
                          )
                        else
                          ...deudas.map(
                            (item) => _card([
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  item.cliente.nombre,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700),
                                ),
                                trailing: Text(
                                  formatCurrencyClp(item.deuda),
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ]),
                          ),
                      ],
                    ),

                    // Tab 4: Inventario
                    ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _card([
                          WarmInfoRow(
                            label: 'Valor invertido en stock',
                            value: formatCurrencyClp(
                                reporte.totalInvertidoEnStock),
                          ),
                          const Divider(
                              height: 28, color: AppColors.outline),
                          WarmInfoRow(
                            label: 'Variedad de productos',
                            value:
                                '${productos.where((p) => p.activo).length} items',
                          ),
                        ]),
                        const SizedBox(height: 24),
                        ...productos
                            .where((p) => p.activo && p.cantidadDisponible > 0)
                            .map(
                              (p) => _card([
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    p.nombre,
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    'Inversión: ${formatCurrencyClp(p.precioCompra ?? 0)}',
                                  ),
                                  trailing: Text(
                                    '${stockLibre[p.id] ?? 0} disponibles',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      );

  Widget _periodSelector() => SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.surface,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        segments: const [
          ButtonSegment(value: 'Día', label: Text('Día')),
          ButtonSegment(value: 'Semana', label: Text('Semana')),
          ButtonSegment(value: 'Mes', label: Text('Mes')),
        ],
        selected: {_periodoSeleccionado},
        onSelectionChanged: (value) =>
            setState(() => _periodoSeleccionado = value.first),
      );

  Widget _dateSelector() {
    final periodo = PeriodoReporte(_periodoSeleccionado, _fechaSeleccionada);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_periodoSeleccionado == 'Día') {
                  _fechaSeleccionada =
                      _fechaSeleccionada.subtract(const Duration(days: 1));
                } else if (_periodoSeleccionado == 'Semana') {
                  _fechaSeleccionada =
                      _fechaSeleccionada.subtract(const Duration(days: 7));
                } else {
                  _fechaSeleccionada = DateTime(
                      _fechaSeleccionada.year, _fechaSeleccionada.month - 1, 1);
                }
              });
            },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final elegida = await showDatePicker(
                context: context,
                initialDate: _fechaSeleccionada,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (elegida != null && mounted) {
                setState(() => _fechaSeleccionada = elegida);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    periodo.etiqueta,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (_periodoSeleccionado == 'Día') {
                  _fechaSeleccionada =
                      _fechaSeleccionada.add(const Duration(days: 1));
                } else if (_periodoSeleccionado == 'Semana') {
                  _fechaSeleccionada =
                      _fechaSeleccionada.add(const Duration(days: 7));
                } else {
                  _fechaSeleccionada = DateTime(
                      _fechaSeleccionada.year, _fechaSeleccionada.month + 1, 1);
                }
              });
            },
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _graficoVentas(Map<String, int> datos) {
    final etiquetas = datos.keys.toList();
    final valores = datos.values.toList();
    final maximo =
        valores.isEmpty ? 0 : valores.reduce((a, b) => a > b ? a : b);
    return Container(
      height: 235,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: maximo == 0
          ? Center(
              child: Text(
                'Sin ventas registradas',
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
            )
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maximo * 1.2,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ),
                ),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (valor, _) => valor == 0
                          ? const SizedBox.shrink()
                          : Text(
                              formatCurrencyClp(valor.toInt(), compact: true),
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (valor, _) {
                        final i = valor.toInt();
                        return i >= 0 && i < etiquetas.length
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  etiquetas[i],
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  valores.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: valores[i].toDouble(),
                        color: AppColors.secondary,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        child: Column(children: children),
      );
}
