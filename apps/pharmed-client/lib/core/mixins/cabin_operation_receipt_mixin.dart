// [SWREQ-PRN-092] [IEC 62304 §5.5]
// Kabin kuyruğunun sonunda işlem fişi basan katman (master alım / iade).
// CabinDrawerQueueMixin'in hook'larını override eder; kuyruk mixin'i
// yazıcıdan habersiz kalır. Feature notifier'a eklemek yeterlidir:
//
//   class XxxNotifier extends ChangeNotifier
//       with MasterDrawerExecutionMixin,
//            CabinDrawerQueueMixin<XxxJob, XxxTarget>,
//            ...,
//            CabinOperationReceiptMixin<XxxJob, XxxTarget> { ... }
//
// SIRA: CabinDrawerQueueMixin'den SONRA gelmeli (hook'lar super zincirine oturur).
//
// Akış:
//   onQueueStarting  → toplanan kalemler sıfırlanır
//   onTargetSaved    → hedefin kalemleri fişe eklenir (yalnızca BAŞARILI kayıt)
//   onQueueFinishing → en az bir kalem varsa fiş arka planda basılır
//                      (durdurulan/hatayla biten kuyrukta da: kaydedilenler)
//
// Politika: BEST-EFFORT — yazdırma stok kaydının parçası değildir. Hata
// kuyruğu etkilemez; yalnızca [onReceiptFailed] ile ekrana bildirilir.
//
// Sınıf: Class B
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../hardware/printer/printer.dart';
import 'mixins.dart';

mixin CabinOperationReceiptMixin<TJob extends DrawerJob<TTarget>, TTarget extends DrawerJobTarget>
    on ChangeNotifier, MasterDrawerExecutionMixin, CabinDrawerQueueMixin<TJob, TTarget> {
  /// Provider'dan / testte fake ile enjekte edilir.
  OperationReceiptService get receiptService;

  OperationReceiptKind get receiptKind;

  /// Kaydı başarıyla yapılan hedefin fiş kalemleri. Kalemleri hedef dışında
  /// (ör. kalem kalem kayıt) toplayan feature boş liste dönüp
  /// [addReceiptLines]'ı kendisi çağırabilir.
  @protected
  List<OperationReceiptLine> receiptLinesOf(TTarget target);

  /// Yazdırma başarısız olunca çağrılır. View initState'te atar, dispose'ta temizler.
  void Function(PrinterFailureReason reason)? onReceiptFailed;

  List<OperationReceiptLine> _receiptLines = [];

  /// Bu kuyrukta fişe girecek kalemler (test/teşhis için salt okunur).
  List<OperationReceiptLine> get receiptLines => List.unmodifiable(_receiptLines);

  @protected
  void addReceiptLines(Iterable<OperationReceiptLine> lines) => _receiptLines.addAll(lines);

  @override
  Future<void> onQueueStarting() async {
    _receiptLines = [];
    await super.onQueueStarting();
  }

  @override
  void onTargetSaved(TTarget target) {
    super.onTargetSaved(target);
    addReceiptLines(receiptLinesOf(target));
  }

  @override
  void onQueueFinishing(QueueFinishReason reason) {
    super.onQueueFinishing(reason);
    final lines = _receiptLines;
    _receiptLines = [];
    if (lines.isEmpty) return;
    unawaited(_print(lines));
  }

  Future<void> _print(List<OperationReceiptLine> lines) async {
    final result = await receiptService.printOperation(kind: receiptKind, lines: lines);
    result.when(
      ok: (_) {},
      // Ekran bu arada kapandıysa View callback'i temizlemiştir; hata yine loglandı.
      error: (e) => onReceiptFailed?.call(printerFailureReasonOf(e)),
    );
  }
}
