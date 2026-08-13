import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../productos/presentation/widgets/producto_form_dialog.dart';
import '../../domain/entities/encargo_detalle_entity.dart';
import '../../domain/entities/encargo_entity.dart';
import '../providers/encargo_providers.dart';

class EncargoFormScreen extends ConsumerStatefulWidget {
  final Encargo? encargoExistente;
  final int? clienteId;
  final bool esVentaDirecta;

  const EncargoFormScreen({
    super.key, 
    this.encargoExistente, 
    this.clienteId,
    this.esVentaDirecta = false,
  });

  @override
  ConsumerState<EncargoFormScreen> createState() => _EncargoFormScreenState();
}

class _DetalleInput {
  int? productoId;
  String? nombreTemporal;
  final cantidadCtrl = TextEditingController(text: '1');
  final precioCtrl = TextEditingController();
  final costoCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  void dispose() {
    cantidadCtrl.dispose();
    precioCtrl.dispose();
    costoCtrl.dispose();
    searchCtrl.dispose();
  }
}

class _EncargoFormScreenState extends ConsumerState<EncargoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _observacionesCtrl;
  int? _clienteId;
  String _estado = 'PENDIENTE';
  bool _isLoading = false;
  bool _pagoInmediato = true; 
  late final List<_DetalleInput> _detalles;

  @override
  void initState() {
    super.initState();
    final encargo = widget.encargoExistente;
    _observacionesCtrl = TextEditingController(text: encargo?.observaciones ?? '');
    _clienteId = encargo?.clienteId ?? widget.clienteId;
    _estado = widget.esVentaDirecta ? 'ENTREGADO' : (encargo?.estado ?? 'PENDIENTE');
    
    final productos = ref.read(productosStreamProvider).asData?.value ?? [];

    _detalles = (encargo?.detalles ?? [const EncargoDetalle(productoId: null, cantidad: 1)])
        .map((detalle) {
          final item = _DetalleInput();
          item.productoId = detalle.productoId;
          item.cantidadCtrl.text = detalle.cantidad.toString();
          item.precioCtrl.text = detalle.precioUnitario?.toString() ?? '';
          item.costoCtrl.text = detalle.costoUnitario?.toString() ?? '';
          
          if (detalle.productoId != null) {
            final p = productos.where((p) => p.id == detalle.productoId).firstOrNull;
            item.searchCtrl.text = p?.nombre ?? detalle.nombreTemporal ?? '';
          } else {
            item.searchCtrl.text = detalle.nombreTemporal ?? '';
            item.nombreTemporal = detalle.nombreTemporal;
          }
          
          _addListeners(item);
          return item;
        })
        .toList();
  }

  void _addListeners(_DetalleInput item) {
    item.cantidadCtrl.addListener(_onFieldChanged);
    item.precioCtrl.addListener(_onFieldChanged);
    item.costoCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    for (final detalle in _detalles) {
      detalle.dispose();
    }
    super.dispose();
  }

  void _agregarDetalle() {
    final nuevoItem = _DetalleInput();
    _addListeners(nuevoItem);
    setState(() => _detalles.add(nuevoItem));
  }

  void _eliminarDetalle(int index) {
    setState(() {
      _detalles[index].dispose();
      _detalles.removeAt(index);
    });
  }

  Future<void> _crearProductoRapido(_DetalleInput input) async {
    final nuevoProd = await showDialog<Producto>(
      context: context,
      builder: (_) => ProductoFormDialog(
        productoExistente: Producto(
          nombre: input.searchCtrl.text,
          precioCompra: int.tryParse(input.costoCtrl.text),
          precioVenta: int.tryParse(input.precioCtrl.text),
          cantidadDisponible: 0,
        ),
      ),
    );

    if (nuevoProd != null && nuevoProd.id != null) {
      setState(() {
        input.productoId = nuevoProd.id;
        input.nombreTemporal = null;
        input.searchCtrl.text = nuevoProd.nombre;
        input.costoCtrl.text = nuevoProd.precioCompra?.toString() ?? input.costoCtrl.text;
        input.precioCtrl.text = nuevoProd.precioVenta?.toString() ?? input.precioCtrl.text;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_clienteId == null && !widget.esVentaDirecta) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un cliente')));
      return;
    }

    final validInputs = _detalles.where((d) => d.productoId != null || d.searchCtrl.text.isNotEmpty).toList();

    if (validInputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añade al menos un producto')));
      return;
    }

    setState(() => _isLoading = true);

    final detallesEntidad = validInputs.map((d) {
      return EncargoDetalle(
        productoId: d.productoId,
        nombreTemporal: d.productoId == null ? d.searchCtrl.text : null,
        cantidad: int.parse(d.cantidadCtrl.text),
        precioUnitario: int.tryParse(d.precioCtrl.text),
        costoUnitario: int.tryParse(d.costoCtrl.text),
      );
    }).toList();

    final encargo = Encargo(
      id: widget.encargoExistente?.id,
      clienteId: _clienteId,
      fecha: widget.encargoExistente?.fecha ?? DateTime.now(),
      estado: _estado,
      observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
      activo: widget.encargoExistente?.activo ?? true,
      tipoVenta: widget.esVentaDirecta ? 'Venta directa' : (widget.encargoExistente?.tipoVenta ?? 'Por encargo'),
      detalles: detallesEntidad,
    );

    try {
      await ref.read(saveEncargoUseCaseProvider).call(encargo);
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
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? [];
    final productos = ref.watch(productosStreamProvider).asData?.value ?? [];
    final String titulo = widget.esVentaDirecta ? 'Venta Directa' : (widget.encargoExistente == null ? 'Nuevo Encargo' : 'Editar Encargo');

    int totalVenta = 0;
    int totalCosto = 0;
    for (final item in _detalles) {
      final c = int.tryParse(item.cantidadCtrl.text) ?? 0;
      final p = int.tryParse(item.precioCtrl.text) ?? 0;
      final co = int.tryParse(item.costoCtrl.text) ?? 0;
      totalVenta += c * p;
      totalCosto += c * co;
    }
    final int ganancia = totalVenta - totalCosto;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titulo, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            DropdownButtonFormField<int?>(
              value: _clienteId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: widget.esVentaDirecta ? 'Cliente (Opcional)' : 'Cliente *', 
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: [
                if (widget.esVentaDirecta) const DropdownMenuItem(value: null, child: Text('Venta sin cliente registrado')),
                ...clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))),
              ],
              onChanged: (widget.clienteId != null && widget.encargoExistente != null) ? null : (v) => setState(() => _clienteId = v),
              validator: (v) => (!widget.esVentaDirecta && v == null) ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            
            if (widget.esVentaDirecta) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    _PagoOption(
                      label: 'Pago total ahora',
                      isSelected: _pagoInmediato,
                      onTap: () => setState(() => _pagoInmediato = true),
                      color: AppColors.primary,
                    ),
                    _PagoOption(
                      label: 'Va abonando',
                      isSelected: !_pagoInmediato,
                      onTap: () => setState(() => _pagoInmediato = false),
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              DropdownButtonFormField<String>(
                value: _estado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Estado del pedido',
                  prefixIcon: Icon(Icons.info_outline_rounded),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: const [
                  DropdownMenuItem(value: 'PENDIENTE', child: Text('Pendiente (A traer)')),
                  DropdownMenuItem(value: 'COMPRADO', child: Text('Comprado (Ya en stock)')),
                  DropdownMenuItem(value: 'ENTREGADO', child: Text('Entregado al cliente')),
                ],
                onChanged: (v) => setState(() => _estado = v!),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _observacionesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas', 
                prefixIcon: Icon(Icons.notes_rounded),
                filled: true,
                fillColor: AppColors.surface,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Productos', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                TextButton.icon(
                  onPressed: _agregarDetalle, 
                  icon: const Icon(Icons.add_circle_outline_rounded), 
                  label: const Text('Añadir Item'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._detalles.asMap().entries.map((entry) {
              final idx = entry.key;
              final input = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Autocomplete<Producto>(
                            optionsBuilder: (textValue) {
                              if (textValue.text.isEmpty) return const Iterable<Producto>.empty();
                              return productos.where((p) => p.activo && p.nombre.toLowerCase().contains(textValue.text.toLowerCase()));
                            },
                            displayStringForOption: (p) => p.nombre,
                            onSelected: (p) {
                              setState(() {
                                input.productoId = p.id;
                                input.nombreTemporal = null;
                                input.searchCtrl.text = p.nombre;
                                input.precioCtrl.text = p.precioVenta?.toString() ?? '';
                                input.costoCtrl.text = p.precioCompra?.toString() ?? '';
                              });
                            },
                            fieldViewBuilder: (ctx, ctrl, node, onSubmitted) {
                              if (ctrl.text.isEmpty && input.searchCtrl.text.isNotEmpty) ctrl.text = input.searchCtrl.text;
                              return TextFormField(
                                controller: ctrl,
                                focusNode: node,
                                decoration: InputDecoration(
                                  labelText: 'Producto',
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  suffixIcon: (ctrl.text.isNotEmpty && !productos.any((p) => p.nombre.toLowerCase() == ctrl.text.toLowerCase()))
                                    ? IconButton(icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary), onPressed: () => _crearProductoRapido(input))
                                    : null,
                                ),
                                onChanged: (v) => input.searchCtrl.text = v,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: input.cantidadCtrl,
                            decoration: const InputDecoration(labelText: 'Cant.', filled: true, fillColor: AppColors.background),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error), onPressed: () => _eliminarDetalle(idx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (!widget.esVentaDirecta) ...[
                          Expanded(
                            child: TextFormField(
                              controller: input.costoCtrl,
                              decoration: const InputDecoration(labelText: 'Costo Unit.', prefixText: r'$ ', filled: true, fillColor: AppColors.background),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: TextFormField(
                            controller: input.precioCtrl,
                            decoration: const InputDecoration(labelText: 'Precio Venta', prefixText: r'$ ', filled: true, fillColor: AppColors.background),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Cobro:', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 16)),
                      Text(formatCurrencyClp(totalVenta), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary)),
                    ],
                  ),
                  if (!widget.esVentaDirecta) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ganancia Estimada:', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text(formatCurrencyClp(ganancia), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: ganancia >= 0 ? AppColors.secondary : AppColors.error)),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: _isLoading ? null : _guardar,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : Text(widget.esVentaDirecta ? 'FINALIZAR VENTA' : 'GUARDAR', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PagoOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _PagoOption({required this.label, required this.isSelected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textSecondary)),
          ),
        ),
      ),
    );
  }
}
