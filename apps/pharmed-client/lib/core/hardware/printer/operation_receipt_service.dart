// pharmed-client/lib/core/hardware/printer/operation_receipt_service.dart
//
// [SWREQ-PRN-091] [IEC 62304 §5.5]
// İşlem fişini oluşturup yazıcıya gönderen servis. Alım/iade (kuyruk mixin'i)
// ve fire/imha (notifier) aynı servisi kullanır.
//
// Yazıcısı olmayan kiosk: yazıcı tanımlı değilse (notConfigured) fiş sessizce
// atlanır ve başarı döner — kullanıcı her işlemde uyarı görmez. Uyarı yalnızca
// yazıcı TANIMLIYKEN yazdırma başarısız olursa gösterilir.
//
// Güvenlik: yazdırma stok kaydının parçası değildir. Bu servis yalnızca kaydı
// tamamlanmış kalemlerle çağrılır, hiçbir hatada exception fırlatmaz ve
// yazdırma hatası kaydı etkilemez — sonuç yalnızca kullanıcıya gösterilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'operation_receipt.dart';

class OperationReceiptService {
  OperationReceiptService({required IReceiptPrinter printer, required String? Function() operatorName})
    : _printer = printer,
      _operatorName = operatorName;

  final IReceiptPrinter _printer;
  final String? Function() _operatorName;

  /// Kalem yoksa hiçbir şey yapmaz ve başarı döner.
  Future<Result<void>> printOperation({
    required OperationReceiptKind kind,
    required List<OperationReceiptLine> lines,
  }) async {
    if (lines.isEmpty) return const Result.ok(null);
    try {
      final document = buildOperationReceipt(
        kind: kind,
        lines: lines,
        operatorName: _operatorName(),
      );
      MedLogger.info(
        unit: 'SW-UNIT-PRN',
        swreq: 'SWREQ-PRN-091',
        message: 'İşlem fişi yazdırılıyor',
        context: {'kind': kind.name, 'lines': lines.length},
      );
      final result = await _printer.printReceipt(document);
      final skipped = result.when(
        ok: (_) => false,
        error: (e) => e is PrinterException && e.reason == PrinterFailureReason.notConfigured,
      );
      if (skipped) {
        MedLogger.info(
          unit: 'SW-UNIT-PRN',
          swreq: 'SWREQ-PRN-091',
          message: 'Kioskta yazıcı tanımlı değil, işlem fişi atlandı',
          context: {'kind': kind.name, 'lines': lines.length},
        );
        return const Result.ok(null);
      }
      return result;
    } catch (e, st) {
      MedLogger.error(
        unit: 'SW-UNIT-PRN',
        swreq: 'SWREQ-PRN-091',
        message: 'İşlem fişi oluşturulamadı',
        context: {'kind': kind.name, 'lines': lines.length},
        error: e,
        stackTrace: st,
      );
      return Result.error(
        PrinterException(message: 'İşlem fişi oluşturulamadı', reason: PrinterFailureReason.renderFailed, cause: e),
      );
    }
  }
}
