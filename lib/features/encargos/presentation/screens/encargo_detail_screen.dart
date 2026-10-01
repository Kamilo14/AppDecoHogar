import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';

import '../../../pagos/presentation/providers/pago_providers.dart';
import '../../../pagos/domain/entities/pago_entity.dart';
import '../../domain/entities/encargo_entity.dart';
import '../providers/encargo_providers.dart';
import '../widgets/encargo_form_screen.dart';

import '../../../../core/theme/app_colors.dart';

class EncargoDetailScreen extends ConsumerStatefulWidget {
  final Encargo encargo;

  const EncargoDetailScreen({super.key, required this.encargo});

  @override
  ConsumerState<EncargoDetailScreen> createState() =>
      _EncargoDetailScreenState();
}

class _EncargoDetailScreenState extends ConsumerState<EncargoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Encargo _currentEncargo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentEncargo = widget.encargo;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final encargosAsync = ref.watch(encargosStreamProvider);
    encargosAsync.whenData((list) {
      final updated = list.firstWhere((e) => e.id == _currentEncargo.id,
          orElse: () => _currentEncargo);
      if (updated != _currentEncargo) {
        _currentEncargo = updated;
      }
    });

    final clientes =
        ref.watch(clientesStreamProvider).asData?.value ?? const [];
    final productos =
        ref.watch(productosStreamProvider).asData?.value ?? const [];
    final pagos = ref.watch(pagosStreamProvider).asData?.value ?? const [];
    final esVenta = _currentEncargo.tipoVenta != 'Por encargo';

    final cliente = clientes.firstWhere(
      (c) => c.id == _currentEncargo.clienteId,
      orElse: () => Cliente(nombre: 'Cliente', fechaRegistro: DateTime(2000)),
    );

    // Los pagos se relacionan por ID, independientemente de su descripción.
    final List<Pago> pagosEncargo = esVenta
        ? pagos.where((p) => p.encargoId == _currentEncargo.id).toList()
        : const <Pago>[];
    final totalAbonado = pagosEncargo.fold(0, (sum, p) => sum + p.monto);
    final deudaGlobal = _currentEncargo.clienteId == null
        ? 0
        : ref.watch(deudaClienteProvider(_currentEncargo.clienteId!));
    final saldoPendiente = (_currentEncargo.totalExigible - totalAbonado)
        .clamp(0, deudaGlobal < 0 ? 0 : deudaGlobal)
        .toInt();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('ENC-${_currentEncargo.id}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EncargoFormScreen(encargoExistente: _currentEncargo),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  WarmClienteAvatar(
                      nombre: cliente.nombre, radius: 28, tieneDeuda: false),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        if (cliente.telefono != null)
                          Text(cliente.telefono!,
                              style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  WarmStatusChip(estado: _currentEncargo.estado),
                ],
              ),
            ),
            WarmTabBar(
              controller: _tabController,
              tabs: [
                const Tab(text: 'Detalle'),
                Tab(text: 'Productos (${_currentEncargo.detalles.length})'),
                const Tab(text: 'Pagos'),
                const Tab(text: 'Notas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Detalle
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      WarmSurfaceCard(
                        child: Column(
                          children: [
                            WarmInfoRow(
                                label: 'Estado', value: _currentEncargo.estado),
                            WarmInfoRow(
                                label: 'Fecha',
                                value: formatDateCl(_currentEncargo.fecha)),
                            const Divider(height: 24),
                            if (esVenta) ...[
                              WarmInfoRow(
                                label: 'Total Venta',
                                value: formatCurrencyClp(_currentEncargo.total),
                                isBoldValue: true,
                              ),
                              WarmInfoRow(
                                label: 'Total Abonado',
                                value: formatCurrencyClp(totalAbonado),
                                isBoldValue: true,
                              ),
                              WarmInfoRow(
                                label: 'Pendiente',
                                value: formatCurrencyClp(saldoPendiente),
                                isBoldValue: true,
                              ),
                            ] else
                              WarmInfoRow(
                                label: 'Productos solicitados',
                                value: '${_currentEncargo.detalles.length}',
                                isBoldValue: true,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Tab Productos
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: _currentEncargo.detalles.map((detalle) {
                      final prod = productos.firstWhere(
                        (p) => p.id == detalle.productoId,
                        orElse: () => Producto(
                            nombre: detalle.nombreTemporal ?? 'Producto',
                            precioCompra: 0,
                            precioVenta: 0),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: WarmSurfaceCard(
                          child: Row(
                            children: [
                              Icon(
                                  detalle.comprado
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: const Color(0xFFBFA995)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(prod.nombre,
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14)),
                                    if (detalle.unidadesCompradas !=
                                        detalle.cantidad)
                                      Text(
                                          'Compradas: ${detalle.unidadesCompradas} · Para inventario: ${detalle.unidadesCompradas - detalle.cantidad}'),
                                    Text(
                                        'Cantidad para el cliente: ${detalle.cantidad}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                              ),
                              if (esVenta && detalle.precioUnitario != null)
                                Text(formatCurrencyClp(detalle.subtotal),
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // Tab Pagos
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: !esVenta
                        ? [
                            const Center(
                              child: Text(
                                  'Los encargos son solo recordatorios. Registra la venta aparte cuando corresponda.'),
                            )
                          ]
                        : pagosEncargo.isEmpty
                            ? [
                                const Center(
                                    child: Text(
                                        'No hay abonos registrados para este encargo'))
                              ]
                            : pagosEncargo.map((pago) {
                                return ListTile(
                                  title: Text(pago.tipo),
                                  subtitle: Text(formatDateCl(pago.fecha)),
                                  trailing: Text(formatCurrencyClp(pago.monto),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                  ),
                  // Tab Notas
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      WarmSurfaceCard(
                        child: Text(_currentEncargo.observaciones ??
                            'Sin observaciones.'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (_currentEncargo.estado == 'PENDIENTE') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EncargoFormScreen(
                              encargoExistente: _currentEncargo),
                        ));
                      },
                      icon: const Icon(Icons.shopping_cart_checkout_rounded,
                          color: AppColors.primary, size: 20),
                      label: Text(
                        'REGISTRAR COMPRA',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () => _mostrarDialogoEntregaYPago(context),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 20),
                      label: Text(
                        'ENTREGAR',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ] else if (_currentEncargo.estado == 'COMPRADO') ...[
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () => _mostrarDialogoEntregaYPago(context),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 20),
                      label: Text(
                        'ENTREGAR AL CLIENTE',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.secondary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Encargo Entregado',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEntregaYPago(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EncargoFormScreen(
        encargoExistente: _currentEncargo.copyWith(estado: 'ENTREGADO'),
      ),
    ));
  }
}
