part of 'unscanned_barcodes_screen.dart';

void showScanBarcodeView(BuildContext context, PrescriptionItem data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UnscannedBarcodesNotifier>(),
      child: ScanBarcodeView(item: data),
    ),
  );
}

class ScanBarcodeView extends StatefulWidget {
  const ScanBarcodeView({super.key, required this.item});

  final PrescriptionItem item;

  @override
  State<ScanBarcodeView> createState() => _ScanBarcodeViewState();
}

class _ScanBarcodeViewState extends State<ScanBarcodeView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UnscannedBarcodesNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: context.l10n.unscannedBarcode_scan_actionLabel,
          maxHeight: 300,
          width: 500,
          onSave: () async {
            await notifier.scanBarcode(
              widget.item,
              onSuccess: () {
                MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                Navigator.pop(context);
              },
              onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
            );
          },
          saveButtonText: context.l10n.common_completeButton,
          child: TextFormField(
            maxLines: 1,
            decoration: InputDecoration(hintText: context.l10n.common_barcodeLabel, border: const OutlineInputBorder()),
            onChanged: (value) => notifier.barcode = value,
          ),
        );
      },
    );
  }
}
