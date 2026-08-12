import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../productos/domain/entities/producto_entity.dart';

class ProductoCatalogoCard extends StatelessWidget {
  final Producto producto;
  const ProductoCatalogoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return WarmSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEFE6D9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: producto.fotoPath != null && producto.fotoPath!.isNotEmpty
                    ? (producto.fotoPath!.startsWith('http')
                        ? Image.network(producto.fotoPath!, fit: BoxFit.cover)
                        : Image.file(File(producto.fotoPath!), fit: BoxFit.cover))
                    : const Icon(Icons.storefront_outlined, size: 40, color: Color(0xFFBFA995)),
              ),
            ),
          ),
          // Info del producto
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFF2C221E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Muestra el PRECIO FINAL (Base + Comisión de Viaje)
                  Text(
                    formatCurrencyClp(producto.precioFinal),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (producto.comisionViaje > 0)
                    Text(
                      'Incluye comisión logística',
                      style: TextStyle(fontSize: 9, color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
