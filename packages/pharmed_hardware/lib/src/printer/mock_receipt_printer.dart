// pharmed-client/lib/core/hardware/printer/mock_receipt_printer.dart
//
// [SWREQ-PRN-070]
// Mock flavor ve yazıcısız geliştirme için IReceiptPrinter.
//
// Fişi gerçek yazıcıyla aynı rasterizer'dan geçirir ve PNG olarak kaydeder:
//   %LOCALAPPDATA%\PharMed\dev\receipts\<zaman>_<başlık>.png
// Barkodlar görüntüde çerçeveli yer tutucu olarak görünür.
// Böylece fiş tasarımı yazıcı olmadan da gözden geçirilebilir.
//
// Sınıf: Class B

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'receipt_rasterizer.dart';

class MockReceiptPrinter implements IReceiptPrinter {
  MockReceiptPrinter({String? outputDirectory, this.rasterizer = const ReceiptRasterizer()})
    : outputDirectory = outputDirectory ?? _defaultDirectory();

  final String outputDirectory;
  final ReceiptRasterizer rasterizer;

  static String _defaultDirectory() {
    final base = Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
    return p.join(base, 'PharMed', 'dev', 'receipts');
  }

  @override
  Future<Result<void>> printReceipt(ReceiptDocument document) async {
    try {
      if (document.isEmpty) {
        return const Result.error(
          PrinterException(message: 'Boş fiş yazdırılamaz', reason: PrinterFailureReason.invalidDocument),
        );
      }
      final pngs = await rasterizer.renderPreviewPng(document);
      await Directory(outputDirectory).create(recursive: true);

      final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final safeTitle = document.title.replaceAll(RegExp(r'[^\w\-]+', unicode: true), '_');
      final files = <String>[];
      for (var i = 0; i < pngs.length; i++) {
        final suffix = pngs.length > 1 ? '_${i + 1}' : '';
        final file = File(p.join(outputDirectory, '${stamp}_$safeTitle$suffix.png'));
        await file.writeAsBytes(pngs[i]);
        files.add(file.path);
      }

      MedLogger.info(
        unit: 'SW-UNIT-PRN',
        swreq: 'SWREQ-PRN-070',
        message: 'Mock yazıcı: fiş PNG olarak kaydedildi',
        context: {'title': document.title, 'files': files},
      );
      return const Result.ok(null);
    } catch (e, st) {
      MedLogger.error(
        unit: 'SW-UNIT-PRN',
        swreq: 'SWREQ-PRN-070',
        message: 'Mock yazıcı: fiş kaydedilemedi',
        error: e,
        stackTrace: st,
      );
      return Result.error(
        PrinterException(message: 'Fiş önizlemesi kaydedilemedi', reason: PrinterFailureReason.renderFailed, cause: e),
      );
    }
  }

  @override
  Future<void> close() async {}
}
