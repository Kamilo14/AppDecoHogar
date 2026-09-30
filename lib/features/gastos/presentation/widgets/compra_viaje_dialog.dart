import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../data/datasources/compra_local_datasource.dart';
import '../providers/viaje_providers.dart';

class CompraViajeDialog extends ConsumerStatefulWidget {
  final int viajeId;
  const CompraViajeDialog({super.key, required this.viajeId});
  @override
  ConsumerState<CompraViajeDialog> createState() => _CompraViajeState();
}

class _LineaCompra {
  String modo = 'catalogo';
  int? productoId, encargoId, detalleId;
  final nombre = TextEditingController();
  final cantidad = TextEditingController(text: '1');
  final costo = TextEditingController();
  final precio = TextEditingController();
  final cliente = TextEditingController(text: '1');
  bool todas = true;
  void dispose() {
    for (final c in [nombre, cantidad, costo, precio, cliente]) {
      c.dispose();
    }
  }
}

class _CompraViajeState extends ConsumerState<CompraViajeDialog> {
  final form = GlobalKey<FormState>();
  final lineas = [_LineaCompra()];
  bool guardando = false;
  @override
  void dispose() {
    for (final l in lineas) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> guardar() async {
    if (!form.currentState!.validate()) return;
    setState(() => guardando = true);
    try {
      await ref.read(compraDataSourceProvider).registrar(
          widget.viajeId,
          lineas
              .map((l) => EntradaCompra(
                    productoId: l.productoId,
                    nombre: l.nombre.text.trim(),
                    cantidad: int.parse(l.cantidad.text),
                    costoUnitario: int.parse(l.costo.text),
                    precioVenta: int.parse(l.precio.text),
                    encargoId: l.encargoId,
                    detalleId: l.detalleId,
                    cantidadCliente: l.encargoId == null
                        ? 0
                        : int.parse(l.todas ? l.cantidad.text : l.cliente.text),
                  ))
              .toList());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => guardando = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = ref.watch(productosStreamProvider).asData?.value ?? [];
    final encargos = ref.watch(encargosStreamProvider).asData?.value ?? [];
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? [];
    final pendientes = [
      for (final e
          in encargos.where((e) => e.activo && e.estado == 'PENDIENTE'))
        for (final d
            in e.detalles.where((d) => !d.comprado && d.compraId == null))
          (encargo: e, detalle: d)
    ];
    return Dialog.fullscreen(
        child: Scaffold(
      appBar: AppBar(title: const Text('Registrar compras del viaje')),
      body: Form(
          key: form,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            const Text(
                'Cada compra se registra una vez. Puedes crear productos, reponer stock o asociar unidades a un encargo.'),
            ...lineas.asMap().entries.map((entry) {
              final l = entry.value;
              return Card(
                  key: ObjectKey(l),
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Row(children: [
                          Expanded(child: Text('Producto ${entry.key + 1}')),
                          IconButton(
                              onPressed: guardando || lineas.length == 1
                                  ? null
                                  : () => setState(() {
                                        lineas.remove(l);
                                        l.dispose();
                                      }),
                              icon: const Icon(Icons.delete_outline))
                        ]),
                        DropdownButtonFormField<String>(
                            initialValue: l.modo,
                            isExpanded: true,
                            decoration:
                                const InputDecoration(labelText: 'Origen'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'catalogo',
                                  child:
                                      Text('Producto existente / reposición')),
                              DropdownMenuItem(
                                  value: 'nuevo',
                                  child: Text('Producto nuevo')),
                              DropdownMenuItem(
                                  value: 'encargo',
                                  child: Text('Asociar a un encargo pendiente'))
                            ],
                            onChanged: guardando
                                ? null
                                : (v) => setState(() {
                                      l.modo = v!;
                                      l.productoId = null;
                                      l.encargoId = null;
                                      l.detalleId = null;
                                      l.nombre.clear();
                                    })),
                        const SizedBox(height: 12),
                        if (l.modo == 'catalogo')
                          Autocomplete<Producto>(
                              optionsBuilder: (v) => productos.where((p) =>
                                  p.activo &&
                                  p.nombre
                                      .toLowerCase()
                                      .contains(v.text.toLowerCase())),
                              displayStringForOption: (p) => p.nombre,
                              onSelected: (p) {
                                l.productoId = p.id;
                                l.nombre.text = p.nombre;
                                l.costo.text = p.precioCompra?.toString() ?? '';
                                l.precio.text = p.precioVenta?.toString() ?? '';
                              },
                              fieldViewBuilder: (_, ctrl, node, __) =>
                                  TextFormField(
                                      controller: ctrl,
                                      focusNode: node,
                                      decoration: const InputDecoration(
                                          labelText:
                                              'Buscar y seleccionar producto',
                                          prefixIcon: Icon(Icons.search)),
                                      onChanged: (_) {
                                        l.productoId = null;
                                      },
                                      validator: (_) => l.productoId == null
                                          ? 'Selecciona un producto de la lista'
                                          : null)),
                        if (l.modo == 'nuevo')
                          TextFormField(
                              controller: l.nombre,
                              decoration: const InputDecoration(
                                  labelText: 'Nombre del nuevo producto'),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Ingresa el nombre'
                                  : null),
                        if (l.modo == 'encargo')
                          DropdownButtonFormField<int>(
                              initialValue: l.detalleId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  labelText: 'Cliente y producto solicitado'),
                              items: pendientes.map((p) {
                                final cliente = clientes
                                        .where(
                                            (c) => c.id == p.encargo.clienteId)
                                        .firstOrNull
                                        ?.nombre ??
                                    'Cliente';
                                final nombre = p.detalle.nombreTemporal ??
                                    productos
                                        .where((prod) =>
                                            prod.id == p.detalle.productoId)
                                        .firstOrNull
                                        ?.nombre ??
                                    'Producto';
                                return DropdownMenuItem(
                                    value: p.detalle.id,
                                    child: Text(
                                        '$cliente · $nombre (${p.detalle.cantidad})',
                                        overflow: TextOverflow.ellipsis));
                              }).toList(),
                              validator: (v) =>
                                  v == null ? 'Selecciona el encargo' : null,
                              onChanged: (v) => setState(() {
                                    final p = pendientes
                                        .firstWhere((p) => p.detalle.id == v);
                                    l.detalleId = v;
                                    l.encargoId = p.encargo.id;
                                    l.productoId = p.detalle.productoId;
                                    l.nombre.text = p.detalle.nombreTemporal ??
                                        productos
                                            .where((prod) =>
                                                prod.id == l.productoId)
                                            .firstOrNull
                                            ?.nombre ??
                                        '';
                                    l.cantidad.text =
                                        p.detalle.cantidad.toString();
                                    l.cliente.text = l.cantidad.text;
                                    l.costo.text =
                                        p.detalle.costoUnitario?.toString() ??
                                            '';
                                    l.precio.text =
                                        p.detalle.precioUnitario?.toString() ??
                                            '';
                                  })),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: l.cantidad,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Cantidad comprada'),
                            validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                                ? 'Mínimo 1'
                                : null),
                        if (l.modo == 'encargo') ...[
                          CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                  'Todas las unidades son para el cliente'),
                              value: l.todas,
                              onChanged: (v) => setState(() => l.todas = v!)),
                          if (!l.todas)
                            TextFormField(
                                controller: l.cliente,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Cantidad para el cliente'),
                                validator: (v) {
                                  final n = int.tryParse(v ?? '') ?? 0;
                                  return n <= 0 ||
                                          n >
                                              (int.tryParse(l.cantidad.text) ??
                                                  0)
                                      ? 'Revisa las unidades para el cliente'
                                      : null;
                                }),
                        ],
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: TextFormField(
                                  controller: l.costo,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Costo unitario',
                                      prefixText: r'$ '),
                                  validator: (v) =>
                                      int.tryParse(v ?? '') == null ||
                                              int.parse(v!) < 0
                                          ? 'Costo inválido'
                                          : null)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: TextFormField(
                                  controller: l.precio,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Precio de venta',
                                      prefixText: r'$ '),
                                  validator: (v) =>
                                      (int.tryParse(v ?? '') ?? 0) <= 0
                                          ? 'Precio inválido'
                                          : null)),
                        ]),
                      ])));
            }),
            OutlinedButton.icon(
                onPressed: guardando
                    ? null
                    : () => setState(() => lineas.add(_LineaCompra())),
                icon: const Icon(Icons.add),
                label: const Text('Añadir otro producto')),
            FilledButton(
                onPressed: guardando ? null : guardar,
                child: Text(
                    guardando ? 'Guardando…' : 'Guardar todas las compras')),
          ])),
    ));
  }
}
