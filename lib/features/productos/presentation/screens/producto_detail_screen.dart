import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/categoria_entity.dart';
import '../../domain/entities/producto_entity.dart';
import '../providers/producto_providers.dart';
import '../widgets/producto_form_dialog.dart';

class ProductoDetailScreen extends ConsumerStatefulWidget {
  final Producto producto;

  const ProductoDetailScreen({super.key, required this.producto});

  @override
  ConsumerState<ProductoDetailScreen> createState() => _ProductoDetailScreenState();
}

class _ProductoDetailScreenState extends ConsumerState<ProductoDetailScreen> {
  late Producto _producto;

  @override
  void initState() {
    super.initState();
    _producto = widget.producto;
  }

  Future<void> _editarProducto() async {
    final actualizado = await showDialog<Producto>(
      context: context,
      builder: (_) => ProductoFormDialog(productoExistente: _producto),
    );
    if (actualizado != null && mounted) {
      setState(() => _producto = actualizado);
    }
  }

  Future<void> _marcarAgotado() async {
    final actualizado = _producto.copyWith(cantidadDisponible: 0);
    await ref.read(saveProductoUseCaseProvider).call(actualizado);
    setState(() => _producto = actualizado);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasStreamProvider).asData?.value ?? const <Categoria>[];
    final categoriaNombre = categorias.firstWhere(
      (categoria) => categoria.id == _producto.categoriaId,
      orElse: () => const Categoria(nombre: 'Sin categoría'),
    ).nombre;

    final tieneStock = _producto.tieneStock;
    
    // Blindaje de nulabilidad para cálculos
    final int cost = _producto.costoReal ?? 0;
    final int margin = _producto.margenReal ?? 0;
    
    final marginPercent = cost > 0
        ? ((margin / cost) * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        title: Text(_producto.nombre),
        actions: [
          IconButton(
            onPressed: _editarProducto,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: const Color(0xFFEFE6D9),
                    child: _producto.fotoPath != null && _producto.fotoPath!.isNotEmpty
                        ? Image.network(_producto.fotoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Color(0xFFBFA995)))
                        : const Icon(Icons.storefront_outlined, size: 60, color: Color(0xFFBFA995)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _producto.nombre,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tieneStock ? const Color(0xFFEFF5EC) : const Color(0xFFFDECE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tieneStock ? 'Disponible' : 'Agotado',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: tieneStock ? const Color(0xFF6E7E52) : const Color(0xFFD67C52),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  categoriaNombre,
                  style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF2C221E).withAlpha(150), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                
                // Muestra el PRECIO FINAL (Base + Comisión) manejando nulos
                Text(
                  formatCurrencyClp(_producto.precioFinal),
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary),
                ),
                if (_producto.comisionViaje > 0)
                  Text(
                    'P. Base: ${formatCurrencyClp(_producto.precioVenta)} + Comisión: ${formatCurrencyClp(_producto.comisionViaje)}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                  ),

                const SizedBox(height: 24),
                Text(
                  'Descripción',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF2C2C2C)),
                ),
                const SizedBox(height: 6),
                Text(
                  _producto.descripcion ?? 'Sin descripción adicional.',
                  style: GoogleFonts.outfit(fontSize: 14, height: 1.4, color: const Color(0xFF2C221E).withAlpha(180)),
                ),
                const SizedBox(height: 24),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: [
                    _DetailStatBox(label: 'Stock actual', value: '${_producto.cantidadDisponible} un.'),
                    _DetailStatBox(label: 'Costo Compra', value: formatCurrencyClp(_producto.precioCompra)),
                    _DetailStatBox(label: 'Costo Logística', value: formatCurrencyClp(_producto.comisionViaje)),
                    _DetailStatBox(label: 'Utilidad Real', value: '${formatCurrencyClp(_producto.margenReal)} ($marginPercent%)'),
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
                    onPressed: _editarProducto,
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _marcarAgotado,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD67C52),
                      side: const BorderSide(color: Color(0xFFD67C52), width: 1.5),
                    ),
                    child: const Text('Marcar agotado'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStatBox extends StatelessWidget {
  final String label;
  final String value;

  const _DetailStatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFE6D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF2C221E).withAlpha(128), fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF2C221E), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
