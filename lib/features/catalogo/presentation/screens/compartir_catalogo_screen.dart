import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    if (widget.productos.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay productos para compartir')),
        );
      }
      return;
    }
    setState(() => _compartiendo = true);
    try {
      final bytes = await GenerarCatalogoPdfUseCase().call(widget.productos);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/catalogo_deco_hogar.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: 'catalogo.pdf')],
        text: subject ?? 'Catálogo DECORA TU HOGAR',
        subject: subject,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo compartir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final mesAnio = '${meses[now.month - 1]} ${now.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Compartir Catálogo')),
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    WarmSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'DECORA TU HOGAR',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Catálogo de productos — $mesAnio',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF2C221E).withValues(alpha: 0.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(height: 24),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.productos.take(4).length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder: (context, idx) {
                              final p = widget.productos[idx];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFE6D9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      width: double.infinity,
                                      child: const Icon(Icons.storefront_outlined, color: Color(0xFFBFA995)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                  Text(
                                    formatCurrencyClp(p.precioVenta),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (widget.productos.length > 4) ...[
                            const SizedBox(height: 12),
                            Text(
                              '+ ${widget.productos.length - 4} productos más',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C221E).withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Compartir por:',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ShareOption(
                          icon: Icons.chat_bubble_outline,
                          label: 'WhatsApp',
                          onTap: _compartiendo ? null : () => _compartirCatalogo(subject: 'Catálogo por WhatsApp'),
                        ),
                        _ShareOption(
                          icon: Icons.camera_alt_outlined,
                          label: 'Instagram',
                          onTap: _compartiendo ? null : () => _compartirCatalogo(subject: 'Catálogo'),
                        ),
                        _ShareOption(
                          icon: Icons.email_outlined,
                          label: 'Correo',
                          onTap: _compartiendo ? null : () => _compartirCatalogo(subject: 'Catálogo DECORA TU HOGAR'),
                        ),
                        _ShareOption(
                          icon: Icons.more_horiz,
                          label: 'Más',
                          onTap: _compartiendo ? null : () => _compartirCatalogo(),
                        ),
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
                        onPressed: _compartiendo ? null : () => _compartirCatalogo(subject: 'Catálogo (PDF)'),
                        child: const Text('Guardar imagen'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _compartiendo ? null : () => _compartirCatalogo(),
                        child: _compartiendo
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Compartir catálogo'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ShareOption({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEFE6D9)),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
