import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../providers/encargo_providers.dart';
import '../widgets/encargo_form_screen.dart';
import '../../domain/entities/encargo_entity.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
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
    final clientes =
        ref.watch(clientesStreamProvider).asData?.value ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: encargosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (encargos) {
            final filtrados = encargos.where((e) {
              if (_filtroEstado == null) return e.activo;
              return e.activo &&
                  e.estado.toUpperCase() == _filtroEstado!.toUpperCase();
            }).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Encargos',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outline),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune_rounded,
                            color: AppColors.textPrimary, size: 22),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('Todos', null),
                      _buildFilterChip('Pendiente', 'PENDIENTE'),
                      _buildFilterChip('Comprado', 'COMPRADO'),
                      _buildFilterChip('Entregado', 'ENTREGADO'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (filtrados.isEmpty)
                  _buildEmptyState()
                else
                  ...filtrados.map((encargo) {
                    final cliente = clientes.firstWhere(
                      (c) => c.id == encargo.clienteId,
                      orElse: () => Cliente(
                          nombre: 'Cliente Desconocido',
                          fechaRegistro: DateTime.now()),
                    );
                    return _EncargoCard(
                        encargo: encargo, clienteNombre: cliente.nombre);
                  }),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EncargoFormScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? estado) {
    final isSelected = _filtroEstado == estado;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _filtroEstado = estado);
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.secondary.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.outfit(
          color: isSelected ? AppColors.secondary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.5)
                  : AppColors.outline),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No hay encargos en este estado',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncargoCard extends ConsumerWidget {
  final Encargo encargo;
  final String clienteNombre;

  const _EncargoCard({required this.encargo, required this.clienteNombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosStreamProvider).asData?.value ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EncargoDetailScreen(encargo: encargo),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ENC-${encargo.id}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      formatCurrencyClp(encargo.total),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  clienteNombre,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...encargo.detalles.map((d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Icon(
                            d.comprado
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(d.nombreTemporal ??
                                productos
                                    .where((p) => p.id == d.productoId)
                                    .firstOrNull
                                    ?.nombre ??
                                'Producto')),
                        Text('${d.cantidad}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                    )),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WarmStatusChip(estado: encargo.estado),
                    Text(
                      formatDateCl(encargo.fecha),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
