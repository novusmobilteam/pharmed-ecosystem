// [SWREQ-MGR-REFILLLIST-003] [IEC 62304 §5.5]
//
// Tek bir dolum listesinin çıktısı (kaydetmeden doğrudan yazdırma).
// Üstte liste no, istasyon, tarih, dolum yapacak kişi ve durum; altında
// Barkod | Malzeme | Dolum | Mevcut | Maks kolonları. Her satırın altında,
// Barkod kolonunun genişliğinde Code128 barkod basılır (dolum sırasında el
// terminaliyle okutulabilsin diye). Stil istasyon stok çıktısıyla aynıdır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/refill_list_form_notifier.dart' show refillCurrentStock;

/// Kolon genişlikleri (flex). İlki barkod genişliğini belirler.
const _flexes = <int>[16, 44, 9, 9, 9];

/// Sayısal kolonlar (Dolum..Maks) sağa yaslanır.
const _numericFrom = 2;

const _fontSize = 7.5;
const _barcodeHeight = 22.0;

/// Listenin detayını çekip sistem yazdırma diyaloğuna gönderir.
Future<void> printRefillList({
  required BuildContext context,
  required RefillList list,
  Station? station,
}) async {
  final l10n = context.l10n;
  final id = list.id;
  if (id == null) return;

  final result = await context.read<GetRefillListDetailUseCase>().call(id);
  if (!context.mounted) return;

  final List<RefillObject>? objects = result.when(
    ok: (data) => data,
    error: (error) {
      MessageUtils.showErrorSnackbar(context, error.message);
      return null;
    },
  );
  if (objects == null) return;
  if (objects.isEmpty) {
    MessageUtils.showErrorSnackbar(context, l10n.refillList_print_noDetails);
    return;
  }

  final title = l10n.refillList_listTitle(id);
  final infoLines = [
    '${l10n.refillList_print_stationLabel}: ${(list.station ?? station)?.name ?? '-'}',
    '${l10n.movement_dateLabel}: ${list.date?.formattedDate ?? '-'}',
    '${l10n.refillList_fieldAssignedUser}: ${list.user?.fullName ?? '-'}',
    '${l10n.common_statusLabel}: ${list.status?.label ?? '-'}',
  ];
  final headers = [
    l10n.stationStock_table_barcodeColumn,
    l10n.stationStock_print_materialColumn,
    l10n.refillList_print_fillingColumn,
    l10n.refillList_print_currentColumn,
    l10n.stationStock_print_maxColumn,
  ];
  final total = objects.fold<num>(0, (sum, o) => sum + o.quantity);
  final totalLine = l10n.refillList_form_totalLabel(objects.length, total.formatFractional);

  try {
    final doc = await _buildDocument(
      title: title,
      infoLines: infoLines,
      headers: headers,
      objects: objects,
      totalLine: totalLine,
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: title);
  } catch (e) {
    if (context.mounted) MessageUtils.showErrorSnackbar(context, l10n.fileExport_printErrorMessage(e));
  }
}

Future<pw.Document> _buildDocument({
  required String title,
  required List<String> infoLines,
  required List<String> headers,
  required List<RefillObject> objects,
  required String totalLine,
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
          if (context.pageNumber == 1) ...[
            pw.Center(
              child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 18,
              runSpacing: 2,
              children: [for (final line in infoLines) pw.Text(line, style: const pw.TextStyle(fontSize: 8))],
            ),
            pw.SizedBox(height: 8),
          ],
          _headerRow(headers),
        ],
      ),
      build: (context) => [
        for (final o in objects) _row(o),
        pw.SizedBox(height: 6),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(totalLine, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ),
      ],
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

pw.Widget _row(RefillObject o) {
  final barcode = o.medicine?.barcode ?? '';
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
          barcode.isEmpty ? '-' : barcode,
          o.medicine?.name ?? '-',
          _num(o.quantity),
          _num(refillCurrentStock(o)),
          _num(o.assignment?.maxQuantity),
        ]),
        if (canDrawBarcode) ...[
          pw.SizedBox(height: 3),
          pw.Row(
            children: [
              pw.Expanded(
                flex: _flexes[0],
                child: pw.BarcodeWidget(barcode: code128, data: barcode, height: _barcodeHeight, drawText: false),
              ),
              pw.Expanded(flex: _flexes.skip(1).fold(0, (a, b) => a + b), child: pw.SizedBox()),
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
