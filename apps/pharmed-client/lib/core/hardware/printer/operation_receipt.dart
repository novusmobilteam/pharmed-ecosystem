// pharmed-client/lib/core/hardware/printer/operation_receipt.dart
//
// [SWREQ-PRN-090] [IEC 62304 §5.5]
// Stoğu etkileyen kabin işlemlerinin (alım / iade / fire / imha) fişi.
//
// Fiş YALNIZCA kaydı başarıyla yapılmış kalemleri listeler; kalemleri
// toplayan katman (CabinOperationReceiptMixin, fire/imha notifier'ı) kalemi
// API kaydı başarılı olduktan sonra ekler. İşlem yarıda kesilse de fiş aynı
// biçimdedir — listede yalnızca kaydedilen kalemler bulunur.
//
// Kalemler hastaya göre gruplanır: iade ve fire/imha listelerinde birden fazla
// hastanın kalemi olabilir. Her hasta grubunun başında hasta bilgisi ve
// protokol numarası barkodu basılır.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum OperationReceiptKind { intake, refund, wastage, destruction }

/// Fişteki tek kalem.
final class OperationReceiptLine {
  const OperationReceiptLine({
    required this.medicineName,
    required this.quantityLabel,
    this.hospitalization,
    this.location,
    this.barcode,
  });

  final String medicineName;

  /// Birimiyle birlikte miktar, ör. "4 Adet" / "2 Adet × 100 ml".
  final String quantityLabel;

  /// Kalemin hastası; hasta bağlamı olmayan işlemde null.
  final Hospitalization? hospitalization;

  /// Kabindeki konum (ör. "Çekmece A1 - Sütun 2 - Satır 3"); bilinmiyorsa null.
  final String? location;

  /// İlaç barkodu (GTIN); yoksa null.
  final String? barcode;
}

// ── Yardımcılar ──────────────────────────────────────────────────

/// Atamanın konum metni — CabinAssignmentListView ile aynı biçim.
String? receiptLocationOf(MedicineAssignment? assignment) {
  final unit = assignment?.drawerUnit;
  if (assignment == null || unit == null) return null;
  final l10n = contextlessL10n();
  return assignment.isKubikType
      ? l10n.cabinAssignmentList_cubicLocationLabel(
          unit.drawerSlot?.address ?? '-',
          unit.compartmentNo ?? '-',
          unit.orderNo ?? '-',
        )
      : l10n.cabinAssignmentList_unitLocationLabel(unit.drawerSlot?.orderNumber ?? '-', unit.compartmentNo ?? '-');
}

/// Birimiyle miktar ("4 Adet" / "2 Adet × 100 ml") — MedicineAssignment.quantityLabel
/// ile aynı biçim; atama bilgisi olmayan kalemler (fire/imha) için.
String receiptQuantityLabel(Medicine? medicine, num pieces) => MedicineAssignment(medicine: medicine).quantityLabel(pieces);

/// Hastanın fişte barkodu basılacak protokol numarası.
String? receiptProtocolOf(Hospitalization? h) {
  final protocol = h?.patient?.protocolNo?.trim();
  return protocol == null || protocol.isEmpty ? null : protocol;
}

// ── Fiş ─────────────────────────────────────────────────────────

ReceiptDocument buildOperationReceipt({
  required OperationReceiptKind kind,
  required List<OperationReceiptLine> lines,
  required String? operatorName,
  DateTime? now,
}) {
  final l10n = contextlessL10n();
  final at = now ?? DateTime.now();
  final title = switch (kind) {
    OperationReceiptKind.intake => l10n.printer_receipt_intakeTitle,
    OperationReceiptKind.refund => l10n.printer_receipt_refundTitle,
    OperationReceiptKind.wastage => l10n.printer_receipt_wastageTitle,
    OperationReceiptKind.destruction => l10n.printer_receipt_destructionTitle,
  };

  // Hasta sırası, kalemlerin geliş sırasını korur.
  final groups = groupBy<OperationReceiptLine, int?>(lines, (l) => l.hospitalization?.id);

  final blocks = <ReceiptBlock>[
    const ReceiptText('Pharmed', size: ReceiptTextSize.title, align: ReceiptAlign.center),
    ReceiptText(title, size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center),
    ReceiptText(DateFormat('dd.MM.yyyy  HH:mm:ss').format(at), align: ReceiptAlign.center),
    const ReceiptDivider(ReceiptDividerStyle.thick),
  ];

  var index = 0;
  for (final groupLines in groups.values) {
    final h = groupLines.first.hospitalization;
    if (h != null) {
      blocks.addAll(_patientBlocks(h));
      blocks.add(const ReceiptDivider(ReceiptDividerStyle.thick));
    }
    if (index == 0) {
      blocks
        ..add(ReceiptText(l10n.printer_receipt_medicineListTitle, size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center))
        ..add(const ReceiptDivider());
    }
    for (final line in groupLines) {
      index++;
      blocks
        ..add(ReceiptText('$index. ${line.medicineName}', bold: true))
        ..add(ReceiptKeyValue(line.quantityLabel, line.location ?? '', size: ReceiptTextSize.small, indent: 18));
      final barcode = line.barcode?.trim();
      if (barcode != null && barcode.isNotEmpty) {
        blocks
          ..add(const ReceiptSpacer(4))
          ..add(ReceiptBarcode(barcode, type: ReceiptBarcodeType.ean13, height: 50));
      }
      blocks.add(const ReceiptDivider(ReceiptDividerStyle.dashed));
    }
  }

  blocks.addAll([
    ReceiptKeyValue('${l10n.printer_receipt_itemCountLabel}:', '${lines.length}', bold: true),
    if (operatorName != null && operatorName.trim().isNotEmpty)
      ReceiptKeyValue('${l10n.printer_receipt_operatorLabel}:', operatorName.trim()),
  ]);

  return ReceiptDocument(title: title, blocks: blocks);
}

List<ReceiptBlock> _patientBlocks(Hospitalization h) {
  final l10n = contextlessL10n();
  final name = h.patient?.fullName;
  final protocol = receiptProtocolOf(h);
  final service = (h.inpatientService ?? h.physicalService)?.name;
  final room = h.room?.name;
  final bed = h.bed?.name;

  return [
    if (name != null && name.isNotEmpty)
      ReceiptText(name, size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center),
    if (protocol != null) ...[
      const ReceiptSpacer(4),
      ReceiptBarcode(protocol),
    ],
    const ReceiptSpacer(4),
    if (service != null && service.isNotEmpty) ReceiptKeyValue('${l10n.printer_receipt_serviceLabel}:', service),
    if (room != null || bed != null)
      ReceiptKeyValue('${l10n.printer_receipt_roomBedLabel}:', '${room ?? '-'} / ${bed ?? '-'}'),
  ];
}
