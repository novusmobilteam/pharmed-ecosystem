// pharmed-client/lib/widgets/receipt_print_button.dart
//
// [SWREQ-PRN-100]
// Liste ekranlarında (İstasyon Envanter, Kabin Stok, ısı/nem) ekrandaki veriyi
// fiş yazıcısına gönderen buton. Kullanıcı isteğiyle basıldığı için sonuç her
// zaman bildirilir: başarı, yazıcı tanımlı değil dahil tüm hatalar.
//
// Fişi [buildReceipt] o anda oluşturur — buton basıldığı andaki veri basılır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/hardware/printer/printer.dart';
import '../core/providers/printer_providers.dart';

class ReceiptPrintButton extends ConsumerStatefulWidget {
  const ReceiptPrintButton({super.key, required this.buildReceipt, this.enabled = true});

  /// null dönerse (basılacak veri yok) yazdırma yapılmaz.
  final ReceiptDocument? Function() buildReceipt;
  final bool enabled;

  @override
  ConsumerState<ReceiptPrintButton> createState() => _ReceiptPrintButtonState();
}

class _ReceiptPrintButtonState extends ConsumerState<ReceiptPrintButton> {
  bool _printing = false;

  Future<void> _print() async {
    final document = widget.buildReceipt();
    if (document == null || document.isEmpty) return;

    setState(() => _printing = true);
    final result = await ref.read(receiptPrinterProvider).printReceipt(document);
    if (!mounted) return;
    setState(() => _printing = false);

    result.when(
      ok: (_) => MessageUtils.showSuccessSnackbar(context, context.l10n.printer_sentMessage),
      error: (e) => MessageUtils.showErrorSnackbar(context, printerFailureReasonOf(e).message(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MedButton(
      label: context.l10n.printer_printButton,
      variant: MedButtonVariant.secondary,
      size: MedButtonSize.sm,
      prefixIcon: Icon(PhosphorIcons.printer()),
      isLoading: _printing,
      onPressed: widget.enabled && !_printing ? _print : null,
    );
  }
}
