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
import '../../domain/entities/encargo_entity.dart';
import '../providers/encargo_providers.dart';
import '../widgets/encargo_form_screen.dart';

class EncargoDetailScreen extends ConsumerStatefulWidget {
  final Encargo encargo;

  const EncargoDetailScreen({super.key, required this.encargo});

  @override
  ConsumerState<EncargoDetailScreen> createState() => _EncargoDetailScreenState();
}

class _EncargoDetailScreenState extends ConsumerState<EncargoDetailScreen> with SingleTickerProviderStateMixin {
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
      final updated = list.firstWhere((e) => e.id == _currentEncargo.id, orElse: () => _currentEncargo);
      if (updated != _currentEncargo) {
        setState(() => _currentEncargo = updated);
      }
    });

    final id = _currentEncargo.id!;
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? const [];
    final productos = ref.watch(productosStreamProvider).asData?.value ?? const [];
    final pagos = ref.watch(pagosStreamProvider).asData?.value ?? const [];
    
    final cliente = clientes.firstWhere(
      (c) => c.id == _currentEncargo.clienteId,
      orElse: () => Cliente(nombre: 'Cliente', fechaRegistro: DateTime(2000)),
    );

    // Trazabilidad: Pagos asociados a este encargo
    final pagosEncargo = pagos.where((p) => p.clienteId == _currentEncargo.clienteId && p.concepto != null && p.concepto!.contains('ENC-${_currentEncargo.id}')).toList();
    // Alternativamente, si no hay asociación directa por ID en la tabla pagos todavía, sumamos lo abonado por el cliente en general para este pedido
    final totalAbonado = pagosEncargo.fold(0, (sum, p) => sum + p.monto);

    return Scaffold(
      appBar: AppBar(
        title: Text('ENC-${_currentEncargo.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EncargoFormScreen(encargoExistente: _currentEncargo),
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
                WarmClienteAvatar(nombre: cliente.nombre, radius: 28, tieneDeuda: false),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nombre,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      if (cliente.telefono != null)
                        Text(cliente.telefono!, style: Theme.of(context).textTheme.bodyMedium),
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
                          WarmInfoRow(label: 'Estado', value: _currentEncargo.estado),
                          WarmInfoRow(label: 'Fecha', value: formatDateCl(_currentEncargo.fecha)),
                          const Divider(height: 24),
                          WarmInfoRow(
                            label: 'Total Encargo',
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
                            value: formatCurrencyClp(_currentEncargo.total - totalAbonado),
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
                      orElse: () => Producto(nombre: 'Producto', precioCompra: 0, precioVenta: 0),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WarmSurfaceCard(
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Color(0xFFBFA995)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prod.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
                                  Text('Cantidad: ${detalle.cantidad}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            if (detalle.precioUnitario != null)
                              Text(formatCurrencyClp(detalle.subtotal), style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Tab Pagos
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: pagosEncargo.isEmpty
                      ? [const Center(child: Text('No hay abonos registrados para este encargo'))]
                      : pagosEncargo.map((pago) {
                          return ListTile(
                            title: Text(pago.tipo),
                            subtitle: Text(formatDateCl(pago.fecha)),
                            trailing: Text(formatCurrencyClp(pago.monto), style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                ),
                // Tab Notas
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    WarmSurfaceCard(
                      child: Text(_currentEncargo.observaciones ?? 'Sin observaciones.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
