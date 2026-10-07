// pharmed-client/lib/features/cabin_stock/master/receipts/cabin_stock_receipt.dart
//
// [SWREQ-PRN-102]
// Kabin Stok çıktısı — seçili kabindeki TÜM atamalar (ekrandaki arama
// uygulanmadan), listedeki sırayla: ilaç adı, konum ve stok (mevcut/maks).
//
// Sınıf: Class B

import 'package:intl/intl.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/printer/printer.dart';

ReceiptDocument buildCabinStockReceipt({
  required String? cabinName,
  required List<MedicineAssignment> stocks,
  required String? operatorName,
  DateTime? now,
}) {
  final l10n = contextlessL10n();
  final at = now ?? DateTime.now();
  final cabin = cabinName?.trim();

  return ReceiptDocument(
    title: l10n.printer_receipt_cabinStockTitle,
    blocks: [
      const ReceiptText('Pharmed', size: ReceiptTextSize.title, align: ReceiptAlign.center),
      ReceiptText(l10n.printer_receipt_cabinStockTitle, size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center),
      ReceiptText(DateFormat('dd.MM.yyyy  HH:mm:ss').format(at), align: ReceiptAlign.center),
      if (cabin != null && cabin.isNotEmpty) ReceiptKeyValue('${l10n.printer_receipt_cabinLabel}:', cabin),
      const ReceiptDivider(ReceiptDividerStyle.thick),
      for (final (i, a) in stocks.indexed) ...[
        ReceiptText('${i + 1}. ${a.medicine?.name ?? '—'}', bold: true),
        ReceiptKeyValue(receiptLocationOf(a) ?? '', a.stockRatioLabel, size: ReceiptTextSize.small, indent: 18),
        const ReceiptDivider(ReceiptDividerStyle.dashed),
      ],
      ReceiptKeyValue('${l10n.printer_receipt_itemCountLabel}:', '${stocks.length}', bold: true),
      if (operatorName != null && operatorName.trim().isNotEmpty)
        ReceiptKeyValue('${l10n.printer_receipt_operatorLabel}:', operatorName.trim()),
    ],
  );
}
