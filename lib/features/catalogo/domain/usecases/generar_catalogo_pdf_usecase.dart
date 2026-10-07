import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../productos/domain/entities/producto_entity.dart';

class GenerarCatalogoPdfUseCase {
  static const _rosaSuave = PdfColor.fromInt(0xFFFFEEF4);
  static const _rosaPrincipal = PdfColor.fromInt(0xFFD95D89);
  static const _ciruela = PdfColor.fromInt(0xFF71334E);
  static const _lilaSuave = PdfColor.fromInt(0xFFF4ECF7);

  Future<Uint8List> call(List<Producto> productos) async {
    final pdf = pw.Document();
    final productosDisponibles =
        productos.where((producto) => producto.tieneStock).toList();
    final formatter =
        NumberFormat.currency(locale: 'es_CL', symbol: r'$', decimalDigits: 0);
    final fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final fotos = await _cargarFotos(productosDisponibles);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Text(
            'Catálogo de productos · $fecha',
            style: const pw.TextStyle(color: _ciruela, fontSize: 10),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'DECORA TU HOGAR · @rincondepulguita · Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(color: _ciruela, fontSize: 9),
          ),
        ),
        build: (context) => [
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            decoration: const pw.BoxDecoration(
              color: _rosaSuave,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'DECORA TU HOGAR',
                  style: pw.TextStyle(
                    fontSize: 27,
                    fontWeight: pw.FontWeight.bold,
                    color: _ciruela,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Detalles bonitos para hacer especial cada rincón',
                  style: const pw.TextStyle(
                      fontSize: 12, color: _rosaPrincipal),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                  ),
                  child: pw.Text(
                    'Instagram  @rincondepulguita',
                    style: pw.TextStyle(fontSize: 10, color: _ciruela),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 22),
          pw.Text('Colección disponible',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: _ciruela)),
          pw.SizedBox(height: 12),
          if (productosDisponibles.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: const pw.BoxDecoration(
                color: _lilaSuave,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Center(
                  child: pw.Text('Pronto tendremos novedades para ti.',
                      style: const pw.TextStyle(color: _ciruela))),
            )
          else
            pw.Wrap(
              spacing: 16,
              runSpacing: 16,
              children: productosDisponibles
                  .map((producto) =>
                      _productoCard(producto, formatter, fotos[producto.id]))
                  .toList(),
            ),
          pw.SizedBox(height: 28),
          pw.Center(
            child: pw.Text(
              'Gracias por preferir nuestros productos · Síguenos en @rincondepulguita',
              style: const pw.TextStyle(
                fontSize: 13,
                fontStyle: pw.FontStyle.italic,
                color: _ciruela,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<Map<int?, pw.MemoryImage>> _cargarFotos(
      List<Producto> productos) async {
    final fotos = <int?, pw.MemoryImage>{};
    for (final producto in productos) {
      final ruta = producto.fotoPath;
      if (ruta == null || ruta.isEmpty || ruta.startsWith('http')) continue;

      final archivo = File(ruta);
      if (!await archivo.exists()) continue;
      try {
        fotos[producto.id] = pw.MemoryImage(await archivo.readAsBytes());
      } on FileSystemException {
        // Una imagen inaccesible no debe impedir compartir el catálogo.
      }
    }
    return fotos;
  }

  pw.Widget _productoCard(
    Producto producto,
    NumberFormat formatter,
    pw.MemoryImage? foto,
  ) {
    return pw.Container(
      width: 257,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: _lilaSuave, width: 1.2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 148,
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              color: _lilaSuave,
              borderRadius:
                  pw.BorderRadius.vertical(top: pw.Radius.circular(11)),
            ),
            child: foto == null
                ? pw.Center(
                    child: pw.Text(
                      'Foto próximamente',
                      style:
                          const pw.TextStyle(color: _ciruela, fontSize: 11),
                    ),
                  )
                : pw.ClipRRect(
                    horizontalRadius: 11,
                    verticalRadius: 11,
                    child: pw.Image(foto, fit: pw.BoxFit.cover),
                  ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(13),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(
                    color: _ciruela,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (producto.descripcion?.trim().isNotEmpty ?? false) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    producto.descripcion!.trim(),
                    maxLines: 2,
                    overflow: pw.TextOverflow.clip,
                    style: const pw.TextStyle(
                        color: PdfColors.grey700, fontSize: 9),
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 9, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    color: _rosaSuave,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(7)),
                  ),
                  child: pw.Text(
                    formatter.format(producto.precioFinal ?? 0),
                    style: pw.TextStyle(
                      color: _rosaPrincipal,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
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
