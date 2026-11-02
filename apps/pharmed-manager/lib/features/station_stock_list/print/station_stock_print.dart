// [SWREQ-MGR-STATIONSTOCK-002] [IEC 62304 §5.5]
//
// İstasyon stok listesi çıktısı: üstte ortalanmış istasyon adı, altında
// Id | Barkod | Malzeme | Maks | Miktar | Rezerve | Kalan | Dolum kolonları.
// Her satırın altında, Id + Barkod kolonlarının genişliğinde Code128 barkod
// basılır (dolum sırasında el terminaliyle okutulabilsin diye).
//
// Kalan ve Dolum servisten geldiği gibi basılır (negatif olabilir).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/core.dart';

/// Kolon genişlikleri (flex). İlk ikisinin toplamı barkod genişliğini belirler.
const _flexes = <int>[6, 12, 40, 5, 5, 6, 5, 5];

/// Sayısal kolonlar (Maks..Dolum) sağa yaslanır.
const _numericFrom = 3;

const _fontSize = 7.0;
const _barcodeHeight = 22.0;

/// Seçili stokları sistem yazdırma diyaloğuna gönderir.
Future<void> printStationStockList({
  required BuildContext context,
  required String? stationName,
  required List<StationStock> stocks,
}) async {
  final l10n = context.l10n;
  final title = stationName ?? '-';
  final headers = [
    l10n.stationStock_print_idColumn,
    l10n.stationStock_table_barcodeColumn,
    l10n.stationStock_print_materialColumn,
    l10n.stationStock_print_maxColumn,
    l10n.stationStock_print_quantityColumn,
    l10n.stationStock_table_reservedColumn,
    l10n.stationStock_table_remainingColumn,
    l10n.stationStock_table_fillingColumn,
  ];

  try {
    final doc = await _buildDocument(title: title, headers: headers, stocks: stocks);
    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: l10n.stationStock_printTitle(title));
  } catch (e) {
    if (context.mounted) MessageUtils.showErrorSnackbar(context, l10n.fileExport_printErrorMessage(e));
  }
}

Future<pw.Document> _buildDocument({
  required String title,
  required List<String> headers,
  required List<StationStock> stocks,
}) async {
  final doc = pw.Document();
  final font = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 32, 28, 32),
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(child: pw.Text(title, style: const pw.TextStyle(fontSize: 11))),
          pw.SizedBox(height: 6),
          _headerRow(headers),
        ],
      ),
      build: (context) => [for (final stock in stocks) _stockRow(stock)],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
      ),
    ),
  );
  return doc;
}

pw.Widget _headerRow(List<String> headers) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(width: 0.6),
        bottom: pw.BorderSide(width: 0.6),
      ),
    ),
    child: _cells(headers),
  );
}

pw.Widget _stockRow(StationStock stock) {
  final barcode = stock.medicine?.barcode ?? '';
  final code128 = pw.Barcode.code128();
  final canDrawBarcode = barcode.isNotEmpty && code128.isValid(barcode);

  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 3, bottom: 4),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: 0.6)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _cells([
          stock.medicine?.id?.toString() ?? '-',
          barcode.isEmpty ? '-' : barcode,
          stock.medicine?.name ?? '-',
          _num(stock.maxQuantity),
          _num(stock.currentQuantity),
          _num(stock.reservedQuantity),
          _num(stock.remainingQuantity),
          _num(stock.fillingQuantity),
        ]),
        if (canDrawBarcode) ...[
          pw.SizedBox(height: 3),
          // Barkod, Id + Barkod kolonlarının genişliğini kaplar.
          pw.Row(
            children: [
              pw.Expanded(
                flex: _flexes[0] + _flexes[1],
                child: pw.BarcodeWidget(barcode: code128, data: barcode, height: _barcodeHeight, drawText: false),
              ),
              pw.Expanded(flex: _flexes.skip(2).fold(0, (a, b) => a + b), child: pw.SizedBox()),
            ],
          ),
        ],
      ],
    ),
  );
}

pw.Widget _cells(List<String> values) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < values.length; i++)
        pw.Expanded(
          flex: _flexes[i],
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 2),
            child: pw.Text(
              values[i],
              textAlign: i >= _numericFrom ? pw.TextAlign.right : pw.TextAlign.left,
              style: const pw.TextStyle(fontSize: _fontSize),
            ),
          ),
        ),
    ],
  );
}

String _num(num? value) => value == null ? '-' : value.formatFractional;
