import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasStreamProvider).asData?.value ?? const <Categoria>[];
    final categoriaNombre = categorias.firstWhere(
      (categoria) => categoria.id == _producto.categoriaId,
      orElse: () => const Categoria(nombre: 'Sin categoría'),
    ).nombre;

    final tieneStock = _producto.tieneStock;
    final int cost = _producto.costoReal ?? 0;
    final int margin = _producto.margenReal ?? 0;
    final marginPercent = cost > 0 ? ((margin / cost) * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_producto.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(onPressed: _editarProducto, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Imagen del Producto
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _producto.fotoPath != null && _producto.fotoPath!.isNotEmpty
                  ? Image.network(_producto.fotoPath!, fit: BoxFit.cover)
                  : Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(height: 24),
          
          // Nombre y Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_producto.nombre, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tieneStock ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tieneStock ? 'Disponible' : 'Agotado',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: tieneStock ? AppColors.success : AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(categoriaNombre, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),

          // Precio Final
          Text('Precio Final', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Text(formatCurrencyClp(_producto.precioFinal), style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary)),
          
          const SizedBox(height: 32),
          Text('Información de Negocio', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatDetail(label: 'Stock Actual', value: '${_producto.cantidadDisponible} un.', color: AppColors.secondary),
              _StatDetail(label: 'Margen Real', value: '$marginPercent%', color: AppColors.tertiary),
              _StatDetail(label: 'Costo Compra', value: formatCurrencyClp(_producto.precioCompra ?? 0), color: AppColors.textSecondary),
              _StatDetail(label: 'Precio Base', value: formatCurrencyClp(_producto.precioVenta ?? 0), color: AppColors.textSecondary),
            ],
          ),
          
          const SizedBox(height: 32),
          Text('Descripción', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            child: Text(
              _producto.descripcion ?? 'Sin descripción adicional.',
              style: GoogleFonts.outfit(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _StatDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatDetail({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
