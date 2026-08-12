import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../productos/presentation/widgets/producto_form_dialog.dart';
import '../providers/viaje_providers.dart';

enum ModoEntrada { existente, nuevo }

class CompraViajeDialog extends ConsumerStatefulWidget {
  final int viajeId;
  const CompraViajeDialog({super.key, required this.viajeId});

  @override
  ConsumerState<CompraViajeDialog> createState() => _CompraViajeDialogState();
}

class _CompraViajeDialogState extends ConsumerState<CompraViajeDialog> {
  final _formKey = GlobalKey<FormState>();
  ModoEntrada _modo = ModoEntrada.existente;
  int? _productoId;
  final _cantidadCtrl = TextEditingController(text: '1');
  final _searchCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirFormularioNuevo() async {
    final nuevoProd = await showDialog<Producto>(
      context: context,
      builder: (_) => ProductoFormDialog(
        productoExistente: Producto(
          nombre: '',
          precioCompra: 0,
          precioVenta: 0,
          cantidadDisponible: 0,
          viajeId: widget.viajeId,
        ),
      ),
    );

    if (nuevoProd != null && nuevoProd.id != null) {
      setState(() {
        _productoId = nuevoProd.id;
        _modo = ModoEntrada.existente; // Cambiamos a existente para mostrar el producto creado
        _searchCtrl.text = nuevoProd.nombre;
      });
    }
  }

  Future<void> _guardar() async {
    if (_modo == ModoEntrada.existente && _productoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un producto')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final productos = ref.read(productosStreamProvider).asData?.value ?? [];
      final producto = productos.firstWhere((p) => p.id == _productoId);
      
      final productoActualizado = producto.copyWith(
        cantidadDisponible: producto.cantidadDisponible + int.parse(_cantidadCtrl.text),
        viajeId: widget.viajeId,
      );

      await ref.read(saveProductoUseCaseProvider).call(productoActualizado);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = ref.watch(productosStreamProvider).asData?.value ?? [];

    return AlertDialog(
      title: Text('Cargar Mercadería', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de Modo: Existente o Nuevo
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ModoEntrada>(
                      title: const Text('Existente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      value: ModoEntrada.existente,
                      groupValue: _modo,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _modo = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ModoEntrada>(
                      title: const Text('Crear Nuevo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      value: ModoEntrada.nuevo,
                      groupValue: _modo,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _modo = val!);
                        _abrirFormularioNuevo();
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              if (_modo == ModoEntrada.existente)
                Autocomplete<Producto>(
                  optionsBuilder: (textValue) {
                    if (textValue.text.isEmpty) return const Iterable<Producto>.empty();
                    return productos.where((p) => 
                      p.activo && p.nombre.toLowerCase().contains(textValue.text.toLowerCase())
                    );
                  },
                  displayStringForOption: (p) => p.nombre,
                  onSelected: (p) {
                    setState(() {
                      _productoId = p.id;
                      _searchCtrl.text = p.nombre;
                    });
                  },
                  fieldViewBuilder: (ctx, ctrl, node, onSubmitted) {
                    if (ctrl.text.isEmpty && _searchCtrl.text.isNotEmpty) {
                      ctrl.text = _searchCtrl.text;
                    }
                    return TextFormField(
                      controller: ctrl,
                      focusNode: node,
                      decoration: const InputDecoration(
                        labelText: 'Buscar producto...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              
              if (_modo == ModoEntrada.nuevo)
                OutlinedButton.icon(
                  onPressed: _abrirFormularioNuevo,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Abrir Formulario Nuevo'),
                ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _cantidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cantidad comprada hoy',
                  prefixIcon: Icon(Icons.add_box_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Cantidad inválida';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _isLoading ? null : _guardar, 
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Text('Sumar al Stock'),
        ),
      ],
    );
  }
}
