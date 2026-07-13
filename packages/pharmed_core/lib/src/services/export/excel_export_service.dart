import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class ExcelExportService {
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

      for (int i = 0; i < columnNames.length; i++) {
        final cell = sheet.cell(CellIndex.indexByString("${_getExcelColumnName(i)}1"));
        cell.value = TextCellValue(columnNames[i]);
        cell.cellStyle = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
      }

      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final row = data[rowIndex];
        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          final value = row[colIndex]?.toString() ?? '';
          sheet.cell(CellIndex.indexByString("${_getExcelColumnName(colIndex)}${rowIndex + 2}")).value = TextCellValue(
            value,
          );
        }
      }

      final bytes = excel.save();
      if (bytes != null) {
        File? savedFile;
        if (showSaveDialog) {
          savedFile = await DesktopFileService.saveFile(extension: 'xlsx', bytes: bytes, fileName: fileName);
        } else {
          savedFile = await DesktopFileService.saveToDesktop(bytes: bytes, fileName: fileName, extension: 'xlsx');
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

  static Future<void> exportToExcel({
    required String fileName,
    required List<String> columnNames,
    required List<List<dynamic>> data,
    required BuildContext context,
    String? sheetName = 'Sheet1',
    bool showSaveDialog = true,
  }) async {
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

  /// Kolon tanımlarından (displayValue) satır üreterek export eder.
  ///
  /// [columns] → başlık listesi (l10n'lı title'lar)
  /// [rows]    → her item için, her kolonun displayValue'sundan üretilmiş
  ///             String satırlar. Tablo widget'ı bunu hazırlayıp verir.
  static Future<void> exportRows({
    required String fileName,
    required List<String> columns,
    required List<List<String>> rows,
    required BuildContext context,
    ExportBehavior exportBehavior = ExportBehavior.saveDialog,
  }) async {
    try {
      await exportToExcel(
        fileName: fileName,
        columnNames: columns,
        data: rows,
        context: context,
        showSaveDialog: exportBehavior == ExportBehavior.saveDialog,
      );
    } catch (e) {
      if (context.mounted) MessageUtils.showErrorSnackbar(context, 'Tablo export işlemi başarısız: $e');
      rethrow;
    }
  }

  /// Geriye dönük: content tabanlı eski çağrılar için korunur.
  static Future<void> exportTableData<T extends TableData>({
    required String fileName,
    required List<String> columns,
    required List<T> data,
    required BuildContext context,
    bool showSaveDialog = true,
    ExportBehavior exportBehavior = ExportBehavior.saveDialog,
  }) async {
    final rows = data.map((item) => item.content.map((c) => c?.toString() ?? '').toList()).toList();
    await exportRows(
      fileName: fileName,
      columns: columns,
      rows: rows,
      context: context,
      exportBehavior: exportBehavior,
    );
  }

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

enum ExportBehavior { saveDialog, saveToDesktop, custom }
