// pharmed-client/lib/features/printer_settings/receipts/printer_test_receipt.dart
//
// [SWREQ-PRN-080]
// Ayarlar › Yazıcı ekranındaki test fişi. Kurulumda kontrol edilecek her şeyi
// içerir: başlık fontu, Türkçe karakterler, sol-sağ satır, ayraç türleri,
// Code128 ve EAN-13 barkodlar, fiş sonu boşluğu.
//
// Sınıf: Class B

import 'package:intl/intl.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

ReceiptDocument buildPrinterTestReceipt(PrinterConfig config, {DateTime? now}) {
  final l10n = contextlessL10n();
  final at = now ?? DateTime.now();
  final connection = switch (config.connectionType) {
    PrinterConnectionType.serial => '${config.target} · ${config.baudRate}',
    PrinterConnectionType.windowsSpooler => config.target,
  };

  return ReceiptDocument(
    title: l10n.printer_testReceipt_title,
    blocks: [
      const ReceiptText('Pharmed', size: ReceiptTextSize.title, align: ReceiptAlign.center),
      ReceiptText(l10n.printer_testReceipt_title, size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center),
      ReceiptText(DateFormat('dd.MM.yyyy  HH:mm:ss').format(at), align: ReceiptAlign.center),
      const ReceiptDivider(ReceiptDividerStyle.thick),
      ReceiptKeyValue('${l10n.printer_settings_connectionLabel}:', connection),
      const ReceiptDivider(),
      ReceiptText(l10n.printer_testReceipt_charsetLabel, bold: true),
      const ReceiptText('ç ğ ı i ö ş ü   Ç Ğ I İ Ö Ş Ü'),
      const ReceiptText('0123456789  % / - + ( ) . , :'),
      const ReceiptDivider(ReceiptDividerStyle.dashed),
      ReceiptText(l10n.printer_testReceipt_barcodeLabel, bold: true),
      const ReceiptSpacer(),
      const ReceiptBarcode('P2026100601'),
      const ReceiptSpacer(),
      const ReceiptBarcode('869951200101', type: ReceiptBarcodeType.ean13, height: 50),
    ],
  );
}
