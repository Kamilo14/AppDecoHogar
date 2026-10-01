import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../productos/presentation/providers/producto_providers.dart';
import '../widgets/producto_catalogo_card.dart';
import 'compartir_catalogo_screen.dart';

class CatalogoScreen extends ConsumerStatefulWidget {
  const CatalogoScreen({super.key});

  @override
  ConsumerState<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends ConsumerState<CatalogoScreen> {
  String _searchQuery = '';
  int? _selectedCategoriaId;

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(productosStreamProvider);
    final categoriasAsync = ref.watch(categoriasStreamProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header del Catálogo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nuestro Catálogo',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lo mejor para decorar tu hogar',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de búsqueda y filtros
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: '¿Qué estás buscando?',
                          hintStyle: GoogleFonts.outfit(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.6)),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.primary, size: 22),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    categoriasAsync.when(
                      data: (categorias) => SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: const Text('Todo'),
                                selected: _selectedCategoriaId == null,
                                onSelected: (sel) =>
                                    setState(() => _selectedCategoriaId = null),
                                backgroundColor: AppColors.surface,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                labelStyle: GoogleFonts.outfit(
                                  color: _selectedCategoriaId == null
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: _selectedCategoriaId == null
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: _selectedCategoriaId == null
                                          ? AppColors.primary
                                              .withValues(alpha: 0.5)
                                          : AppColors.outline),
                                ),
                              ),
                            ),
                            ...categorias.map((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(cat.nombre),
                                    selected: _selectedCategoriaId == cat.id,
                                    onSelected: (sel) => setState(() =>
                                        _selectedCategoriaId =
                                            sel ? cat.id : null),
                                    backgroundColor: AppColors.surface,
                                    selectedColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    labelStyle: GoogleFonts.outfit(
                                      color: _selectedCategoriaId == cat.id
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: _selectedCategoriaId == cat.id
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                          color: _selectedCategoriaId == cat.id
                                              ? AppColors.primary
                                                  .withValues(alpha: 0.5)
                                              : AppColors.outline),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox(height: 40),
                      error: (_, __) => const SizedBox(height: 40),
                    ),
                  ],
                ),
              ),

              // Cuadrícula de productos
              Expanded(
                child: productosAsync.when(
                  data: (productos) {
                    final filtrados = productos.where((p) {
                      final matchesSearch = p.nombre
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                      final matchesCat = _selectedCategoriaId == null ||
                          p.categoriaId == _selectedCategoriaId;
                      return p.activo && matchesSearch && matchesCat;
                    }).toList();

                    if (filtrados.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No encontramos productos',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColors.textPrimary),
                            ),
                            Text(
                              'Intenta con otra búsqueda',
                              style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      itemCount: filtrados.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) =>
                          ProductoCatalogoCard(producto: filtrados[index]),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              // Botón Compartir
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5)),
                  ],
                ),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  onPressed: () {
                    productosAsync.whenData((list) {
                      final filtrados = list.where((p) {
                        final matchesSearch = p.nombre
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                        final matchesCat = _selectedCategoriaId == null ||
                            p.categoriaId == _selectedCategoriaId;
                        return p.activo &&
                            matchesSearch &&
                            matchesCat &&
                            p.tieneStock;
                      }).toList();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CompartirCatalogoScreen(productos: filtrados),
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Compartir Catálogo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
