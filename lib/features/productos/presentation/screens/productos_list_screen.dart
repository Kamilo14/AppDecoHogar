import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../domain/entities/categoria_entity.dart';
import '../../domain/entities/producto_entity.dart';
import '../providers/producto_providers.dart';
import '../widgets/categoria_form_dialog.dart';
import '../widgets/producto_form_dialog.dart';
import 'producto_detail_screen.dart';

class ProductosListScreen extends ConsumerWidget {
  const ProductosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(productoSearchProvider);
    final categoriaId = ref.watch(productoCategoriaFiltroProvider);
    final productosAsync = ref.watch(productosFiltradosProvider);
    final categoriasAsync = ref.watch(categoriasStreamProvider);
    final categorias = categoriasAsync.asData?.value ?? const <Categoria>[];

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
          child: productosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (productos) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Productos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        icon: const Icon(Icons.category_outlined),
                        onPressed: () => _showCategoriasManager(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  SearchBar(
                    hintText: 'Buscar productos...',
                    leading: const Icon(Icons.search, color: Color(0xFFBFA995)),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: const WidgetStatePropertyAll(Color(0xFFEFE6D9)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    textStyle: WidgetStatePropertyAll(GoogleFonts.outfit(fontSize: 14)),
                    trailing: [
                      if (query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ref.read(productoSearchProvider.notifier).state = '',
                        ),
                    ],
                    onChanged: (value) => ref.read(productoSearchProvider.notifier).state = value,
                  ),
                  const SizedBox(height: 16),
                  // Filter chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Todos'),
                            selected: categoriaId == null,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(productoCategoriaFiltroProvider.notifier).state = null;
                              }
                            },
                          ),
                        ),
                        ...categorias.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat.nombre),
                              selected: categoriaId == cat.id,
                              onSelected: (selected) {
                                ref.read(productoCategoriaFiltroProvider.notifier).state = selected ? cat.id : null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (productos.isEmpty)
                    _EmptyProducts(query: query, categoriaId: categoriaId)
                  else
                    ...productos.map(
                      (producto) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ProductoTile(
                          producto: producto,
                          categoriaNombre: _categoriaNombre(categorias, producto.categoriaId),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ProductoFormDialog(),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  String _categoriaNombre(List<Categoria> categorias, int? categoriaId) {
    if (categoriaId == null) return 'Sin categoría';
    return categorias.firstWhere(
      (categoria) => categoria.id == categoriaId,
      orElse: () => const Categoria(nombre: 'Sin categoría'),
    ).nombre;
  }

  Future<void> _showCategoriasManager(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Consumer(
              builder: (context, ref, _) {
                final categoriasAsync = ref.watch(categoriasStreamProvider);
                return categoriasAsync.when(
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Error: $error')),
                  ),
                  data: (categorias) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categorías',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              FilledButton.icon(
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => const CategoriaFormDialog(),
                                  );
                                },
                                style: FilledButton.styleFrom(minimumSize: const Size(100, 40)),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Nueva'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: categorias.isEmpty
                                ? const Center(
                                    child: Text('Todavía no hay categorías creadas.'),
                                  )
                                : ListView.separated(
                                    itemCount: categorias.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final categoria = categorias[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.label_outline),
                                        title: Text(categoria.nombre),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => CategoriaFormDialog(
                                                categoriaExistente: categoria,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProductoTile extends StatelessWidget {
  final Producto producto;
  final String categoriaNombre;

  const _ProductoTile({
    required this.producto,
    required this.categoriaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return WarmSurfaceCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductoDetailScreen(producto: producto),
          ),
        );
      },
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFEFE6D9),
              child: producto.fotoPath != null && producto.fotoPath!.isNotEmpty
                  ? Image.network(producto.fotoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Color(0xFFBFA995)))
                  : const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFFBFA995),
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  producto.nombre,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF2C221E)),
                ),
                const SizedBox(height: 2),
                Text(
                  categoriaNombre,
                  style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF2C221E).withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrencyClp(producto.precioVenta),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      'Stock: ${producto.cantidadDisponible}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFF2C221E).withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFFBFA995), size: 20),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final String query;
  final int? categoriaId;

  const _EmptyProducts({required this.query, required this.categoriaId});

  @override
  Widget build(BuildContext context) {
    return WarmSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 72, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              query.isEmpty && categoriaId == null ? 'Aún no hay productos' : 'Sin resultados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el botón + para agregar tu primer producto',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}