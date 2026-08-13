import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../productos/domain/entities/producto_entity.dart';
import '../../domain/usecases/generar_catalogo_pdf_usecase.dart';

class CompartirCatalogoScreen extends StatefulWidget {
  final List<Producto> productos;

  const CompartirCatalogoScreen({super.key, required this.productos});

  @override
  State<CompartirCatalogoScreen> createState() => _CompartirCatalogoScreenState();
}

class _CompartirCatalogoScreenState extends State<CompartirCatalogoScreen> {
  bool _compartiendo = false;

  Future<void> _compartirCatalogo({String? subject}) async {
    if (widget.productos.isEmpty) return;
    setState(() => _compartiendo = true);
    try {
      final bytes = await GenerarCatalogoPdfUseCase().call(widget.productos);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/catalogo_deco_hogar.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: 'catalogo.pdf')],
        text: subject ?? 'Catálogo DECORA TU HOGAR',
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Preparar para Compartir', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                WarmSurfaceCard(
                  child: Column(
                    children: [
                      Text('VISTA PREVIA DEL PDF', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Text('DECORA TU HOGAR', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18)),
                            const Divider(height: 32),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.productos.take(4).length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
                              itemBuilder: (context, i) => Container(
                                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Enviar por:', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ShareIcon(icon: Icons.chat_bubble_outline_rounded, label: 'WhatsApp', onTap: () => _compartirCatalogo()),
                    _ShareIcon(icon: Icons.camera_alt_outlined, label: 'Instagram', onTap: () => _compartirCatalogo()),
                    _ShareIcon(icon: Icons.email_outlined, label: 'Correo', onTap: () => _compartirCatalogo()),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
              onPressed: _compartiendo ? null : () => _compartirCatalogo(),
              icon: const Icon(Icons.share_rounded),
              label: Text(_compartiendo ? 'Generando PDF...' : 'Compartir Catálogo', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ShareIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.outline)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
