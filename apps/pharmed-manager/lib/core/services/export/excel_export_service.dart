import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

import '../../core.dart';
import '../file/desktop_file_service.dart';

class ExcelExportService {
  /// Masaüstü için Excel export
  static Future<void> exportToExcelDesktop({
    required String fileName,
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String? sheetName = 'Sheet1',
    bool showSaveDialog = true,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel[sheetName!];

      // Başlık satırını ekle (styling ile)
      for (int i = 0; i < columnNames.length; i++) {
        final cell = sheet.cell(CellIndex.indexByString("${_getExcelColumnName(i)}1"));
        cell.value = TextCellValue(columnNames[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // Veri satırlarını ekle
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final row = data[rowIndex];
        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          final value = row[colIndex]?.toString() ?? '';
          sheet.cell(CellIndex.indexByString("${_getExcelColumnName(colIndex)}${rowIndex + 2}")).value =
              TextCellValue(value);
        }
      }

      // Excel'i byte array'e dönüştür
      final bytes = excel.save();
      if (bytes != null) {
        File? savedFile;

        if (showSaveDialog) {
          // Kaydetme dialog'u göster
          savedFile = await DesktopFileService.saveFile(
            extension: 'xlsx',
            bytes: bytes,
            fileName: fileName,
          );
        } else {
          // Masaüstüne direkt kaydet
          savedFile = await DesktopFileService.saveToDesktop(
            bytes: bytes,
            fileName: fileName,
            extension: 'xlsx',
          );
        }

        if (savedFile != null && context.mounted) {
          MessageUtils.showSuccessSnackbar(context, 'Dosya başarıyla kaydedildi: ${savedFile.path}');
        } else {
          if (context.mounted) MessageUtils.showInfoSnackbar(context, 'Dosya kaydetme işlemi iptal edildi');
        }
      } else {
        MessageUtils.showErrorSnackbar(context, 'Excel dosyası oluşturulamadı');
      }
    } catch (e) {
      if (context.mounted) MessageUtils.showErrorSnackbar(context, 'Excel export işlemi başarısız: $e');
      rethrow;
    }
  }

  /// Platform bağımsız export - otomatik olarak platformu tespit eder
  static Future<void> exportToExcel({
    required String fileName,
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String? sheetName = 'Sheet1',
    bool showSaveDialog = true,
  }) async {
    // Platform kontrolü
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await exportToExcelDesktop(
        fileName: fileName,
        columnNames: columnNames,
        data: data,
        context: context,
        sheetName: sheetName,
        showSaveDialog: showSaveDialog,
      );
    }
  }

  /// Filtrelenmiş ve sıralanmış tablo verisi için export
  static Future<void> exportTableData<T extends TableData>({
    required String fileName,
    required List<String> columns,
    required List<T> data,
    required BuildContext context,
    bool showSaveDialog = true,
    ExportBehavior exportBehavior = ExportBehavior.saveDialog,
  }) async {
    try {
      final rowData = data.map((item) => item.content).toList();

      await exportToExcel(
        fileName: fileName,
        columnNames: columns,
        data: rowData,
        context: context,
        showSaveDialog: exportBehavior == ExportBehavior.saveDialog,
      );
    } catch (e) {
      if (context.mounted) MessageUtils.showErrorSnackbar(context, 'Tablo export işlemi başarısız: $e');
      rethrow;
    }
  }

  // === PRIVATE HELPERS ===

  static String _getExcelColumnName(int index) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (index < letters.length) {
      return letters[index];
    } else {
      final firstLetter = letters[(index ~/ 26) - 1];
      final secondLetter = letters[index % 26];
      return '$firstLetter$secondLetter';
    }
  }
}

enum ExportBehavior {
  saveDialog,
  saveToDesktop,
  custom,
}
