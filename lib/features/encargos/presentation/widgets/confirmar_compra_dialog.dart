import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../gastos/presentation/providers/viaje_providers.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../domain/entities/encargo_entity.dart';
import '../../domain/entities/encargo_detalle_entity.dart';
import '../providers/encargo_providers.dart';

class ConfirmarCompraDialog extends ConsumerStatefulWidget {
  final Encargo encargo;
  const ConfirmarCompraDialog({super.key, required this.encargo});

  @override
  ConsumerState<ConfirmarCompraDialog> createState() => _ConfirmarCompraDialogState();
}

class _ConfirmarCompraDialogState extends ConsumerState<ConfirmarCompraDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _viajeId;
  late final List<TextEditingController> _costoCtrls;
  late final List<TextEditingController> _precioCtrls;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _costoCtrls = widget.encargo.detalles.map((d) => TextEditingController()).toList();
    _precioCtrls = widget.encargo.detalles.map((d) {
      final productos = ref.read(productosStreamProvider).asData?.value ?? [];
      final p = productos.where((prod) => prod.id == d.productoId).firstOrNull;
      return TextEditingController(text: p?.precioVenta?.toString() ?? '');
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _costoCtrls) {
      c.dispose();
    }
    for (var p in _precioCtrls) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _viajeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un viaje e ingresa todos los precios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nuevosDetalles = <EncargoDetalle>[];
      for (int i = 0; i < widget.encargo.detalles.length; i++) {
        final d = widget.encargo.detalles[i];
        final costo = int.parse(_costoCtrls[i].text);
        final precio = int.parse(_precioCtrls[i].text);

        nuevosDetalles.add(d.copyWith(
          costoUnitario: costo,
          precioUnitario: precio,
        ));

        final productos = ref.read(productosStreamProvider).asData?.value ?? [];
        final p = productos.firstWhere((prod) => prod.id == d.productoId);
        
        await ref.read(saveProductoUseCaseProvider).call(p.copyWith(
          precioCompra: costo,
          precioVenta: precio,
          cantidadDisponible: p.cantidadDisponible + d.cantidad,
          viajeId: _viajeId,
        ));
      }

      final encargoComprado = widget.encargo.copyWith(
        estado: 'COMPRADO',
        detalles: nuevosDetalles,
      );

      await ref.read(saveEncargoUseCaseProvider).call(encargoComprado);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viajesAsync = ref.watch(viajesStreamProvider);
    final productos = ref.watch(productosStreamProvider).asData?.value ?? [];

    return AlertDialog(
      title: const Text('Registrar Compra'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              viajesAsync.when(
                data: (lista) => DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(labelText: 'Viaje de compra', prefixIcon: Icon(Icons.flight_takeoff)),
                  items: lista.map((v) => DropdownMenuItem(value: v.id, child: Text(v.destino))).toList(),
                  onChanged: (v) => setState(() => _viajeId = v),
                  validator: (v) => v == null ? 'Selecciona un viaje' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error al cargar viajes'),
              ),
              const SizedBox(height: 20),
              ...widget.encargo.detalles.asMap().entries.map((entry) {
                final idx = entry.key;
                final det = entry.value;
                final p = productos.where((prod) => prod.id == det.productoId).firstOrNull;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p?.nombre ?? 'Producto', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Cantidad: ${det.cantidad}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costoCtrls[idx],
                              decoration: const InputDecoration(labelText: 'Costo Compra'),
                              keyboardType: TextInputType.number,
                              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _precioCtrls[idx],
                              decoration: const InputDecoration(labelText: 'Precio Venta'),
                              keyboardType: TextInputType.number,
                              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _isLoading ? null : _guardar, child: const Text('Confirmar y Cargar Stock')),
      ],
    );
  }
}
