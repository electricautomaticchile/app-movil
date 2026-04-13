import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'consumo_service.dart';

class ExportService {
  /// Export consumption history as CSV string and share
  static Future<void> exportCSV(List<HistorialPunto> data, String clienteName) async {
    final buffer = StringBuffer();
    buffer.writeln('Periodo,Consumo (kWh),Costo (CLP)');
    for (final punto in data) {
      buffer.writeln('${punto.periodo},${punto.energiaTotal.toStringAsFixed(2)},${punto.costoTotal.toStringAsFixed(0)}');
    }

    final bytes = Uint8List.fromList(buffer.toString().codeUnits);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'consumo-$clienteName.csv',
    );
  }

  /// Export consumption history as PDF and share
  static Future<void> exportPDF(List<HistorialPunto> data, String clienteName) async {
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final pdf = pw.Document();

    final totalKwh = data.fold<double>(0, (s, p) => s + p.energiaTotal);
    final totalCosto = data.fold<double>(0, (s, p) => s + p.costoTotal);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text('Historial de Consumo',
              style: pw.TextStyle(font: fontBold, fontSize: 20)),
          pw.SizedBox(height: 8),
          pw.Text('Cliente: $clienteName',
              style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Periodo', fontBold),
                  _cell('kWh', fontBold),
                  _cell('Costo', fontBold),
                ],
              ),
              ...data.map((p) => pw.TableRow(children: [
                _cell(p.periodo, font),
                _cell(p.energiaTotal.toStringAsFixed(2), font),
                _cell('\$${p.costoTotal.toStringAsFixed(0)}', font),
              ])),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _cell('TOTAL', fontBold),
                  _cell(totalKwh.toStringAsFixed(2), fontBold),
                  _cell('\$${totalCosto.toStringAsFixed(0)}', fontBold),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'consumo-$clienteName.pdf');
  }

  static pw.Widget _cell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }
}
