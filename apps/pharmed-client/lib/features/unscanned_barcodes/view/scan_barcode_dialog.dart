import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/scan_barcode_dialog_notifier.dart';
import '../notifier/scan_barcode_dialog_state.dart';
import '../notifier/unscanned_barcodes_notifier.dart';

class ScanBarcodeDialog extends ConsumerStatefulWidget {
  const ScanBarcodeDialog({super.key, required this.prescriptionItemId});

  final int prescriptionItemId;

  @override
  ConsumerState<ScanBarcodeDialog> createState() => _ScanBarcodeDialogState();
}

class _ScanBarcodeDialogState extends ConsumerState<ScanBarcodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onComplete() async {
    final success = await ref
        .read(scanBarcodeDialogNotifierProvider.notifier)
        .submit(prescriptionItemId: widget.prescriptionItemId, qrCode: _controller.text);

    if (success && mounted) {
      ref.read(unscannedBarcodesNotifierProvider.notifier).refresh();
      Navigator.of(context).pop();
      MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanBarcodeDialogNotifierProvider);
    final isSubmitting = state is ScanBarcodeDialogSubmitting;

    return AlertDialog(
      title: Text(context.l10n.unscannedBarcode_scan_actionLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !isSubmitting,
            decoration: InputDecoration(labelText: context.l10n.common_barcodeLabel),
            onSubmitted: (_) => isSubmitting ? null : _onComplete(),
          ),
          if (state is ScanBarcodeDialogError) ...[
            const SizedBox(height: 8),
            Text(state.message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_dismissButton),
        ),
        MedButton(
          onPressed: isSubmitting ? null : _onComplete,
          label: context.l10n.common_completeButton,
          isLoading: isSubmitting,
        ),
      ],
    );
  }
}
