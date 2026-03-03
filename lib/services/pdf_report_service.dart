// path: lib/services/pdf_report_service.dart

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';

class PdfReportService {
  static Future<void> generateAndOpenMonthlyReport({
    required List<Invoice> invoices,
    required int year,
    required String monthName,
  }) async {
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    final pdfBytes = await _generatePdfBytes(
      invoices: invoices,
      year: year,
      monthName: monthName,
      font: font,
      fontBold: fontBold,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Reporte_${monthName}_$year.pdf',
    );
  }

  static Future<Uint8List> _generatePdfBytes({
    required List<Invoice> invoices,
    required int year,
    required String monthName,
    required pw.Font font,
    required pw.Font fontBold,
  }) async {
    final pdf = pw.Document();

    final totalMonto = invoices.fold<double>(0, (sum, i) => sum + i.monto);
    final pagadoMonto = invoices
        .where((i) => i.estado == 'pagado')
        .fold<double>(0, (sum, i) => sum + i.monto);
    final vencidoMonto = invoices
        .where((i) => i.estado == 'vencido')
        .fold<double>(0, (sum, i) => sum + i.monto);
    final pendienteMonto = invoices
        .where((i) => i.estado == 'pendiente')
        .fold<double>(0, (sum, i) => sum + i.monto);

    final baseStyle = pw.TextStyle(font: font);
    final boldStyle = pw.TextStyle(font: fontBold);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          _buildHeader(monthName, year, boldStyle),
          pw.SizedBox(height: 30),
          _buildSummary(
            documentCount: invoices.length,
            totalMonto: totalMonto,
            pagadoMonto: pagadoMonto,
            vencidoMonto: vencidoMonto,
            pendienteMonto: pendienteMonto,
            baseStyle: baseStyle,
            boldStyle: boldStyle,
          ),
          pw.SizedBox(height: 30),
          if (invoices.isNotEmpty)
            _buildInvoiceTable(invoices, baseStyle, boldStyle)
          else
            pw.Center(
              child: pw.Text(
                'No hay boletas para este periodo',
                style: baseStyle.copyWith(
                  fontSize: 14,
                  color: PdfColors.grey600,
                ),
              ),
            ),
        ],
        footer: (context) => _buildFooter(context, baseStyle),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    String monthName,
    int year,
    pw.TextStyle boldStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ELECTRICAUTOMATICCHILE',
                  style: boldStyle.copyWith(
                    fontSize: 20,
                    color: PdfColor.fromHex('#F97316'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Administracion Inteligente del Suministro Electrico',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF3E0'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'REPORTE MENSUAL',
                style: boldStyle.copyWith(
                  fontSize: 12,
                  color: PdfColor.fromHex('#F97316'),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Text('$monthName $year', style: boldStyle.copyWith(fontSize: 24)),
      ],
    );
  }

  static pw.Widget _buildSummary({
    required int documentCount,
    required double totalMonto,
    required double pagadoMonto,
    required double vencidoMonto,
    required double pendienteMonto,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN',
            style: boldStyle.copyWith(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Total Boletas',
                '$documentCount',
                PdfColors.blue700,
                baseStyle,
                boldStyle,
              ),
              _buildSummaryItem(
                'Monto Total',
                _formatMonto(totalMonto),
                PdfColors.grey800,
                baseStyle,
                boldStyle,
              ),
              _buildSummaryItem(
                'Pagado',
                _formatMonto(pagadoMonto),
                PdfColors.green700,
                baseStyle,
                boldStyle,
              ),
              _buildSummaryItem(
                'Vencido',
                _formatMonto(vencidoMonto),
                PdfColors.red700,
                baseStyle,
                boldStyle,
              ),
              _buildSummaryItem(
                'Pendiente',
                _formatMonto(pendienteMonto),
                PdfColor.fromHex('#F97316'),
                baseStyle,
                boldStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    String value,
    PdfColor color,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: baseStyle.copyWith(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(value, style: boldStyle.copyWith(fontSize: 14, color: color)),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(
    List<Invoice> invoices,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETALLE DE BOLETAS',
          style: boldStyle.copyWith(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell(
                  'Periodo',
                  isHeader: true,
                  boldStyle: boldStyle,
                ),
                _buildTableCell('Fecha', isHeader: true, boldStyle: boldStyle),
                _buildTableCell('Monto', isHeader: true, boldStyle: boldStyle),
                _buildTableCell('Estado', isHeader: true, boldStyle: boldStyle),
              ],
            ),
            ...invoices.map(
              (invoice) => pw.TableRow(
                children: [
                  _buildTableCell(invoice.periodo, baseStyle: baseStyle),
                  _buildTableCell(invoice.formattedDate, baseStyle: baseStyle),
                  _buildTableCell(invoice.formattedMonto, baseStyle: baseStyle),
                  _buildStatusCell(invoice.estado, boldStyle),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextStyle? baseStyle,
    pw.TextStyle? boldStyle,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: isHeader
            ? boldStyle?.copyWith(fontSize: 10, color: PdfColors.grey800)
            : baseStyle?.copyWith(fontSize: 9, color: PdfColors.grey700),
      ),
    );
  }

  static pw.Widget _buildStatusCell(String estado, pw.TextStyle boldStyle) {
    final PdfColor color;
    final PdfColor bgColor;
    final String label;

    switch (estado.toLowerCase()) {
      case 'pagado':
        color = PdfColors.green700;
        bgColor = PdfColor.fromHex('#E8F5E9');
        label = 'PAGADO';
        break;
      case 'vencido':
        color = PdfColors.red700;
        bgColor = PdfColor.fromHex('#FFEBEE');
        label = 'VENCIDO';
        break;
      default:
        color = PdfColor.fromHex('#F97316');
        bgColor = PdfColor.fromHex('#FFF3E0');
        label = 'PENDIENTE';
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          label,
          style: boldStyle.copyWith(fontSize: 8, color: color),
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.TextStyle baseStyle) {
    final now = DateTime.now();
    final formattedDate =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado el $formattedDate',
              style: baseStyle.copyWith(fontSize: 9, color: PdfColors.grey500),
            ),
            pw.Text(
              'Pagina ${context.pageNumber} de ${context.pagesCount}',
              style: baseStyle.copyWith(fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'ELECTRICAUTOMATICCHILE - Todos los derechos reservados',
          style: baseStyle.copyWith(fontSize: 8, color: PdfColors.grey400),
        ),
      ],
    );
  }

  static String _formatMonto(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '\$$formatted';
  }
}
