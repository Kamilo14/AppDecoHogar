import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: productosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (productos) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Productos',
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
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.category_rounded, color: AppColors.textPrimary, size: 22),
                        onPressed: () => _showCategoriasManager(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Buscador
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => ref.read(productoSearchProvider.notifier).state = v,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filtros de Categoría
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(ref, 'Todos', null, categoriaId == null),
                      ...categorias.map((cat) => _buildFilterChip(ref, cat.nombre, cat.id, categoriaId == cat.id)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (productos.isEmpty)
                  _buildEmptyState()
                else
                  ...productos.map((producto) {
                    final catNombre = categorias.firstWhere((c) => c.id == producto.categoriaId, orElse: () => const Categoria(nombre: 'Sin categoría')).nombre;
                    return _ProductoTile(producto: producto, categoriaNombre: catNombre);
                  }),
                const SizedBox(height: 80),
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
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ProductoFormDialog(),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, int? id, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) ref.read(productoCategoriaFiltroProvider.notifier).state = id;
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: GoogleFonts.outfit(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outline),
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
            Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No hay productos disponibles', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showCategoriasManager(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const CategoriaFormDialog(),
    );
  }
}

class _ProductoTile extends StatelessWidget {
  final Producto producto;
  final String categoriaNombre;

  const _ProductoTile({required this.producto, required this.categoriaNombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductoDetailScreen(producto: producto),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColors.background,
                    child: producto.fotoPath != null && producto.fotoPath!.isNotEmpty
                        ? Image.network(producto.fotoPath!, fit: BoxFit.cover)
                        : Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                      Text(categoriaNombre, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatCurrencyClp(producto.precioVenta ?? 0), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                    Text('Stock: ${producto.cantidadDisponible}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
