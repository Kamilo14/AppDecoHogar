import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/producto_entity.dart';
import '../providers/producto_providers.dart';

class SeleccionarProductosDialog extends ConsumerStatefulWidget {
  const SeleccionarProductosDialog({super.key});
  @override
  ConsumerState<SeleccionarProductosDialog> createState() =>
      _SeleccionarProductosState();
}

class _SeleccionarProductosState
    extends ConsumerState<SeleccionarProductosDialog> {
  String query = '';
  final seleccion = <int>{};
  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(stockLibreProvider);
    final productos = ref.watch(productosStreamProvider);
    return AlertDialog(
      title: const Text('Seleccionar productos'),
      content: SizedBox(
          width: 480,
          height: 420,
          child: Column(children: [
            TextField(
                decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search)),
                onChanged: (v) =>
                    setState(() => query = v.toLowerCase().trim())),
            const SizedBox(height: 12),
            Expanded(
                child: productos.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Text('No se pudo cargar el inventario: $e'),
                    data: (lista) {
                      final visibles = lista
                          .where((p) =>
                              p.activo &&
                              (stock[p.id] ?? 0) > 0 &&
                              p.nombre.toLowerCase().contains(query))
                          .toList();
                      if (visibles.isEmpty)
                        return const Center(
                            child: Text(
                                'No hay productos disponibles para esta búsqueda.'));
                      return ListView(
                          children: visibles
                              .map((p) => CheckboxListTile(
                                    title: Text(p.nombre),
                                    subtitle: Text(
                                        '${stock[p.id]} disponibles · ${formatCurrencyClp(p.precioFinal ?? 0)}'),
                                    value: seleccion.contains(p.id),
                                    onChanged: (v) => setState(() {
                                      if (v!) {
                                        seleccion.add(p.id!);
                                      } else {
                                        seleccion.remove(p.id);
                                      }
                                    }),
                                  ))
                              .toList());
                    })),
          ])),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: seleccion.isEmpty
                ? null
                : () => Navigator.pop<List<Producto>>(
                    context,
                    (productos.asData?.value ?? [])
                        .where((p) =>
                            seleccion.contains(p.id) && (stock[p.id] ?? 0) > 0)
                        .toList()),
            child: Text('Agregar (${seleccion.length})'))
      ],
    );
  }
}
