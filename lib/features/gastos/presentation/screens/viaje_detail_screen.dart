import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../providers/viaje_providers.dart';
import '../widgets/gasto_form_dialog.dart';
import '../widgets/compra_viaje_dialog.dart';

class ViajeDetailScreen extends ConsumerStatefulWidget {
  final int viajeId;
  const ViajeDetailScreen({super.key, required this.viajeId});
  @override
  ConsumerState<ViajeDetailScreen> createState() => _ViajeDetailState();
}

class _ViajeDetailState extends ConsumerState<ViajeDetailScreen> {
  double? monto;
  bool guardando = false;
  Future<void> aplicar(int cantidad) async {
    setState(() => guardando = true);
    try {
      await ref
          .read(distribuirGastosUseCaseProvider)
          .call(widget.viajeId, cantidad);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Reparto guardado. Los gastos no se contabilizan dos veces.')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comprasAsync = ref.watch(comprasStreamProvider);
    final compras = (comprasAsync.asData?.value ?? [])
        .where((c) => c.viajeId == widget.viajeId)
        .toList();
    final encargos = ref.watch(encargosStreamProvider).asData?.value ?? [];
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? [];
    return Scaffold(
        appBar: AppBar(title: const Text('Logística del viaje')),
        body: ref.watch(viajeDetalleProvider(widget.viajeId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (viaje) {
              if (viaje == null)
                return const Center(child: Text('Viaje no encontrado'));
              final inversion = compras.fold<int>(
                  0, (s, c) => s + c.cantidad * c.costoUnitario);
              final simulado = (monto ?? viaje.montoDistribuido.toDouble())
                  .clamp(0, viaje.totalGastos.toDouble())
                  .toDouble();
              final base = compras.fold<int>(
                  0,
                  (s, c) =>
                      s +
                      (c.costoUnitario > 0 ? c.costoUnitario : 1) * c.cantidad);
              return ListView(padding: const EdgeInsets.all(20), children: [
                Text(viaje.destino,
                    style: Theme.of(context).textTheme.headlineSmall),
                Text(formatDateCl(viaje.fecha)),
                if (viaje.observaciones != null) Text(viaje.observaciones!),
                const SizedBox(height: 16),
                _total('Compras de mercadería', inversion),
                _total('Gastos del viaje', viaje.totalGastos),
                _total('Desembolso total', inversion + viaje.totalGastos),
                const Divider(height: 32),
                Row(children: [
                  const Expanded(
                      child: Text('Detalle de gastos',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  IconButton(
                      tooltip: 'Agregar comida, pasajes o peajes',
                      icon: const Icon(Icons.add),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) =>
                              GastoFormDialog(viajeId: widget.viajeId)))
                ]),
                if (viaje.gastos.isEmpty) const Text('Sin gastos registrados.'),
                ...viaje.gastos.map((g) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(g.tipo),
                    trailing: Text(formatCurrencyClp(g.monto)))),
                const Divider(height: 32),
                const Text('Distribuir gastos en las compras',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text(
                    'El monto elegido se incorpora al costo de la mercadería. El resto se registra como gasto separado en Reportes.'),
                Slider(
                    value: simulado,
                    min: 0,
                    max: viaje.totalGastos > 0
                        ? viaje.totalGastos.toDouble()
                        : 1,
                    onChanged: guardando || compras.isEmpty
                        ? null
                        : (v) => setState(() => monto = v)),
                _total('Reparto seleccionado', simulado.round()),
                _total('Ya incorporado al costo', viaje.montoDistribuido),
                _total('Egresos separados guardados', viaje.gastoSinDistribuir),
                FilledButton(
                    onPressed:
                        guardando ? null : () => aplicar(simulado.round()),
                    child: Text(guardando ? 'Guardando…' : 'Guardar reparto')),
                const Divider(height: 32),
                Row(children: [
                  const Expanded(
                      child: Text('Compras y precios estimados',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  IconButton(
                      tooltip: 'Registrar varias compras',
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) =>
                              CompraViajeDialog(viajeId: widget.viajeId)))
                ]),
                if (comprasAsync.isLoading) const LinearProgressIndicator(),
                if (comprasAsync.hasError)
                  const Text('No se pudo cargar el historial de compras.'),
                if (compras.isEmpty)
                  const Text(
                      'Registra las compras de este viaje. Los productos anteriores sin historial conservan su stock; no vuelvas a cargar compras ya ingresadas.'),
                ...compras.map((c) {
                  final asociados = [
                    for (final e in encargos.where((e) => e.activo))
                      for (final d
                          in e.detalles.where((d) => d.compraId == c.id))
                        '${clientes.where((cl) => cl.id == e.clienteId).firstOrNull?.nombre ?? 'Venta sin cliente'} · ENC-${e.id} · ${d.cantidad} unidades (${e.estado})'
                  ];
                  final comision = base == 0
                      ? 0
                      : (simulado *
                              (c.costoUnitario > 0 ? c.costoUnitario : 1) /
                              base)
                          .round();
                  return Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.nombreProducto,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Compra #${c.id} · ${formatDateCl(c.fecha)} · ${c.cantidad} unidades'),
                                _total('Costo unitario', c.costoUnitario),
                                _total('Inversión de compra',
                                    c.costoUnitario * c.cantidad),
                                _total('Logística asignada a esta compra',
                                    c.gastoAsignado),
                                _total('Costo unitario estimado con reparto',
                                    c.costoUnitario + comision),
                                _total('Precio sugerido con reparto',
                                    c.precioVenta + comision),
                                if (asociados.isEmpty)
                                  const Text('Destino: inventario disponible'),
                                ...asociados.map((s) => Text(s)),
                              ])));
                }),
              ]);
            }));
  }

  Widget _total(String label, int monto) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(child: Text(label)),
        Text(formatCurrencyClp(monto),
            style: const TextStyle(fontWeight: FontWeight.bold))
      ]));
}
