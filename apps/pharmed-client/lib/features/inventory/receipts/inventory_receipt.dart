// pharmed-client/lib/features/inventory/receipts/inventory_receipt.dart
//
// [SWREQ-PRN-101]
// İstasyon Envanter Listesi çıktısı — ekrandaki tablonun tüm satırları,
// filtre uygulanmadan, tablodaki sırayla: ilaç adı ve barkodu.
//
// Barkod, fişi kısa tutmak için çizgi barkod olarak değil metin olarak basılır
// (uzun listede her satıra çizgi barkod fişi metrelerce uzatır).
//
// Sınıf: Class B

import 'package:intl/intl.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

ReceiptDocument buildInventoryReceipt({
  required List<MedicineAssignment> items,
  required String? operatorName,
  DateTime? now,
}) {
  final l10n = contextlessL10n();
  final at = now ?? DateTime.now();

  return ReceiptDocument(
    title: l10n.printer_receipt_inventoryTitle,
    blocks: [
      const ReceiptText('Pharmed', size: ReceiptTextSize.title, align: ReceiptAlign.center),
      ReceiptText(l10n.printer_receipt_inventoryTitle, size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center),
      ReceiptText(DateFormat('dd.MM.yyyy  HH:mm:ss').format(at), align: ReceiptAlign.center),
      const ReceiptDivider(ReceiptDividerStyle.thick),
      for (final (i, item) in items.indexed) ...[
        ReceiptText('${i + 1}. ${item.medicine?.name ?? '—'}', bold: true),
        if ((item.medicine?.barcode ?? '').trim().isNotEmpty)
          ReceiptKeyValue(
            '${l10n.medicine_fieldBarcode}:',
            item.medicine!.barcode!.trim(),
            size: ReceiptTextSize.small,
            indent: 18,
          ),
        const ReceiptDivider(ReceiptDividerStyle.dashed),
      ],
      ReceiptKeyValue('${l10n.printer_receipt_itemCountLabel}:', '${items.length}', bold: true),
      if (operatorName != null && operatorName.trim().isNotEmpty)
        ReceiptKeyValue('${l10n.printer_receipt_operatorLabel}:', operatorName.trim()),
    ],
  );
}
