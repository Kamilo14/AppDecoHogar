import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../productos/domain/entities/producto_entity.dart';
import 'package:intl/intl.dart';

class GenerarCatalogoPdfUseCase {
  Future<Uint8List> call(List<Producto> productos) async {
    final pdf = pw.Document();
    final NumberFormat formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
    final String fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

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
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text('Catálogo de Productos - $fecha', 
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', 
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
        ),
        build: (context) {
          return [
            // Banner de Bienvenida
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF5EFE6),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('DECORA TU HOGAR', 
                      style: pw.TextStyle(
                        fontSize: 28, 
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF8A6B4F),
                      )),
                    pw.SizedBox(height: 4),
                    pw.Text('Transformamos tus espacios con amor y detalle', 
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey800)),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 30),

            // Tabla de productos estilizada
            pw.TableHelper.fromTextArray(
              border: null,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFD67C52),
                borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEFE6D9), width: 0.5)),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 11),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FixedColumnWidth(80),
              },
              headers: ['Producto', 'Stock', 'Precio de Venta'],
              data: productos.map((p) => [
                p.nombre,
                p.cantidadDisponible.toString(),
                formatter.format(p.precioVenta),
              ]).toList(),
            ),
            
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text('¡Gracias por preferir nuestros productos!',
                style: pw.TextStyle(
                  fontSize: 14, 
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColor.fromInt(0xFF8A6B4F),
                )),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
