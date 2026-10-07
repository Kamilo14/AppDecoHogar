import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';

import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../productos/presentation/widgets/seleccionar_productos_dialog.dart';
import '../../domain/entities/encargo_detalle_entity.dart';
import '../../domain/entities/encargo_entity.dart';
import '../providers/encargo_providers.dart';
import '../../../pagos/presentation/providers/pago_providers.dart';

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
  int? compraId;
  int? costoLogistica;
  bool comprado = false;
  bool agregarAProductos = false;
  bool todasParaCliente = true;
  String? nombreTemporal;
  final cantidadCtrl = TextEditingController(text: '1');
  final cantidadCompradaCtrl = TextEditingController(text: '1');
  final precioCtrl = TextEditingController();
  final costoCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  void dispose() {
    cantidadCtrl.dispose();
    cantidadCompradaCtrl.dispose();
    precioCtrl.dispose();
    costoCtrl.dispose();
    searchCtrl.dispose();
  }
}

class _EncargoFormScreenState extends ConsumerState<EncargoFormScreen> {
  bool get _esVentaDirecta =>
      widget.esVentaDirecta ||
      (widget.encargoExistente != null &&
          widget.encargoExistente!.tipoVenta != 'Por encargo');
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _observacionesCtrl;
  final TextEditingController _montoAbonoCtrl = TextEditingController();
  int? _clienteId;
  String _estado = 'PENDIENTE';
  bool _isLoading = false;
  String _opcionPago = 'SIN_PAGO'; // 'PAGO_TOTAL', 'ABONO', 'SIN_PAGO'
  String _metodoPago = 'Efectivo';
  late final List<_DetalleInput> _detalles;

  @override
  void initState() {
    super.initState();
    final encargo = widget.encargoExistente;
    _observacionesCtrl =
        TextEditingController(text: encargo?.observaciones ?? '');
    _clienteId = encargo?.clienteId ?? widget.clienteId;
    _estado = _esVentaDirecta ? 'ENTREGADO' : (encargo?.estado ?? 'PENDIENTE');
    if (_esVentaDirecta) {
      _opcionPago = 'PAGO_TOTAL';
    }

    final productos = ref.read(productosStreamProvider).asData?.value ?? [];

    _detalles = (encargo?.detalles ??
            (_esVentaDirecta
                ? <EncargoDetalle>[]
                : [const EncargoDetalle(productoId: null, cantidad: 1)]))
        .map((detalle) {
      final item = _DetalleInput();
      item.productoId = detalle.productoId;
      item.compraId = detalle.compraId;
      item.costoLogistica = detalle.costoLogistica;
      item.comprado = detalle.comprado || encargo?.estado == 'COMPRADO';
      item.cantidadCtrl.text = detalle.cantidad.toString();
      item.cantidadCompradaCtrl.text = detalle.unidadesCompradas.toString();
      item.todasParaCliente = detalle.unidadesCompradas == detalle.cantidad;
      item.precioCtrl.text = detalle.precioUnitario?.toString() ?? '';
      item.costoCtrl.text = detalle.costoUnitario?.toString() ?? '';

      if (detalle.productoId != null) {
        final p =
            productos.where((p) => p.id == detalle.productoId).firstOrNull;
        item.searchCtrl.text = p?.nombre ?? detalle.nombreTemporal ?? '';
      } else {
        item.searchCtrl.text = detalle.nombreTemporal ?? '';
        item.nombreTemporal = detalle.nombreTemporal;
      }

      _addListeners(item);
      return item;
    }).toList();
  }

  void _addListeners(_DetalleInput item) {
    item.cantidadCtrl.addListener(_onFieldChanged);
    item.cantidadCompradaCtrl.addListener(_onFieldChanged);
    item.precioCtrl.addListener(_onFieldChanged);
    item.costoCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    _montoAbonoCtrl.dispose();
    for (final detalle in _detalles) {
      detalle.dispose();
    }
    super.dispose();
  }

  Future<void> _seleccionarProductos() async {
    final elegidos = await showDialog<List<Producto>>(
        context: context, builder: (_) => const SeleccionarProductosDialog());
    if (!mounted || elegidos == null) return;
    setState(() {
      for (final p in elegidos) {
        final existente =
            _detalles.where((d) => d.productoId == p.id).firstOrNull;
        if (existente != null) continue;
        final d = _DetalleInput();
        d.productoId = p.id;
        d.searchCtrl.text = p.nombre;
        d.precioCtrl.text = p.precioFinal?.toString() ?? '';
        d.costoCtrl.text = p.precioCompra?.toString() ?? '';
        _addListeners(d);
        _detalles.add(d);
      }
    });
  }

