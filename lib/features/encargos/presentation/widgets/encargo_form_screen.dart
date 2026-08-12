import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../productos/presentation/widgets/producto_form_dialog.dart';
import '../../domain/entities/encargo_detalle_entity.dart';
import '../../domain/entities/encargo_entity.dart';
import '../providers/encargo_providers.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../../core/theme/app_colors.dart';

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

  void _onFieldChanged() {
    setState(() {}); // Actualiza los totales en tiempo real
  }

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un cliente')));
      return;
    }

    final validInputs = _detalles.where((d) => d.productoId != null || d.searchCtrl.text.isNotEmpty).toList();

    if (validInputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes agregar al menos un producto')));
      return;
    }

    if (_estado != 'PENDIENTE') {
      final tieneTemporales = validInputs.any((d) => d.productoId == null);
      if (tieneTemporales) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Para pasar a COMPRADO, todos los productos deben estar vinculados (usa el botón +)')),
        );
        return;
      }
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
    final String titulo = widget.esVentaDirecta ? 'Nueva Venta Directa' : (widget.encargoExistente == null ? 'Nuevo Encargo' : 'Editar Encargo');

    // Cálculos de totales en vivo
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
                labelText: widget.esVentaDirecta ? 'Cliente (Opcional)' : 'Cliente', 
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: [
                if (widget.esVentaDirecta) const DropdownMenuItem(value: null, child: Text('Sin cliente (Venta rápida)')),
                ...clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))),
              ],
              onChanged: (widget.clienteId != null && widget.encargoExistente != null) ? null : (v) => setState(() => _clienteId = v),
              validator: (v) => (!widget.esVentaDirecta && v == null) ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            
            if (!widget.esVentaDirecta) ...[
              DropdownButtonFormField<String>(
                value: _estado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Estado del pedido',
                  prefixIcon: Icon(Icons.info_outline),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: const [
                  DropdownMenuItem(value: 'PENDIENTE', child: Text('PENDIENTE (Solo registro)')),
                  DropdownMenuItem(value: 'COMPRADO', child: Text('COMPRADO (Ya se adquirió)')),
                  DropdownMenuItem(value: 'ENTREGADO', child: Text('ENTREGADO (Al cliente)')),
                  DropdownMenuItem(value: 'FINALIZADO', child: Text('FINALIZADO (Pagado)')),
                ],
                onChanged: (v) => setState(() => _estado = v!),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _observacionesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas / Observaciones', 
                prefixIcon: Icon(Icons.notes),
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
                  icon: const Icon(Icons.add_circle_outline), 
                  label: const Text('Añadir Item'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._detalles.asMap().entries.map((entry) {
              final idx = entry.key;
              final input = entry.value;
              final bool esTemporal = input.productoId == null;

              return WarmSurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Autocomplete<Producto>(
                            optionsBuilder: (textValue) {
                              if (textValue.text.isEmpty) return const Iterable<Producto>.empty();
                              return productos.where((p) => 
                                p.activo && p.nombre.toLowerCase().contains(textValue.text.toLowerCase())
                              );
                            },
                            displayStringForOption: (p) => p.nombre,
                            onSelected: (p) {
                              setState(() {
                                input.productoId = p.id;
                                input.nombreTemporal = null;
                                input.searchCtrl.text = p.nombre;
                                if (_estado != 'PENDIENTE') {
                                  input.costoCtrl.text = p.precioCompra?.toString() ?? input.costoCtrl.text;
                                  input.precioCtrl.text = p.precioVenta?.toString() ?? input.precioCtrl.text;
                                }
                              });
                            },
                            fieldViewBuilder: (ctx, ctrl, node, onSubmitted) {
                              if (ctrl.text.isEmpty && input.searchCtrl.text.isNotEmpty) {
                                ctrl.text = input.searchCtrl.text;
                              }
                              return TextFormField(
                                controller: ctrl,
                                focusNode: node,
                                decoration: InputDecoration(
                                  labelText: _estado == 'PENDIENTE' ? '¿Qué necesita el cliente?' : 'Seleccionar Producto',
                                  hintText: 'Ej: Frutilla',
                                  suffixIcon: (ctrl.text.isNotEmpty && !productos.any((p) => p.nombre.toLowerCase() == ctrl.text.toLowerCase()))
                                    ? IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                        onPressed: () => _crearProductoRapido(input),
                                        tooltip: 'Convertir a producto real',
                                      )
                                    : (esTemporal && _estado != 'PENDIENTE' ? const Icon(Icons.warning_amber_rounded, color: Colors.orange) : null),
                                ),
                                onChanged: (v) {
                                  input.searchCtrl.text = v;
                                  if (input.productoId != null) {
                                    final p = productos.where((prod) => prod.id == input.productoId).firstOrNull;
                                    if (p != null && p.nombre.toLowerCase() != v.toLowerCase()) {
                                      input.productoId = null;
                                    }
                                  }
                                },
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Escribe el nombre';
                                  if (_estado != 'PENDIENTE' && input.productoId == null) return '¡Vincula un producto!';
                                  return null;
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: input.cantidadCtrl,
                            decoration: const InputDecoration(labelText: 'Cant.'),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Error' : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _eliminarDetalle(idx),
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        ),
                      ],
                    ),
                    if (_estado != 'PENDIENTE') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: input.costoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Costo Unit.', 
                                prefixText: r'$ ',
                                hintText: '0',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => (_estado != 'PENDIENTE' && (v == null || v.isEmpty)) ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: input.precioCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Precio Venta', 
                                prefixText: r'$ ',
                                hintText: '0',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => (_estado != 'PENDIENTE' && (v == null || v.isEmpty)) ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
            
            // Resumen de Totales en Vivo
            if (_estado != 'PENDIENTE') ...[
              const SizedBox(height: 24),
              WarmSurfaceCard(
                color: AppColors.primary.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Venta:', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text(formatCurrencyClp(totalVenta), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ganancia Estimada:', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text(
                          formatCurrencyClp(ganancia), 
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, 
                            fontSize: 18, 
                            color: ganancia >= 0 ? AppColors.secondary : AppColors.error
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isLoading ? null : _guardar,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(
                      widget.esVentaDirecta 
                        ? 'REGISTRAR VENTA' 
                        : (_estado == 'PENDIENTE' ? 'GUARDAR RECORDATORIO' : 'GUARDAR Y FIJAR PRECIOS'),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
