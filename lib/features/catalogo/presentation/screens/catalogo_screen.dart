import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
          child: Column(
            children: [
              // Header del Catálogo
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nuestro Catálogo',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                        const Icon(Icons.auto_awesome, color: Color(0xFFD67C52), size: 24),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lo mejor para decorar tu hogar',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF2C221E).withAlpha(150),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de búsqueda y filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    SearchBar(
                      hintText: '¿Qué estás buscando?',
                      leading: const Icon(Icons.search, color: Color(0xFFBFA995)),
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: const WidgetStatePropertyAll(Color(0xFFEFE6D9)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),
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
                                onSelected: (sel) => setState(() => _selectedCategoriaId = null),
                              ),
                            ),
                            ...categorias.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat.nombre),
                                selected: _selectedCategoriaId == cat.id,
                                onSelected: (sel) => setState(() => _selectedCategoriaId = sel ? cat.id : null),
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
                      final matchesSearch = p.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
                      final matchesCat = _selectedCategoriaId == null || p.categoriaId == _selectedCategoriaId;
                      return p.activo && matchesSearch && matchesCat;
                    }).toList();

                    if (filtrados.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_outlined, size: 64, color: Color(0xFFBFA995)),
                            const SizedBox(height: 16),
                            Text(
                              'No encontramos productos',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            Text(
                              'Intenta con otra búsqueda',
                              style: GoogleFonts.outfit(color: const Color(0xFF2C221E).withAlpha(128)),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: filtrados.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) => ProductoCatalogoCard(producto: filtrados[index]),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              // Botón Compartir
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(top: BorderSide(color: Color(0xFFEFE6D9))),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    productosAsync.whenData((list) {
                      final filtrados = list.where((p) {
                        final matchesSearch = p.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
                        final matchesCat = _selectedCategoriaId == null || p.categoriaId == _selectedCategoriaId;
                        return p.activo && matchesSearch && matchesCat && p.tieneStock;
                      }).toList();
                      
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CompartirCatalogoScreen(productos: filtrados),
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Preparar para compartir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
