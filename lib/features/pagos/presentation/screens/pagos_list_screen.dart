import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/pago_providers.dart';
import '../widgets/pago_form_screen.dart';

class PagosListScreen extends ConsumerWidget {
  const PagosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? const [];
    final pagosAsync = ref.watch(pagosStreamProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F0E7), Color(0xFFFFFBF7)],
          ),
        ),
        child: SafeArea(
          child: pagosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (pagos) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  WarmSurfaceCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pagos',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Abonos y pagos completos con una vista más clara y ligera.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        WarmPill(
                          label: '${pagos.length} pagos registrados',
                          color: const Color(0xFF7B8B5D),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  WarmSectionHeader(title: 'Historial'),
                  const SizedBox(height: 10),
                  if (pagos.isEmpty)
                    WarmSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'Aún no hay pagos registrados',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
                  else
                    ...pagos.map(
                      (pago) {
                        final clienteNombre = clientes.firstWhere(
                          (cliente) => cliente.id == pago.clienteId,
                          orElse: () => Cliente(nombre: 'Cliente', fechaRegistro: DateTime(2000)),
                        ).nombre;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: WarmSurfaceCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => PagoFormScreen(pagoExistente: pago)),
                              );
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(clienteNombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(formatDateCl(pago.fecha)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      WarmPill(label: pago.tipo, color: const Color(0xFF7B8B5D)),
                                      WarmPill(label: pago.metodo, color: const Color(0xFFD28B63)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Text(
                                formatCurrencyClp(pago.monto),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PagoFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pago'),
      ),
    );
  }
}