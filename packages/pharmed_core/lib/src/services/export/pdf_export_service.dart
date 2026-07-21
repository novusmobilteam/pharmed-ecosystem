// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:printing/printing.dart';

/// PDF üst başlık bloğunu ekran tarafında kurmak için imza.
/// Uzun başlık, hasta bilgi satırları, logo vb. serbestçe eklenebilir.
typedef PdfHeaderBuilder = pw.Widget Function(pw.Context context);

class PdfExportService {
  static Future<void> exportToPdf({
    required String fileName,
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String title = 'Rapor',
    PdfHeaderBuilder? headerBuilder,
    bool showSaveDialog = true,
  }) async {
    try {
      final doc = await _generateDocument(title, columnNames, data, headerBuilder);
      final bytes = await doc.save();

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        File? savedFile;
        if (showSaveDialog) {
          savedFile = await DesktopFileService.saveFile(extension: 'pdf', bytes: bytes, fileName: fileName);
        } else {
          savedFile = await DesktopFileService.saveToDesktop(bytes: bytes, fileName: fileName, extension: 'pdf');
        }
        if (savedFile != null) {
          MessageUtils.showSuccessSnackbar(context, 'Dosya kaydedildi: ${savedFile.path}');
        }
      } else {
        await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
      }
    } catch (e) {
      MessageUtils.showErrorSnackbar(context, 'PDF kaydetme hatası: $e');
      rethrow;
    }
  }

  static Future<void> directPrint({
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String title = 'Rapor',
    PdfHeaderBuilder? headerBuilder,
  }) async {
    try {
      final doc = await _generateDocument(title, columnNames, data, headerBuilder);
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save(), name: title);
    } catch (e) {
      MessageUtils.showErrorSnackbar(context, 'Yazdırma hatası: $e');
      rethrow;
    }
  }

  /// Kolon tanımlarından (displayValue) satır üreterek PDF export eder.
  static Future<void> exportRows({
    required String fileName,
    required List<String> columns,
    required List<List<String>> rows,
    required BuildContext context,
    String title = 'Tablo Raporu',
    PdfHeaderBuilder? headerBuilder,
    ExportBehavior exportBehavior = ExportBehavior.saveDialog,
  }) async {
    await exportToPdf(
      fileName: fileName,
      columnNames: columns,
      data: rows,
      context: context,
      title: title,
      headerBuilder: headerBuilder,
      showSaveDialog: exportBehavior == ExportBehavior.saveDialog,
    );
  }

  // === PRIVATE ===

  static Future<pw.Document> _generateDocument(
    String title,
    List<String> headers,
    List<List<dynamic>> data,
    PdfHeaderBuilder? headerBuilder,
  ) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context pdfContext) {
          return [
            // headerBuilder verilmişse onu kullan, yoksa varsayılan başlık
            headerBuilder != null ? headerBuilder(pdfContext) : _buildDefaultHeader(title),
            pw.SizedBox(height: 20),
            _buildTable(headers, data),
          ];
        },
        footer: (pw.Context context) => _buildFooter(context),
      ),
    );
    return doc;
  }

  static pw.Widget _buildDefaultHeader(String title) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            DateTime.now().toString().substring(0, 16),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<String> headers, List<List<dynamic>> data) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 8, // ← başlık boyutu
      ),
      cellStyle: const pw.TextStyle(fontSize: 6),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5), // ← padding de küçüldü
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Text(
        'Sayfa ${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PDF HEADER HELPER — yaygın "başlık + alt bilgi satırları" kalıbı
// Ekranlar her seferinde pw.Widget kurmak zorunda kalmasın diye
// hazır, esnek bir başlık bloğu. İstenirse hiç kullanılmayabilir.
// ═══════════════════════════════════════════════════════════════════

class PdfReportHeader {
  /// [title]    → ana başlık (uzun olabilir, sarar)
  /// [subtitle] → opsiyonel ikinci satır
  /// [infoLines]→ "Etiket: Değer" gibi alt bilgi satırları (hasta bilgisi vb.)
  /// [showDate] → sağ üstte tarih göster
  static PdfHeaderBuilder build({
    required String title,
    String? subtitle,
    List<String> infoLines = const [],
    bool showDate = true,
  }) {
    return (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              if (showDate)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text(
                    DateTime.now().toString().substring(0, 16),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(subtitle, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ],
          if (infoLines.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            ...infoLines.map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(line, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              ),
            ),
          ],
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey400, thickness: 1),
        ],
      );
    };
  }
}
