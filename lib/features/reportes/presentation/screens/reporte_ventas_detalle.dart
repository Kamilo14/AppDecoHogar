import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../../encargos/presentation/screens/encargo_detail_screen.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../gastos/presentation/providers/viaje_providers.dart';
import '../../../gastos/presentation/screens/viaje_detail_screen.dart';
import '../../domain/usecases/get_reporte_ganancias_usecase.dart';
import '../../domain/usecases/periodo_reporte.dart';

class ReporteVentasDetalle extends ConsumerStatefulWidget {
  const ReporteVentasDetalle({super.key});
  @override
  ConsumerState<ReporteVentasDetalle> createState() => _ReporteVentasState();
}

class _ReporteVentasState extends ConsumerState<ReporteVentasDetalle> {
  String modo = 'Mes';
  DateTime fecha = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final eAsync = ref.watch(encargosStreamProvider);
    final vAsync = ref.watch(viajesStreamProvider);
    final cAsync = ref.watch(comprasStreamProvider);
    final pAsync = ref.watch(productosStreamProvider);
    final clientesAsync = ref.watch(clientesStreamProvider);
    if ([eAsync, vAsync, cAsync, pAsync, clientesAsync].any((a) => a.hasError))
      return const Center(
          child: Text('No se pudo cargar el reporte. Vuelve a intentarlo.'));
    if ([eAsync, vAsync, cAsync, pAsync, clientesAsync].any((a) => a.isLoading))
      return const Center(child: CircularProgressIndicator());
    final periodo = PeriodoReporte(modo, fecha);
    final ventas = eAsync.requireValue
        .where((e) =>
            e.activo &&
            (e.estado == 'ENTREGADO' || e.estado == 'FINALIZADO') &&
            periodo.contiene(e.fechaVenta))
        .toList()
      ..sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
    final viajes =
        vAsync.requireValue.where((v) => periodo.contiene(v.fecha)).toList();
    final compras =
        cAsync.requireValue.where((c) => periodo.contiene(c.fecha)).toList();
    final productos = pAsync.requireValue;
    final clientes = clientesAsync.requireValue;
    final reporte = GetReporteGananciasUseCase()(productos, viajes, ventas);
    final inversion =
        compras.fold<int>(0, (s, c) => s + c.cantidad * c.costoUnitario);
    final gastos = viajes.fold<int>(0, (s, v) => s + v.totalGastos);
    return ListView(padding: const EdgeInsets.all(20), children: [
      SegmentedButton<String>(segments: const [
        ButtonSegment(value: 'Día', label: Text('Día')),
        ButtonSegment(value: 'Mes', label: Text('Mes')),
        ButtonSegment(value: 'Todos', label: Text('Todos'))
      ], selected: {
        modo
      }, onSelectionChanged: (v) => setState(() => modo = v.first)),
      if (modo != 'Todos')
        Row(children: [
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => fecha = modo == 'Mes'
                  ? DateTime(fecha.year, fecha.month - 1)
                  : DateTime(fecha.year, fecha.month, fecha.day - 1))),
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    final elegida = await showDatePicker(
                        context: context,
                        initialDate: fecha,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (elegida != null && mounted)
                      setState(() => fecha = elegida);
                  },
                  child: Text(modo == 'Mes'
                      ? '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}'
                      : formatDateCl(fecha)))),
          IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => fecha = modo == 'Mes'
                  ? DateTime(fecha.year, fecha.month + 1)
                  : DateTime(fecha.year, fecha.month, fecha.day + 1))),
        ])
      else
        const SizedBox(height: 16),
      _monto('Ventas entregadas', reporte.totalVendido),
      _monto('Costo de lo entregado (incluye logística asignada)',
          reporte.costoMercaderiaVendida),
      _monto('Ganancia bruta', reporte.gananciaBruta),
      _monto('Gastos de viaje no distribuidos', reporte.gastosNoDistribuidos),
      _monto('Resultado neto del período', reporte.gananciaNeta),
      const Text(
          'La mercadería que sigue en stock es inversión, no costo de una venta. Los gastos repartidos se reconocen al vender esas unidades.'),
      const Divider(height: 32),
      const Text('Ventas, costos y ganancias por cliente',
          style: TextStyle(fontWeight: FontWeight.bold)),
      if (ventas.isEmpty)
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Sin ventas en este período.')),
      ...ventas.map((e) {
        final cliente =
            clientes.where((c) => c.id == e.clienteId).firstOrNull?.nombre ??
                'Venta sin cliente';
        final r = GetReporteGananciasUseCase()(productos, [], [e]);
        return Card(
            child: ExpansionTile(
                title: Text('$cliente · ${formatCurrencyClp(e.total)}'),
                subtitle: Text('ENC-${e.id} · ${formatDateCl(e.fechaVenta)}'),
                childrenPadding: const EdgeInsets.all(16),
                children: [
              ...e.detalles.map((d) {
                final p =
                    productos.where((p) => p.id == d.productoId).firstOrNull;
                final compra = cAsync.requireValue
                    .where((c) => c.id == d.compraId)
                    .firstOrNull;
                final viaje = vAsync.requireValue
                    .where((v) => v.id == compra?.viajeId)
                    .firstOrNull;
                final costo =
                    (d.costoUnitario ?? p?.precioCompra ?? 0) * d.cantidad;
                final logistica =
                    d.costoLogistica ?? (p?.comisionViaje ?? 0) * d.cantidad;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${d.nombreTemporal ?? p?.nombre ?? 'Producto'} · ${d.cantidad} unidades',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          'Precio unitario: ${formatCurrencyClp(d.precioUnitario ?? 0)} · Venta: ${formatCurrencyClp(d.subtotal)}'),
                      Text(
                          'Costo: ${formatCurrencyClp(costo)} · Logística: ${formatCurrencyClp(logistica)}'),
                      Text(
                          'Ganancia: ${formatCurrencyClp(d.subtotal - costo - logistica)}'),
                      if (viaje != null)
                        TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ViajeDetailScreen(viajeId: viaje.id!))),
                            child: Text(
                                'Compra #${compra!.id} · ${viaje.destino} · ${formatDateCl(viaje.fecha)}')),
                      const Divider(),
                    ]);
              }),
              _monto('Costo total', r.costoMercaderiaVendida),
              _monto('Ganancia de esta venta', r.gananciaBruta),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EncargoDetailScreen(encargo: e))),
                  child: const Text('Ver venta y pagos')),
            ]));
      }),
      const Divider(height: 32),
      const Text('Compras y egresos por viaje',
          style: TextStyle(fontWeight: FontWeight.bold)),
      _monto('Inversión en compras del período', inversion),
      _monto('Gastos de viajes del período', gastos),
      _monto('Desembolso de compras y viajes', inversion + gastos),
      ...viajes.map((v) {
        final items = compras.where((c) => c.viajeId == v.id).toList();
        return Card(
            child: ExpansionTile(
                title: Text('${v.destino} · ${formatDateCl(v.fecha)}'),
                subtitle: Text(
                    'Compras: ${formatCurrencyClp(items.fold<int>(0, (s, c) => s + c.cantidad * c.costoUnitario))} · Gastos: ${formatCurrencyClp(v.totalGastos)}'),
                childrenPadding: const EdgeInsets.all(16),
                children: [
              ...items.map((c) => _monto(
                  '${c.nombreProducto} · ${c.cantidad} × ${formatCurrencyClp(c.costoUnitario)}',
                  c.cantidad * c.costoUnitario)),
              ...v.gastos.map((g) => _monto(g.tipo, g.monto)),
              _monto('Incorporado al costo de productos', v.montoDistribuido),
              _monto('Gasto separado', v.gastoSinDistribuir),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViajeDetailScreen(viajeId: v.id!))),
                  child: const Text('Ver viaje y compras')),
            ]));
      }),
    ]);
  }

  Widget _monto(String label, int valor) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        Text(formatCurrencyClp(valor),
            style: const TextStyle(fontWeight: FontWeight.bold))
      ]));
}
