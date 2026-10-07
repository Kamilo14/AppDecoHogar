import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../domain/entities/cliente_entity.dart';
import '../providers/cliente_providers.dart';
import '../../../pagos/presentation/providers/pago_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../../../pagos/presentation/widgets/pago_form_screen.dart';
import '../../../encargos/presentation/widgets/encargo_form_screen.dart';
import '../../../encargos/presentation/screens/encargo_detail_screen.dart';
import '../widgets/cliente_form_dialog.dart';

class ClienteDetailScreen extends ConsumerStatefulWidget {
  final Cliente cliente;

  const ClienteDetailScreen({super.key, required this.cliente});

  @override
  ConsumerState<ClienteDetailScreen> createState() =>
      _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends ConsumerState<ClienteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Cliente _currentCliente;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentCliente = widget.cliente;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(clientesStreamProvider);
    clientAsync.whenData((list) {
      final updated = list.firstWhere((c) => c.id == _currentCliente.id,
          orElse: () => _currentCliente);
      if (updated != _currentCliente) {
        setState(() => _currentCliente = updated);
      }
    });

    final id = _currentCliente.id!;
    final debt = ref.watch(deudaClienteProvider(id));
    final hasDebt = debt > 0;
    final isCredit = debt < 0;

    final encargos =
        ref.watch(encargosStreamProvider).asData?.value ?? const [];
    final pagos = ref.watch(pagosStreamProvider).asData?.value ?? const [];
    final productos =
        ref.watch(productosStreamProvider).asData?.value ?? const [];

    final clienteEncargos =
        encargos.where((e) => e.clienteId == id && e.activo).toList();
    final clientePagos = pagos.where((p) => p.clienteId == id).toList();

    final totalEncargado =
        clienteEncargos.fold<int>(0, (sum, e) => sum + e.total);
    final totalPagado = clientePagos.fold<int>(0, (sum, p) => sum + p.monto);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Ficha Cliente'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) =>
                      ClienteFormDialog(clienteExistente: _currentCliente),
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
                      nombre: _currentCliente.nombre,
                      radius: 34,
                      tieneDeuda: hasDebt),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentCliente.nombre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900),
                              ),
                            ),
                            WarmPill(
                              label: hasDebt
                                  ? 'Con Deuda'
                                  : (isCredit ? 'A Favor' : 'Al día'),
                              color: hasDebt
                                  ? const Color(0xFFD67C52)
                                  : const Color(0xFF6E7E52),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (_currentCliente.telefono != null)
                          Text(_currentCliente.telefono!,
                              style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            WarmTabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Encargos'),
                Tab(text: 'Pagos'),
                Tab(text: 'Notas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Resumen
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text('Deuda actual',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      WarmSurfaceCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(isCredit ? 'Saldo a favor' : 'Deuda neta',
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700)),
                                Text(
                                  isCredit
                                      ? '+${formatCurrencyClp(debt.abs())}'
                                      : formatCurrencyClp(debt),
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: hasDebt
                                        ? const Color(0xFFD67C52)
                                        : const Color(0xFF6E7E52),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            WarmInfoRow(
                                label: 'Total encargado',
                                value: formatCurrencyClp(totalEncargado)),
                            WarmInfoRow(
                                label: 'Total abonado',
                                value: formatCurrencyClp(totalPagado)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Tab Encargos (Mejorado con detalles de productos)
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: clienteEncargos.isEmpty
                        ? [
                            const Center(
                                child: Text('No hay movimientos registrados'))
                          ]
                        : clienteEncargos.map((encargo) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: WarmSurfaceCard(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => EncargoDetailScreen(
                                          encargo: encargo)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ENC-${encargo.correlativoCliente}', // Numeración local
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF8A6B4F)),
                                        ),
                                        Row(
                                          children: [
                                            if (encargo.tipoVenta != 'Por encargo') ...[
                                              WarmPagoStatusChip(
                                                  estadoPago: ref
                                                      .watch(resumenPagoEncargoProvider(encargo))
                                                      .estadoPago),
                                              const SizedBox(width: 6),
                                            ],
                                            WarmStatusChip(estado: encargo.estado),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Listado de productos comprados en este encargo
                                    ...encargo.detalles.map((d) {
                                      final p = productos
                                          .where(
                                              (prod) => prod.id == d.productoId)
                                          .firstOrNull;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.check_circle_outline,
                                                size: 12,
                                                color: Colors.blueGrey),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${p?.nombre ?? "Producto"} x${d.cantidad}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Text(formatCurrencyClp(d.subtotal),
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      );
                                    }),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(formatDateCl(encargo.fecha),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                        Text(
                                            'Total: ${formatCurrencyClp(encargo.total)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                  // Tab Pagos
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: clientePagos.isEmpty
                        ? [
                            const Center(
                                child: Text('No hay abonos registrados'))
                          ]
                        : clientePagos.map((pago) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: WarmSurfaceCard(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(pago.tipo,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800)),
                                  subtitle: Text(
                                      '${formatDateCl(pago.fecha)} · ${pago.metodo}'),
                                  trailing: Text(
                                    formatCurrencyClp(pago.monto),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                  // Tab Notas
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      WarmSurfaceCard(
                        child: Text(_currentCliente.observaciones ??
                            'Sin notas adicionales.'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                border: const Border(top: BorderSide(color: Color(0xFFEFE6D9))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => PagoFormScreen(clienteId: id)),
                      ),
                      child: const Text('Registrar pago'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => EncargoFormScreen(clienteId: id)),
                      ),
                      child: const Text('Nuevo encargo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
