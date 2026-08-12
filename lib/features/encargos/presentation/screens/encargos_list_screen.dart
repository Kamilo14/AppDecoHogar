import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../providers/encargo_providers.dart';
import '../widgets/encargo_form_screen.dart';
import 'encargo_detail_screen.dart';

class EncargosListScreen extends ConsumerStatefulWidget {
  const EncargosListScreen({super.key});

  @override
  ConsumerState<EncargosListScreen> createState() => _EncargosListScreenState();
}

class _EncargosListScreenState extends ConsumerState<EncargosListScreen> {
  String? _filtroEstado; // null = Todos, PENDIENTE, COMPRADO, ENTREGADO

  @override
  Widget build(BuildContext context) {
    final encargosAsync = ref.watch(encargosStreamProvider);
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? const [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EFE6), Color(0xFFFFFDF9)],
          ),
        ),
        child: SafeArea(
          child: encargosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (encargos) {
              final filtrados = encargos.where((e) {
                if (_filtroEstado == null) return e.activo;
                return e.activo && e.estado.toUpperCase() == _filtroEstado!.toUpperCase();
              }).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Encargos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Todos'),
                            selected: _filtroEstado == null,
                            onSelected: (selected) {
                              if (selected) setState(() => _filtroEstado = null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Pendiente'),
                            selected: _filtroEstado == 'PENDIENTE',
                            onSelected: (selected) {
                              if (selected) setState(() => _filtroEstado = 'PENDIENTE');
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('En producción'),
                            selected: _filtroEstado == 'COMPRADO',
                            onSelected: (selected) {
                              if (selected) setState(() => _filtroEstado = 'COMPRADO');
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Entregado'),
                            selected: _filtroEstado == 'ENTREGADO',
                            onSelected: (selected) {
                              if (selected) setState(() => _filtroEstado = 'ENTREGADO');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filtrados.isEmpty)
                    WarmSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Text(
                            'Aún no hay encargos en este estado',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    )
                  else
                    ...filtrados.map((encargo) {
                      final clienteNombre = clientes.firstWhere(
                        (cliente) => cliente.id == encargo.clienteId,
                        orElse: () => Cliente(nombre: 'Cliente', fechaRegistro: DateTime(2000)),
                      ).nombre;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: WarmSurfaceCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EncargoDetailScreen(encargo: encargo),
                              ),
                            );
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ENC-${encargo.id}',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF2C221E).withValues(alpha: 0.5)),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatCurrencyClp(encargo.total),
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFF2C221E)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      clienteNombre,
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF2C221E)),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        WarmStatusChip(estado: encargo.estado),
                                        Text(
                                          formatDateCl(encargo.fecha),
                                          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF2C221E).withValues(alpha: 0.4)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EncargoFormScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}