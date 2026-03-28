// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core.dart';
import '../file/desktop_file_service.dart';
import 'excel_export_service.dart'; // ExportBehavior için

class PdfExportService {
  // --- 1. DOSYAYA KAYDETME (SAVE) ---
  static Future<void> exportToPdf({
    required String fileName,
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String title = 'Rapor',
    bool showSaveDialog = true,
  }) async {
    try {
      // Ortak metot ile dökümanı oluştur
      final doc = await _generateDocument(title, columnNames, data);
      final bytes = await doc.save();

      // Platform kontrolü (Desktop için)
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        File? savedFile;
        if (showSaveDialog) {
          savedFile = await DesktopFileService.saveFile(
            extension: 'pdf',
            bytes: bytes,
            fileName: fileName,
          );
        } else {
          savedFile = await DesktopFileService.saveToDesktop(
            bytes: bytes,
            fileName: fileName,
            extension: 'pdf',
          );
        }

        if (savedFile != null) {
          MessageUtils.showSuccessSnackbar(context, 'Dosya kaydedildi: ${savedFile.path}');
        }
      } else {
        // Mobilde paylaşım ekranını açar
        await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
      }
    } catch (e) {
      MessageUtils.showErrorSnackbar(context, 'PDF kaydetme hatası: $e');
      rethrow;
    }
  }

  // --- 2. DİREKT YAZDIRMA (PRINT) ---
  static Future<void> directPrint({
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String title = 'Rapor',
  }) async {
    try {
      // 1. Dökümanı aynı mantıkla oluştur
      final doc = await _generateDocument(title, columnNames, data);

      // 2. Yazıcı diyaloğunu aç
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: title, // Yazdırma kuyruğunda görünecek ad
      );
    } catch (e) {
      MessageUtils.showErrorSnackbar(context, 'Yazdırma hatası: $e');
      rethrow;
    }
  }

  // --- TABLE DATA İÇİN WRAPPERLAR ---

  // Tabloyu Dosyaya Kaydet
  static Future<void> exportTableData<T extends TableData>({
    required String fileName,
    required List<String> columns,
    required List<T> data,
    required BuildContext context,
    String title = 'Tablo Raporu',
    ExportBehavior exportBehavior = ExportBehavior.saveDialog,
  }) async {
    final rowData = data.map((item) => item.content).toList();

    await exportToPdf(
      fileName: fileName,
      columnNames: columns,
      data: rowData,
      context: context,
      title: title,
      showSaveDialog: exportBehavior == ExportBehavior.saveDialog,
    );
  }

  // Tabloyu Direkt Yazdır (YENİ)
  static Future<void> printTableData<T extends TableData>({
    required List<DataColumn2> columns,
    required List<T> data,
    required BuildContext context,
    String title = 'Tablo Raporu',
  }) async {
    final columnNames = columns.map((col) => _getColumnName(col)).toList();
    final rowData = data.map((item) => item.content).toList();

    await directPrint(
      columnNames: columnNames,
      data: rowData,
      context: context,
      title: title,
    );
  }

  // === PRIVATE HELPERS (ORTAK MANTIK) ===

  // PDF Oluşturma Mantığı (Tek Bir Yerde)
  static Future<pw.Document> _generateDocument(
    String title,
    List<String> headers,
    List<List<dynamic>> data,
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
            _buildHeader(title),
            pw.SizedBox(height: 20),
            _buildTable(headers, data),
          ];
        },
        footer: (pw.Context context) => _buildFooter(context),
      ),
    );
    return doc;
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(DateTime.now().toString().substring(0, 16),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
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
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      rowDecoration:
          const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Text('Sayfa ${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
    );
  }

  static String _getColumnName(DataColumn2 column) {
    if (column.label is Text) {
      return (column.label as Text).data ?? 'Sütun';
    }
    return column.tooltip ?? 'Sütun';
  }
}
