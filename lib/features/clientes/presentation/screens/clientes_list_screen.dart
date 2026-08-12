import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pagos/presentation/providers/pago_providers.dart';
import '../../domain/entities/cliente_entity.dart';
import '../providers/cliente_providers.dart';
import '../widgets/cliente_form_dialog.dart';
import 'cliente_detail_screen.dart';

class ClientesListScreen extends ConsumerWidget {
  const ClientesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(clienteSearchProvider);
    final clientesAsync = ref.watch(clientesFiltradosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: clientesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (clientes) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Clientes',
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
                                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 22),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Buscador Estilizado
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: TextField(
                            onChanged: (v) => ref.read(clienteSearchProvider.notifier).state = v,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre...',
                              hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary.withOpacity(0.6)),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              suffixIcon: query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 20),
                                      onPressed: () => ref.read(clienteSearchProvider.notifier).state = '',
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                if (clientes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyClients(query: query),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ClienteTile(cliente: clientes[index]),
                        ),
                        childCount: clientes.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ClienteFormDialog(),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _ClienteTile extends ConsumerWidget {
  final Cliente cliente;
  const _ClienteTile({required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debt = cliente.id == null ? 0 : ref.watch(deudaClienteProvider(cliente.id!));
    final hasDebt = debt > 0;
    final isCredit = debt < 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClienteDetailScreen(cliente: cliente),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                WarmClienteAvatar(nombre: cliente.nombre, tieneDeuda: hasDebt, radius: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nombre,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCredit 
                          ? 'Saldo a favor' 
                          : (hasDebt ? 'Saldo pendiente' : 'Sin deudas'),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrencyClp(debt.abs()),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isCredit 
                            ? AppColors.secondary 
                            : (hasDebt ? AppColors.error : AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isCredit ? AppColors.secondary : (hasDebt ? AppColors.error : AppColors.textSecondary)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCredit ? 'Crédito' : (hasDebt ? 'Deuda' : 'Al día'),
                        style: GoogleFonts.outfit(
                          color: isCredit ? AppColors.secondary : (hasDebt ? AppColors.error : AppColors.textSecondary),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
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

class _EmptyClients extends StatelessWidget {
  final String query;

  const _EmptyClients({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline_rounded, size: 64, color: AppColors.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            query.isEmpty ? 'Tu lista está vacía' : 'No encontramos resultados',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty ? 'Empieza agregando a tus clientes habituales.' : 'Intenta buscar con otro nombre.',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