  void _agregarDetalle() {
    final nuevoItem = _DetalleInput();
    _addListeners(nuevoItem);
    setState(() {
      _detalles.add(nuevoItem);
      if (_estado == 'COMPRADO') _estado = 'PENDIENTE';
    });
  }

  void _eliminarDetalle(int index) {
    setState(() {
      _detalles[index].dispose();
      _detalles.removeAt(index);
      if (_estado != 'ENTREGADO') {
        _estado = _detalles.isNotEmpty && _detalles.every((d) => d.comprado)
            ? 'COMPRADO'
            : 'PENDIENTE';
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteId == null && !_esVentaDirecta) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona un cliente')));
      return;
    }

    final validInputs = _detalles
        .where((d) => d.productoId != null || d.searchCtrl.text.isNotEmpty)
        .toList();

    if (validInputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Añade al menos un producto')));
      return;
    }

    if (_esVentaDirecta) {
      final stockLibre = ref.read(stockLibreProvider);
      for (final input in validInputs) {
        if (input.productoId == null) continue;
        final cantidad = int.tryParse(input.cantidadCtrl.text) ?? 0;
        final disponible = stockLibre[input.productoId!] ?? 0;
        if (cantidad > disponible) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Stock insuficiente para ${input.searchCtrl.text}: disponibles $disponible.',
            ),
          ));
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      if (!_esVentaDirecta) {
        final productosActuales =
            ref.read(productosStreamProvider).asData?.value ?? const [];
        final nombresCreados = <String>{};
        for (final input in validInputs) {
          final nombre = input.searchCtrl.text.trim();
          final clave = nombre.toLowerCase();
          final yaExiste = productosActuales.any(
                (p) => p.activo && p.nombre.toLowerCase() == clave,
              ) ||
              nombresCreados.contains(clave);
          if (input.agregarAProductos &&
              input.productoId == null &&
              nombre.isNotEmpty &&
              !yaExiste) {
            await ref.read(saveProductoUseCaseProvider).call(
                  Producto(
                    nombre: nombre,
                    cantidadDisponible: 0,
                  ),
                );
            nombresCreados.add(clave);
          }
        }
      }

      final detallesEntidad = validInputs.map((d) {
        return EncargoDetalle(
          productoId: d.productoId,
          compraId: d.compraId,
          costoLogistica: d.costoLogistica,
          comprado: d.comprado,
          nombreTemporal:
              d.searchCtrl.text.isNotEmpty ? d.searchCtrl.text : null,
          cantidad: int.parse(d.cantidadCtrl.text),
          cantidadComprada: d.todasParaCliente || _esVentaDirecta
              ? int.parse(d.cantidadCtrl.text)
              : int.parse(d.cantidadCompradaCtrl.text),
          precioUnitario: int.tryParse(d.precioCtrl.text),
          costoUnitario: int.tryParse(d.costoCtrl.text),
        );
      }).toList();

      final encargo = Encargo(
        id: widget.encargoExistente?.id,
        clienteId: _clienteId,
        fecha: widget.encargoExistente?.fecha ?? DateTime.now(),
        estado: _estado,
        observaciones: _observacionesCtrl.text.trim().isEmpty
            ? null
            : _observacionesCtrl.text.trim(),
        activo: widget.encargoExistente?.activo ?? true,
        tipoVenta: _esVentaDirecta
            ? 'Venta directa'
            : (widget.encargoExistente?.tipoVenta ?? 'Por encargo'),
        detalles: detallesEntidad,
      );

      final registrarPago = _esVentaDirecta && _estado == 'ENTREGADO';
      if (registrarPago &&
          _opcionPago == 'ABONO' &&
          (int.tryParse(_montoAbonoCtrl.text) ?? 0) <= 0) {
        throw Exception('Ingresa un abono mayor a cero.');
      }
      await ref.read(saveEncargoUseCaseProvider).call(
            encargo,
            liquidarSaldo: registrarPago && _opcionPago == 'PAGO_TOTAL',
            montoPagoInicial: registrarPago && _opcionPago == 'ABONO'
                ? int.tryParse(_montoAbonoCtrl.text)
                : null,
            metodoPago: _metodoPago,
          );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildPagoSection({required int abonado, required int saldo}) {
    if (!_esVentaDirecta) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pago',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          if (_clienteId == null) ...[
            const Text(
              'Venta sin cliente: se registra la venta, pero no queda deuda pendiente ni abonos asociados.',
            ),
          ] else ...[
            Text('Abonos registrados: ${formatCurrencyClp(abonado)}'),
            Text('Saldo a pagar: ${formatCurrencyClp(saldo)}'),
            ...const {
              'PAGO_TOTAL': 'Pagó todo (saldo restante)',
              'ABONO': 'Abono nuevo',
              'SIN_PAGO': 'Sin pago nuevo'
            }.entries.map((opcion) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opcion.value),
                  value: _opcionPago == opcion.key,
                  onChanged: (_) =>
                      setState(() => _opcionPago = opcion.key),
                )),
            if (_opcionPago == 'ABONO') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _montoAbonoCtrl,
                decoration: const InputDecoration(
                  labelText: r'Monto que abonó ($)',
                  prefixText: r'$ ',
                  filled: true,
                  fillColor: AppColors.background,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            if (_opcionPago != 'SIN_PAGO') ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(
                    labelText: 'Método de Pago',
                    filled: true,
                    fillColor: AppColors.background),
                items: const [
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(
                      value: 'Transferencia', child: Text('Transferencia')),
                  DropdownMenuItem(
                      value: 'Débito/Crédito', child: Text('Débito/Crédito')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _metodoPago = v!),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetalleSection() => TextFormField(
        controller: _observacionesCtrl,
        decoration: const InputDecoration(
          labelText: 'Detalle / notas',
          prefixIcon: Icon(Icons.notes_rounded),
          filled: true,
          fillColor: AppColors.surface,
        ),
        maxLines: 2,
      );

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? [];
    final productos = ref.watch(productosStreamProvider).asData?.value ?? [];
    final stockLibre = ref.watch(stockLibreProvider);
    final pagos = ref.watch(pagosStreamProvider).asData?.value ?? [];
    final abonado = widget.encargoExistente?.id == null
        ? 0
        : pagos
            .where((p) => p.encargoId == widget.encargoExistente!.id)
            .fold(0, (sum, p) => sum + p.monto);
    final String titulo = _esVentaDirecta
        ? 'Venta Directa'
        : (widget.encargoExistente == null
            ? 'Nuevo Encargo'
            : 'Editar Encargo');

    int totalVenta = 0;
    for (final item in _detalles) {
      final c = int.tryParse(item.cantidadCtrl.text) ?? 0;
      final p = int.tryParse(item.precioCtrl.text) ?? 0;
      totalVenta += c * p;
    }
    final otrosEncargos = ref.watch(encargosStreamProvider).asData?.value ?? [];
    final deudaCliente = otrosEncargos
            .where((e) =>
                e.activo &&
                e.clienteId == _clienteId &&
                e.id != widget.encargoExistente?.id)
            .fold(0, (sum, e) => sum + e.totalExigible) +
        totalVenta -
        pagos
            .where((p) => p.clienteId == _clienteId)
            .fold(0, (sum, p) => sum + p.monto);
    final saldo = (totalVenta - abonado)
        .clamp(0, deudaCliente < 0 ? 0 : deudaCliente)
        .toInt();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(titulo,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
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
                  labelText:
                      _esVentaDirecta ? 'Cliente (Opcional)' : 'Cliente *',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: [
                  if (_esVentaDirecta)
                    const DropdownMenuItem(
                        value: null,
                        child: Text('Venta sin cliente registrado')),
                  ...clientes.map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.nombre))),
                ],
                onChanged: (widget.clienteId != null &&
                        widget.encargoExistente != null)
                    ? null
                    : (v) => setState(() => _clienteId = v),
                validator: (v) =>
                    (!_esVentaDirecta && v == null) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              if (!_esVentaDirecta) ...[
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
                    DropdownMenuItem(
                        value: 'PENDIENTE', child: Text('Pendiente (A traer)')),
                    DropdownMenuItem(
                        value: 'COMPRADO',
                        child: Text('Comprado (Ya en stock)')),
                    DropdownMenuItem(
                        value: 'ENTREGADO',
                        child: Text('Entregado / resuelto')),
                  ],
                  onChanged: (v) => setState(() {
                    _estado = v!;
                    if (v == 'COMPRADO' || v == 'PENDIENTE') {
                      for (final d in _detalles) {
                        d.comprado = v == 'COMPRADO';
                      }
                    }
                  }),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Productos',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.textPrimary)),
                  TextButton.icon(
                    onPressed: _esVentaDirecta
                        ? _seleccionarProductos
                        : _agregarDetalle,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(
                        _esVentaDirecta ? 'Elegir productos' : 'Añadir Item'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_detalles.isEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _esVentaDirecta
                            ? Icons.add_shopping_cart_rounded
                            : Icons.assignment_add,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _esVentaDirecta
                            ? 'Elige productos para realizar la venta.'
                            : 'Añade productos al recordatorio.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ..._detalles.asMap().entries.map((entry) {
                final idx = entry.key;
                final input = entry.value;
                final stockDisponible = input.productoId == null
                    ? null
                    : stockLibre[input.productoId!] ?? 0;

                return Container(
                  key: ObjectKey(input),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: AppColors.outline.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _esVentaDirecta
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(input.searchCtrl.text,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          )),
                                      if (stockDisponible != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '$stockDisponible disponibles',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                          ),
                                        ),
                                    ],
                                  )
                                : Autocomplete<Producto>(
                                    optionsBuilder: (textValue) {
                                      if (textValue.text.isEmpty)
                                        return const Iterable<Producto>.empty();
                                      return productos.where((p) =>
                                          p.activo &&
                                          p.nombre.toLowerCase().contains(
                                              textValue.text.toLowerCase()));
                                    },
                                    displayStringForOption: (p) => p.nombre,
                                    onSelected: (p) {
                                      setState(() {
                                        input.productoId = p.id;
                                        input.agregarAProductos = false;
                                        input.nombreTemporal = null;
                                        input.searchCtrl.text = p.nombre;
                                        if (input.comprado || _esVentaDirecta) {
                                          input.precioCtrl.text =
                                              p.precioVenta?.toString() ?? '';
                                          input.costoCtrl.text =
                                              p.precioCompra?.toString() ?? '';
                                        }
                                      });
                                    },
                                    fieldViewBuilder:
                                        (ctx, ctrl, node, onSubmitted) {
                                      if (ctrl.text.isEmpty &&
                                          input.searchCtrl.text.isNotEmpty)
                                        ctrl.text = input.searchCtrl.text;
                                      return TextFormField(
                                        controller: ctrl,
                                        focusNode: node,
                                        decoration: InputDecoration(
                                          labelText: 'Producto',
                                          filled: true,
                                          fillColor: AppColors.background,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide.none),
                                        ),
                                        onChanged: (v) => setState(() {
                                          input.searchCtrl.text = v;
                                          input.productoId = null;
                                        }),
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'Escribe un producto'
                                                : null,
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(width: 12),
                          if (input.todasParaCliente || _esVentaDirecta)
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: input.cantidadCtrl,
                                validator: (v) =>
                                    (int.tryParse(v ?? '') ?? 0) <= 0
                                        ? 'Mín. 1'
                                        : null,
                                decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                    filled: true,
                                    fillColor: AppColors.background),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.error),
                              onPressed: () => _eliminarDetalle(idx)),
                        ],
                      ),
                      if (!_esVentaDirecta &&
                          input.productoId == null &&
                          input.searchCtrl.text.trim().isNotEmpty)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Agregar también a Productos'),
                          subtitle: const Text(
                              'Crea la ficha del producto con stock 0 para completarla después.'),
                          value: input.agregarAProductos,
                          onChanged: (value) => setState(() {
                            input.agregarAProductos = value ?? false;
                          }),
                        ),
                      if (_esVentaDirecta) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (!_esVentaDirecta) ...[
                              Expanded(
                                child: TextFormField(
                                  controller: input.costoCtrl,
                                  readOnly: input.compraId != null,
                                  validator: (v) =>
                                      int.tryParse(v ?? '') == null ||
                                              int.parse(v!) < 0
                                          ? 'Ingresa costo'
                                          : null,
                                  decoration: const InputDecoration(
                                      labelText: 'Costo Unit.',
                                      prefixText: r'$ ',
                                      filled: true,
                                      fillColor: AppColors.background),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: TextFormField(
                                controller: input.precioCtrl,
                                validator: (v) =>
                                    (int.tryParse(v ?? '') ?? 0) <= 0
                                        ? 'Ingresa precio'
                                        : null,
                                decoration: const InputDecoration(
                                    labelText: 'Precio Venta',
                                    prefixText: r'$ ',
                                    filled: true,
                                    fillColor: AppColors.background),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_esVentaDirecta ? 'Total Cobro:' : 'Productos:',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                fontSize: 16)),
                        Text(
                            _esVentaDirecta
                                ? formatCurrencyClp(totalVenta)
                                : '${_detalles.length} item(s)',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (_esVentaDirecta) ...[
                const SizedBox(height: 16),
                _buildPagoSection(abonado: abonado, saldo: saldo),
              ],
              const SizedBox(height: 16),
              _buildDetalleSection(),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: _isLoading ? null : _guardar,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_esVentaDirecta ? 'FINALIZAR VENTA' : 'GUARDAR',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
